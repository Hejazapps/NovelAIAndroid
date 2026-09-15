import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/easy_seek_api_manager.dart';
import '../services/local_notification_service.dart';
import 'book_models.dart';
import 'save_vc.dart';

class BookGenerationManager extends ChangeNotifier {
  BookGenerationManager._();
  static final BookGenerationManager shared = BookGenerationManager._();

  static const _storageKey = 'generatedBooksV1';
  static const _historyKey = 'textDateEntries';
  final Map<String, GeneratedBook> _books = {};
  final Set<String> _active = {};
  bool _loaded = false;

  GeneratedBook? bookById(String id) => _books[id];

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded.whereType<Map>()) {
            var book = GeneratedBook.fromJson(Map<String, dynamic>.from(item));
            final chapters = book.chapters.map((c) {
              return c.status == BookChapterStatus.generating
                  ? c.copyWith(status: BookChapterStatus.pending)
                  : c;
            }).toList();
            book = book.copyWith(
              chapters: chapters,
              isGenerating: false,
              isCompleted: chapters.isNotEmpty &&
                  chapters.every((c) => c.status == BookChapterStatus.completed),
            );
            _books[book.id] = book;
          }
        }
      } catch (e) {
        debugPrint('Book load failed: $e');
      }
    }

    _loaded = true;
    notifyListeners();
  }

  /// Creates and persists a lightweight book immediately, without waiting for
  /// the outline network request. This lets BookDetailScreen open at once.
  Future<GeneratedBook> createBookDraft({
    required BookGenerationSpec spec,
  }) async {
    await ensureLoaded();

    final now = DateTime.now();
    final outline = _fallbackOutline(spec);

    final book = GeneratedBook(
      id: 'book_${now.microsecondsSinceEpoch}',
      spec: spec,
      outline: outline,
      chapters: List<GeneratedBookChapter>.generate(
        spec.chapterCount,
        (index) => GeneratedBookChapter(
          number: index + 1,
          title: 'Chapter ${index + 1}',
          status: BookChapterStatus.pending,
        ),
      ),
      isGenerating: true,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    _books[book.id] = book;
    notifyListeners();

    // Do not make the user wait on disk/history writes before opening the
    // chapter screen. Persistence continues immediately in the background.
    unawaited(_save().catchError((error) {
      debugPrint('⚠️ [BookGenerationManager] Draft persistence failed: $error');
    }));
    unawaited(LocalNotificationService.shared.prepare());
    return book;
  }

  /// Builds the real outline in the background, updates the visible chapter
  /// titles/plans, then generates all chapters sequentially.
  Future<void> prepareOutlineAndGenerate({
    required String bookId,
    required String outlinePrompt,
  }) async {
    await ensureLoaded();

    final draft = _books[bookId];
    if (draft == null) {
      throw StateError('Book not found.');
    }

    BookOutline outline;
    try {
      final raw = await _request(
        outlinePrompt,
        maxTokens: 4000,
        temperature: 0.72,
      );
      outline = _normalizeOutline(
        BookOutline.fromJson(_decodeObject(raw)),
        draft.spec,
      );
    } catch (error) {
      debugPrint(
        '⚠️ [BookGenerationManager] Outline parse/generation failed. '
        'Using fallback outline instead. Error: $error',
      );
      outline = _fallbackOutline(draft.spec);
    }

    final latest = _books[bookId];
    if (latest == null) return;

    final chapters = List<GeneratedBookChapter>.generate(
      latest.chapters.length,
      (index) {
        final old = latest.chapters[index];
        final plannedTitle = index < outline.chapters.length
            ? outline.chapters[index].title.trim()
            : '';
        return GeneratedBookChapter(
          number: old.number,
          title: plannedTitle.isEmpty ? 'Chapter ${index + 1}' : plannedTitle,
          content: old.content,
          status: old.status,
          errorMessage: old.errorMessage,
        );
      },
    );

    await _replace(
      GeneratedBook(
        id: latest.id,
        spec: latest.spec,
        outline: outline,
        chapters: chapters,
        isGenerating: true,
        isCompleted: latest.isCompleted,
        createdAt: latest.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    try {
      await generatePendingChapters(bookId);
    } catch (error) {
      // Never leave the visible draft permanently stuck in a generating state.
      final failed = _books[bookId];
      if (failed != null && failed.isGenerating) {
        final stopped = failed.copyWith(
          isGenerating: false,
          updatedAt: DateTime.now(),
        );
        _books[bookId] = stopped;
        notifyListeners();
        unawaited(_save().catchError((saveError) {
          debugPrint('⚠️ [BookGenerationManager] Failed to persist stopped state: $saveError');
        }));
      }
      rethrow;
    }
  }

  Future<GeneratedBook> createBook({
    required BookGenerationSpec spec,
    required String outlinePrompt,
  }) async {
    await ensureLoaded();

    BookOutline outline;

    try {
      final raw = await _request(
        outlinePrompt,
        maxTokens: 4000,
        temperature: 0.72,
      );

      final parsed = BookOutline.fromJson(_decodeObject(raw));
      outline = _normalizeOutline(parsed, spec);
    } catch (error) {
      debugPrint(
        '⚠️ [BookGenerationManager] Outline parse/generation failed. '
        'Using fallback outline instead. Error: $error',
      );

      outline = _fallbackOutline(spec);
    }

    final now = DateTime.now();

    final book = GeneratedBook(
      id: 'book_${now.microsecondsSinceEpoch}',
      spec: spec,
      outline: outline,
      chapters: List<GeneratedBookChapter>.generate(
        spec.chapterCount,
        (index) {
          final plan = outline.chapters[index];

          return GeneratedBookChapter(
            number: index + 1,
            title: plan.title.trim().isEmpty
                ? 'Chapter ${index + 1}'
                : plan.title.trim(),
          );
        },
      ),
      isGenerating: false,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    _books[book.id] = book;
    await _save();
    await _syncHistoryEntry(book);
    notifyListeners();

    return book;
  }

  Future<void> generatePendingChapters(String bookId) async {
    await ensureLoaded();
    if (_active.contains(bookId)) return;

    final initial = _books[bookId];
    if (initial == null || initial.isCompleted) return;
    _active.add(bookId);

    try {
      await _replace(initial.copyWith(
        isGenerating: true,
        updatedAt: DateTime.now(),
      ));

      while (true) {
        final book = _books[bookId];
        if (book == null) break;

        final index = book.chapters.indexWhere(
          (c) => c.status == BookChapterStatus.pending ||
              c.status == BookChapterStatus.failed,
        );
        if (index < 0) break;

        await _generateChapter(bookId, index);
      }

      final latest = _books[bookId];
      if (latest != null) {
        final done = latest.chapters.isNotEmpty &&
            latest.chapters.every((c) => c.status == BookChapterStatus.completed);

        await _replace(latest.copyWith(
          isGenerating: false,
          isCompleted: done,
          updatedAt: DateTime.now(),
        ));

        if (done) {
          unawaited(LocalNotificationService.shared.showBookCompleted(
            latest.spec.title,
            latest.chapters.length,
          ));
        }
      }
    } finally {
      _active.remove(bookId);
      final latest = _books[bookId];
      if (latest != null && latest.isGenerating) {
        await _replace(latest.copyWith(
          isGenerating: false,
          updatedAt: DateTime.now(),
        ));
      }
    }
  }

  Future<void> resumeBook(String id) => generatePendingChapters(id);


  Future<void> addChapter({
    required String bookId,
    required String requestedTitle,
    required String description,
  }) async {
    await ensureLoaded();

    final instruction = description.trim();
    if (instruction.isEmpty) {
      throw ArgumentError('Chapter description is required.');
    }

    if (_active.contains(bookId)) {
      throw StateError(
        'Please wait for the current chapter generation to finish.',
      );
    }

    final original = _books[bookId];
    if (original == null) {
      throw StateError('Book not found.');
    }

    _active.add(bookId);

    try {
      await _replace(
        original.copyWith(
          isGenerating: true,
          isCompleted: false,
          updatedAt: DateTime.now(),
        ),
      );

      final latestBeforePlan = _books[bookId];
      if (latestBeforePlan == null) {
        throw StateError('Book not found.');
      }

      final planPrompt = _buildAddedChapterPlanPrompt(
        latestBeforePlan,
        requestedTitle: requestedTitle.trim(),
        instruction: instruction,
      );

      BookOutlineChapter? plannedChapter;
      Object? lastPlanError;

      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          final prompt = attempt == 0
              ? planPrompt
              : '''$planPrompt

IMPORTANT RETRY:
The previous response was not valid complete JSON.
Return ONLY the complete JSON object again.
Keep it concise.
Close every string, array, and brace.
No markdown and no commentary.
''';

          final rawPlan = await _request(
            prompt,
            maxTokens: 1000,
            temperature: 0.45,
          );

          plannedChapter = BookOutlineChapter.fromJson(
            _decodeObject(rawPlan),
          );
          break;
        } catch (error) {
          lastPlanError = error;
          debugPrint(
            'Added chapter plan parse attempt ${attempt + 1}/2 failed: $error',
          );
        }
      }

      if (plannedChapter == null) {
        throw FormatException(
          'Unable to create a valid chapter plan after one retry. '
          '${lastPlanError ?? ''}',
        );
      }

      var newOutlineChapter = plannedChapter;

      final nextNumber = latestBeforePlan.chapters.length + 1;
      final finalTitle = requestedTitle.trim().isNotEmpty
          ? requestedTitle.trim()
          : (newOutlineChapter.title.trim().isEmpty
              ? 'Chapter $nextNumber'
              : newOutlineChapter.title.trim());

      newOutlineChapter = BookOutlineChapter(
        title: finalTitle,
        mode: newOutlineChapter.mode.trim().isEmpty
            ? 'Continuation'
            : newOutlineChapter.mode.trim(),
        setting: newOutlineChapter.setting.trim(),
        timeframe: newOutlineChapter.timeframe.trim(),
        focusCharacters: newOutlineChapter.focusCharacters,
        beat: newOutlineChapter.beat.trim().isEmpty
            ? instruction
            : newOutlineChapter.beat.trim(),
        advances: newOutlineChapter.advances.trim().isEmpty
            ? instruction
            : newOutlineChapter.advances.trim(),
      );

      final current = _books[bookId];
      if (current == null) {
        throw StateError('Book not found.');
      }

      final updatedOutline = BookOutline(
        title: current.outline.title,
        premise: current.outline.premise,
        throughline: current.outline.throughline,
        arc: current.outline.arc,
        cost: current.outline.cost,
        climaxChapter: current.outline.climaxChapter,
        chapters: [...current.outline.chapters, newOutlineChapter],
      );

      final updatedSpec = BookGenerationSpec(
        title: current.spec.title,
        bookDescription: current.spec.bookDescription,
        author: current.spec.author,
        language: current.spec.language,
        tone: current.spec.tone,
        category: current.spec.category,
        length: current.spec.length,
        chapterCount: current.spec.chapterCount + 1,
        ageGroup: current.spec.ageGroup,
        characters: current.spec.characters,
      );

      final newChapter = GeneratedBookChapter(
        number: nextNumber,
        title: finalTitle,
        status: BookChapterStatus.pending,
      );

      final extendedBook = GeneratedBook(
        id: current.id,
        spec: updatedSpec,
        outline: updatedOutline,
        chapters: [...current.chapters, newChapter],
        isGenerating: true,
        isCompleted: false,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );

      await _replace(extendedBook);

      await _generateChapter(bookId, nextNumber - 1);

      final finished = _books[bookId];
      if (finished != null) {
        final allDone = finished.chapters.isNotEmpty &&
            finished.chapters.every(
              (chapter) => chapter.status == BookChapterStatus.completed,
            );

        await _replace(
          finished.copyWith(
            isGenerating: false,
            isCompleted: allDone,
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (error) {
      final latest = _books[bookId];

      if (latest != null && latest.isGenerating) {
        await _replace(
          latest.copyWith(
            isGenerating: false,
            isCompleted: latest.chapters.isNotEmpty &&
                latest.chapters.every(
                  (chapter) =>
                      chapter.status == BookChapterStatus.completed,
                ),
            updatedAt: DateTime.now(),
          ),
        );
      }

      rethrow;
    } finally {
      _active.remove(bookId);
    }
  }

  String _buildAddedChapterPlanPrompt(
    GeneratedBook book, {
    required String requestedTitle,
    required String instruction,
  }) {
    final outline = book.outline;
    final spec = book.spec;
    final nextNumber = book.chapters.length + 1;

    final existingOutline = outline.chapters.asMap().entries.map((entry) {
      final number = entry.key + 1;
      final chapter = entry.value;

      return '''
Chapter $number
Title: ${chapter.title}
Mode: ${chapter.mode}
Setting: ${chapter.setting}
Timeframe: ${chapter.timeframe}
Focus Characters: ${chapter.focusCharacters.join(', ')}
Beat: ${chapter.beat}
Advances: ${chapter.advances}
''';
    }).join('\n');

    final completed = book.chapters
        .where((chapter) =>
            chapter.status == BookChapterStatus.completed &&
            chapter.content.trim().isNotEmpty)
        .toList();

    String recentContinuity;

    if (completed.isEmpty) {
      recentContinuity = 'No completed chapter prose is available.';
    } else {
      final recent = completed.length <= 2
          ? completed
          : completed.sublist(completed.length - 2);

      recentContinuity = recent.map((chapter) {
        return '''
${chapter.title}:
${_tailForPlanning(chapter.content)}
''';
      }).join('\n\n');
    }

    final suppliedCharacters = spec.characters.isEmpty
        ? 'None specifically supplied by the user.'
        : spec.characters
            .map((character) =>
                '- ${character.name}: ${character.description}')
            .join('\n');

    return '''
You are the continuity editor and story architect for an EXISTING book.

The book already has ${book.chapters.length} chapters.
The reader is adding Chapter $nextNumber later.

Your job is NOT to write prose yet.
Design ONE new chapter plan that naturally continues the existing book.

BOOK
Title: ${spec.title}
Genre: ${spec.category}
Language: ${spec.language}
Tone: ${spec.tone}
Audience: ${spec.ageGroup}

ORIGINAL PREMISE
${outline.premise}

CENTRAL THROUGHLINE
${outline.throughline}

OVERALL ARC
${outline.arc}

CENTRAL COST / STAKES
${outline.cost}

ORIGINAL CLIMAX CHAPTER
${outline.climaxChapter}

CHARACTERS
$suppliedCharacters

EXISTING CHAPTER OUTLINE
$existingOutline

RECENT ACTUAL PROSE FOR CONTINUITY
$recentContinuity

USER REQUEST FOR THE NEW CHAPTER
Requested title:
${requestedTitle.isEmpty ? 'No title supplied. Create a suitable title.' : requestedTitle}

What should happen:
$instruction

CONTINUITY RULES
- Treat every completed chapter as canon.
- Do not contradict established facts, chronology, locations, injuries,
  possessions, promises, discoveries, relationships, deaths, or character goals.
- Begin from the actual story state after the latest completed chapter.
- Preserve established character voice, knowledge, motivation, and emotion.
- Do not reset relationships or repeat a conflict that was already resolved.
- Do not undo the original ending or climax merely to create drama.
- If the original central conflict is already resolved, continue through
  aftermath, consequences, a new development, or the user's requested event.
- Respect the user's requested event, but make it logically fit existing canon.
- Reuse prior setup/payoff opportunities where appropriate.
- Avoid filler and avoid copying the previous chapter's structure.

Return STRICT JSON only:
{
  "title": "chapter title",
  "mode": "dominant chapter mode",
  "setting": "primary setting",
  "timeframe": "time relation to previous chapter",
  "focusCharacters": ["name"],
  "beat": "starting state -> pressure/conflict -> development -> meaningful turn -> consequence/landing",
  "advances": "how this chapter advances or extends the existing book"
}

No markdown.
No commentary.
No prose outside the JSON.
''';
  }

  String _tailForPlanning(String content) {
    final cleaned = content.trim();
    if (cleaned.isEmpty) return 'No usable prose.';
    const maxChars = 1800;
    if (cleaned.length <= maxChars) return cleaned;
    return cleaned.substring(cleaned.length - maxChars);
  }

  Future<void> retryChapter(String id, int index) async {
    final book = _books[id];
    if (book == null || _active.contains(id)) return;

    final chapters = [...book.chapters];
    chapters[index] = chapters[index].copyWith(
      status: BookChapterStatus.pending,
      errorMessage: '',
    );

    await _replace(book.copyWith(
      chapters: chapters,
      isCompleted: false,
      updatedAt: DateTime.now(),
    ));

    await generatePendingChapters(id);
  }

  Future<void> _generateChapter(String id, int index) async {
    var book = _books[id];
    if (book == null) return;

    var chapters = [...book.chapters];
    chapters[index] = chapters[index].copyWith(
      status: BookChapterStatus.generating,
      errorMessage: '',
    );
    book = book.copyWith(
      chapters: chapters,
      isGenerating: true,
      updatedAt: DateTime.now(),
    );
    await _replace(book);

    try {
      final content = (await _request(
        _chapterPrompt(book, index),
        maxTokens: _chapterMaxTokens(book.spec.length),
        temperature: 0.75,
      ))
          .trim();

      if (content.isEmpty) {
        throw Exception('Empty chapter response');
      }

      final latest = _books[id]!;
      chapters = [...latest.chapters];
      chapters[index] = chapters[index].copyWith(
        content: content,
        status: BookChapterStatus.completed,
        errorMessage: '',
      );

      await _replace(latest.copyWith(
        chapters: chapters,
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      final latest = _books[id]!;
      chapters = [...latest.chapters];
      chapters[index] = chapters[index].copyWith(
        status: BookChapterStatus.failed,
        errorMessage: e.toString(),
      );
      await _replace(latest.copyWith(
        chapters: chapters,
        isGenerating: false,
        updatedAt: DateTime.now(),
      ));
      rethrow;
    }
  }

  BookOutline _normalizeOutline(
    BookOutline parsed,
    BookGenerationSpec spec,
  ) {
    final chapters = <BookOutlineChapter>[];

    for (var index = 0; index < spec.chapterCount; index++) {
      if (index < parsed.chapters.length) {
        final source = parsed.chapters[index];

        chapters.add(
          BookOutlineChapter(
            title: source.title.trim().isEmpty
                ? 'Chapter ${index + 1}'
                : source.title.trim(),
            mode: source.mode,
            setting: source.setting,
            timeframe: source.timeframe,
            focusCharacters: source.focusCharacters,
            beat: source.beat.trim().isEmpty
                ? _defaultChapterBeat(spec)
                : source.beat.trim(),
            advances: source.advances,
          ),
        );
      } else {
        chapters.add(_defaultChapterPlan(index + 1, spec));
      }
    }

    final climaxChapter =
        parsed.climaxChapter.clamp(1, spec.chapterCount).toInt();

    return BookOutline(
      title: parsed.title.trim().isEmpty
          ? spec.title
          : parsed.title.trim(),
      premise: parsed.premise.trim().isEmpty
          ? spec.bookDescription
          : parsed.premise.trim(),
      throughline: parsed.throughline.trim().isEmpty
          ? spec.bookDescription
          : parsed.throughline.trim(),
      arc: parsed.arc,
      cost: parsed.cost,
      climaxChapter: climaxChapter,
      chapters: chapters,
    );
  }

  BookOutline _fallbackOutline(BookGenerationSpec spec) {
    return BookOutline(
      title: spec.title,
      premise: spec.bookDescription,
      throughline: spec.bookDescription,
      arc: '',
      cost: '',
      climaxChapter: spec.chapterCount,
      chapters: List<BookOutlineChapter>.generate(
        spec.chapterCount,
        (index) => _defaultChapterPlan(index + 1, spec),
      ),
    );
  }

  BookOutlineChapter _defaultChapterPlan(
    int number,
    BookGenerationSpec spec,
  ) {
    return BookOutlineChapter(
      title: 'Chapter $number',
      mode: '',
      setting: '',
      timeframe: '',
      focusCharacters: const [],
      beat: _defaultChapterBeat(spec),
      advances: '',
    );
  }

  String _defaultChapterBeat(BookGenerationSpec spec) {
    return 'Advance the story of ${spec.title} through a distinct chapter '
        'with its own goal, complication, meaningful turn, consequence, '
        'and natural landing.';
  }

  String _chapterPrompt(GeneratedBook book, int index) {
    final s = book.spec;
    final o = book.outline;
    final c = o.chapters[index];

    final completedBefore = book.chapters
        .take(index)
        .where((e) =>
            e.status == BookChapterStatus.completed &&
            e.content.trim().isNotEmpty)
        .toList();

    final previous = completedBefore.isEmpty
        ? 'No previous chapter. This is the opening chapter.'
        : _tail(completedBefore.last.content);

    final continuityLedger = completedBefore.isEmpty
        ? 'No previous completed chapters.'
        : completedBefore.map((chapter) {
            return '- Chapter ${chapter.number}: ${chapter.title}';
          }).join('\n');

    final characters = s.characters.isEmpty
        ? 'None specifically provided.'
        : s.characters.map((e) => '- ${e.name}: ${e.description}').join('\n');

    return '''
Write only Chapter ${index + 1} of ${s.chapterCount} for this connected book.

BOOK
Title: ${s.title}
Genre: ${s.category}
Language: ${s.language}
Tone: ${s.tone}
Audience: ${s.ageGroup}
Target length: ${_target(s.length)}

PREMISE
${o.premise}

THROUGHLINE
${o.throughline}

OVERALL ARC
${o.arc}

COST / STAKES
${o.cost}

ORIGINAL CLIMAX CHAPTER
${o.climaxChapter}

CHARACTERS
$characters

COMPLETED CHAPTER LEDGER
$continuityLedger

CURRENT CHAPTER PLAN
Title: ${c.title}
Mode: ${c.mode}
Setting: ${c.setting}
Timeframe: ${c.timeframe}
Focus characters: ${c.focusCharacters.join(', ')}
Beat: ${c.beat}
Must advance: ${c.advances}

MOST RECENT ACTUAL PROSE
$previous

CONTINUITY RULES
- Everything already written is canon.
- Preserve facts, chronology, locations, injuries, possessions, promises,
  discoveries, relationships, character knowledge, and emotional development.
- Continue from the actual state left by the previous chapter.
- Do not reset character arcs or repeat already-resolved conflicts.
- Do not reverse established events unless the plan logically supports it.
- Keep character voices and motivations consistent.
- Make new events consequences of prior choices whenever possible.
- If this is a later-added chapter after the original ending, extend the
  original ending naturally instead of erasing it.

WRITING RULES
- Write only this chapter.
- Follow the current chapter plan while keeping the prose natural.
- Give the chapter its own dramatic movement and meaningful consequence.
- Stay close to the requested target length. Do not produce a chapter that is
  dramatically longer than ${_target(s.length)}.
- Prefer concise, purposeful prose over padding.
- Avoid filler, repetitive scene patterns, summary-heavy prose, and generic AI phrases.
- Do not prematurely resolve a still-active central conflict.
- Write entirely in ${s.language}.
- Output only finished chapter prose.
- Do not output instructions, analysis, JSON, or markdown fences.
''';
  }


  int _chapterMaxTokens(String length) {
    final value = length.toLowerCase();

    // Keep enough headroom for the requested prose while avoiding the
    // 3500-token ceiling for every single chapter.
    if (value.contains('short')) {
      return 1100;
    }

    if (value.contains('long')) {
      return 2400;
    }

    return 1700;
  }

  String _target(String length) {
    final v = length.toLowerCase();
    if (v.contains('short')) return '300-400 words';
    if (v.contains('long')) return '800-1000 words';
    return '500-700 words';
  }

  String _tail(String text) =>
      text.length <= 2200 ? text : text.substring(text.length - 2200);

  Future<String> _request(
    String prompt, {
    int maxTokens = 3500,
    double temperature = 0.8,
  }) async {
    final result = await EasySeekApiManager.shared.completeBookResponse(
      messages: [
        TogetherAIMessage.user(prompt),
      ],
      maxTokens: maxTokens,
      temperature: temperature,
      timeout: const Duration(seconds: 120),
    );

    final cleaned = result?.trim() ?? '';
    if (cleaned.isEmpty) {
      throw Exception('Book generation request failed');
    }

    return cleaned;
  }

  Map<String, dynamic> _decodeObject(String raw) {
    var cleaned = raw.trim();
    cleaned = cleaned.replaceFirst(
      RegExp(r'^```(?:json)?\s*', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');

    final a = cleaned.indexOf('{');
    final b = cleaned.lastIndexOf('}');
    if (a >= 0 && b > a) cleaned = cleaned.substring(a, b + 1);

    final decoded = jsonDecode(cleaned);
    if (decoded is! Map) throw const FormatException('Invalid outline JSON');
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _replace(GeneratedBook book) async {
    _books[book.id] = book;
    await _save();
    await _syncHistoryEntry(book);
    notifyListeners();
  }

  Future<void> updateChapterContent(
    String bookId,
    int chapterIndex,
    String content,
  ) async {
    await ensureLoaded();

    final book = _books[bookId];
    if (book == null ||
        chapterIndex < 0 ||
        chapterIndex >= book.chapters.length) {
      return;
    }

    final chapters = [...book.chapters];
    chapters[chapterIndex] = chapters[chapterIndex].copyWith(
      content: content,
      status: content.trim().isEmpty
          ? BookChapterStatus.pending
          : BookChapterStatus.completed,
      errorMessage: '',
    );

    final completed = chapters.isNotEmpty &&
        chapters.every((e) => e.status == BookChapterStatus.completed);

    await _replace(
      book.copyWith(
        chapters: chapters,
        isCompleted: completed,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteBook(String bookId) async {
    await ensureLoaded();

    _active.remove(bookId);
    _books.remove(bookId);
    await _save();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          decoded.removeWhere(
            (item) =>
                item is Map &&
                (item['bookId'] ?? '').toString() == bookId,
          );
          await prefs.setString(_historyKey, jsonEncode(decoded));
        }
      } catch (_) {}
    }

    saveVcHistoryRevision.value++;
    notifyListeners();
  }

  String _historyDateText(DateTime date) {
    final local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  String _historyStatus(GeneratedBook book) {
    if (book.isCompleted) return 'Completed';
    if (book.isGenerating) return 'Generating';
    if (book.chapters.any((e) => e.status == BookChapterStatus.failed)) {
      return 'Paused';
    }
    return 'Incomplete';
  }

  Future<void> _syncHistoryEntry(GeneratedBook book) async {
    final prefs = await SharedPreferences.getInstance();

    List<dynamic> entries = <dynamic>[];
    final raw = prefs.getString(_historyKey);

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) entries = decoded;
      } catch (_) {}
    }

    int existingIndex = -1;
    for (int i = 0; i < entries.length; i++) {
      final item = entries[i];
      if (item is Map &&
          (item['bookId'] ?? '').toString() == book.id) {
        existingIndex = i;
        break;
      }
    }

    final oldEntry = existingIndex >= 0 && entries[existingIndex] is Map
        ? Map<String, dynamic>.from(entries[existingIndex] as Map)
        : <String, dynamic>{};

    final status = _historyStatus(book);
    final completedChapters = book.chapters
        .where((c) =>
            c.status == BookChapterStatus.completed &&
            c.content.trim().isNotEmpty)
        .toList();
    final completed = completedChapters.length;
    final total = book.chapters.length;

    // History must never contain an empty Book item. If an older draft entry
    // exists, remove it until at least one chapter has real generated text.
    if (completedChapters.isEmpty) {
      entries.removeWhere(
        (item) =>
            item is Map &&
            (item['bookId'] ?? '').toString() == book.id,
      );
      await prefs.setString(_historyKey, jsonEncode(entries));
      saveVcHistoryRevision.value++;
      return;
    }

    final completedText =
        completedChapters.map((c) => c.content.trim()).join('\n\n');

    final entry = <String, dynamic>{
      'id': book.id,
      'bookId': book.id,
      'text': completedText,
      'progress': '$completed/$total',
      'date': _historyDateText(book.updatedAt),
      'lang': book.spec.language,
      'title': book.spec.title,
      'category': book.spec.category,
      'folder': (oldEntry['folder'] ?? '').toString(),
      'isFav': oldEntry['isFav'] == true,
      'hasTag': '${book.spec.category},${book.spec.tone}',
      'font': 'PlusJakartaSans-Medium',
      'contentType': 'Book',
      'themeId': '',
      'bookStatus': status,
      'completedChapters': completed,
      'totalChapters': total,
      'wordCount': book.totalWordCount,
      'readMinutes': book.estimatedReadMinutes,
      'colortype': '0',
    };

    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }

    await prefs.setString(_historyKey, jsonEncode(entries));
    saveVcHistoryRevision.value++;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_books.values.map((e) => e.toJson()).toList()),
    );
  }
}
