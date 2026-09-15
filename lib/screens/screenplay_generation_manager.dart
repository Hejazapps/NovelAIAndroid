import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/easy_seek_api_manager.dart';
import '../services/local_notification_service.dart';
import 'screenplay_models.dart';

class ScreenplayGenerationManager extends ChangeNotifier {
  ScreenplayGenerationManager._();

  static final ScreenplayGenerationManager shared =
      ScreenplayGenerationManager._();

  static const _storageKey = 'generatedScreenplaysV1';
  static const _historyKey = 'textDateEntries';

  final Map<String, GeneratedScreenplay> _screenplays = {};
  final Set<String> _active = {};
  bool _loaded = false;

  GeneratedScreenplay? screenplayById(String id) => _screenplays[id];

  Future<void> ensureLoaded() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded.whereType<Map>()) {
            final screenplay = GeneratedScreenplay.fromJson(
              Map<String, dynamic>.from(item),
            );

            final episodes = screenplay.episodes.map((episode) {
              if (episode.status == ScreenplayEpisodeStatus.generating) {
                return episode.copyWith(status: ScreenplayEpisodeStatus.pending);
              }
              return episode;
            }).toList();

            _screenplays[screenplay.id] = screenplay.copyWith(
              episodes: episodes,
              isGenerating: false,
              isCompleted: episodes.isNotEmpty &&
                  episodes.every(
                    (e) => e.status == ScreenplayEpisodeStatus.completed,
                  ),
              updatedAt: screenplay.updatedAt,
            );
          }
        }
      } catch (error) {
        debugPrint('Screenplay load failed: $error');
      }
    }

    _loaded = true;
    notifyListeners();
  }

  /// Creates and persists a screenplay shell immediately so the episode
  /// screen can open without waiting for the outline API request.
  Future<GeneratedScreenplay> createScreenplayDraft({
    required ScreenplayGenerationSpec spec,
  }) async {
    await ensureLoaded();

    final now = DateTime.now();
    final outline = _fallbackOutline(spec);

    final screenplay = GeneratedScreenplay(
      id: 'screenplay_${now.microsecondsSinceEpoch}',
      spec: spec,
      outline: outline,
      episodes: List<GeneratedScreenplayEpisode>.generate(
        spec.resolvedSceneCount,
        (index) => GeneratedScreenplayEpisode(
          number: index + 1,
          title: 'Episode ${index + 1}',
          status: ScreenplayEpisodeStatus.pending,
        ),
      ),
      isGenerating: true,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    _screenplays[screenplay.id] = screenplay;
    notifyListeners();

    // Open the episode screen first; disk persistence can finish in the
    // background and must not delay navigation.
    unawaited(_persist().catchError((error) {
      debugPrint('⚠️ [ScreenplayGenerationManager] Draft persistence failed: $error');
    }));
    unawaited(LocalNotificationService.shared.prepare());
    return screenplay;
  }

  /// Generates the real outline in the background, replaces the placeholder
  /// episode plans/titles, then starts sequential episode generation.
  Future<void> prepareOutlineAndGenerate({
    required String screenplayId,
    required String outlineSystemPrompt,
    required String outlinePrompt,
  }) async {
    await ensureLoaded();

    final draft = _screenplays[screenplayId];
    if (draft == null) {
      throw StateError('Screenplay not found.');
    }

    ScreenplayOutline outline;
    try {
      final raw = await _request(
        systemPrompt: outlineSystemPrompt,
        userPrompt: outlinePrompt,
        maxTokens: 4000,
        temperature: 0.72,
      );

      outline = _normalizeOutline(
        ScreenplayOutline.fromJson(_decodeOutlineObject(raw)),
        draft.spec,
      );
    } catch (error) {
      debugPrint(
        '⚠️ [ScreenplayGenerationManager] Outline failed; '
        'using fallback outline. Error: $error',
      );
      outline = _fallbackOutline(draft.spec);
    }

    final latest = _screenplays[screenplayId];
    if (latest == null) return;

    final episodes = List<GeneratedScreenplayEpisode>.generate(
      latest.episodes.length,
      (index) {
        final old = latest.episodes[index];
        final plannedTitle = index < outline.episodes.length
            ? outline.episodes[index].title.trim()
            : '';

        return GeneratedScreenplayEpisode(
          number: old.number,
          title: plannedTitle.isEmpty ? 'Episode ${index + 1}' : plannedTitle,
          content: old.content,
          status: old.status,
          errorMessage: old.errorMessage,
        );
      },
    );

    // Construct a new model instead of relying on copyWith(outline: ...),
    // keeping compatibility with the current model implementation.
    await _replace(
      GeneratedScreenplay(
        id: latest.id,
        spec: latest.spec,
        outline: outline,
        episodes: episodes,
        isGenerating: true,
        isCompleted: latest.isCompleted,
        createdAt: latest.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    try {
      await generatePendingEpisodes(screenplayId);
    } catch (error) {
      // Never leave the visible draft permanently stuck in a generating state.
      final failed = _screenplays[screenplayId];
      if (failed != null && failed.isGenerating) {
        final stopped = failed.copyWith(
          isGenerating: false,
          updatedAt: DateTime.now(),
        );
        _screenplays[screenplayId] = stopped;
        notifyListeners();
        unawaited(_persist().catchError((saveError) {
          debugPrint('⚠️ [ScreenplayGenerationManager] Failed to persist stopped state: $saveError');
        }));
      }
      rethrow;
    }
  }

  Future<GeneratedScreenplay> createScreenplay({
    required ScreenplayGenerationSpec spec,
    required String outlineSystemPrompt,
    required String outlinePrompt,
  }) async {
    await ensureLoaded();

    ScreenplayOutline outline;

    try {
      final raw = await _request(
        systemPrompt: outlineSystemPrompt,
        userPrompt: outlinePrompt,
        maxTokens: 4000,
        temperature: 0.72,
      );

      outline = _normalizeOutline(
        ScreenplayOutline.fromJson(_decodeOutlineObject(raw)),
        spec,
      );
    } catch (error) {
      debugPrint(
        '⚠️ [ScreenplayGenerationManager] Outline failed; '
        'using fallback outline. Error: $error',
      );
      outline = _fallbackOutline(spec);
    }

    final now = DateTime.now();

    final screenplay = GeneratedScreenplay(
      id: 'screenplay_${now.microsecondsSinceEpoch}',
      spec: spec,
      outline: outline,
      episodes: List<GeneratedScreenplayEpisode>.generate(
        spec.resolvedSceneCount,
        (index) => GeneratedScreenplayEpisode(
          number: index + 1,
          title: outline.episodes[index].title.trim().isEmpty
              ? 'Episode ${index + 1}'
              : outline.episodes[index].title.trim(),
        ),
      ),
      isGenerating: false,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    _screenplays[screenplay.id] = screenplay;
    await _persist();
    await _syncHistory(screenplay);
    notifyListeners();

    return screenplay;
  }

  Future<void> generatePendingEpisodes(String screenplayId) async {
    await ensureLoaded();

    if (_active.contains(screenplayId)) return;
    if (_screenplays[screenplayId] == null) return;

    _active.add(screenplayId);

    try {
      var current = _screenplays[screenplayId]!;
      await _replace(
        current.copyWith(
          isGenerating: true,
          isCompleted: false,
          updatedAt: DateTime.now(),
        ),
      );

      for (var index = 0; index < current.episodes.length; index++) {
        current = _screenplays[screenplayId]!;
        final status = current.episodes[index].status;

        if (status == ScreenplayEpisodeStatus.completed) continue;
        if (status == ScreenplayEpisodeStatus.failed) break;

        await _generateEpisodeWithRetry(screenplayId, index);
      }

      current = _screenplays[screenplayId]!;
      final complete = current.episodes.isNotEmpty &&
          current.episodes.every(
            (e) => e.status == ScreenplayEpisodeStatus.completed,
          );

      await _replace(
        current.copyWith(
          isGenerating: false,
          isCompleted: complete,
          updatedAt: DateTime.now(),
        ),
      );

      if (complete) {
        unawaited(LocalNotificationService.shared.showScreenplayCompleted(
          current.spec.title,
          current.episodes.length,
        ));
      }
    } finally {
      _active.remove(screenplayId);

      final latest = _screenplays[screenplayId];
      if (latest != null && latest.isGenerating) {
        await _replace(
          latest.copyWith(
            isGenerating: false,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> resumeScreenplay(String screenplayId) =>
      generatePendingEpisodes(screenplayId);

  Future<void> retryEpisode(String screenplayId, int episodeIndex) async {
    await ensureLoaded();

    final screenplay = _screenplays[screenplayId];
    if (screenplay == null ||
        episodeIndex < 0 ||
        episodeIndex >= screenplay.episodes.length) {
      return;
    }

    if (_active.contains(screenplayId)) return;

    final episodes = [...screenplay.episodes];

    for (var i = episodeIndex; i < episodes.length; i++) {
      episodes[i] = episodes[i].copyWith(
        content: '',
        status: ScreenplayEpisodeStatus.pending,
        errorMessage: '',
      );
    }

    await _replace(
      screenplay.copyWith(
        episodes: episodes,
        isGenerating: false,
        isCompleted: false,
        updatedAt: DateTime.now(),
      ),
    );

    await generatePendingEpisodes(screenplayId);
  }

  Future<void> updateEpisodeContent(
    String screenplayId,
    int episodeIndex,
    String content,
  ) async {
    await ensureLoaded();

    final screenplay = _screenplays[screenplayId];
    if (screenplay == null ||
        episodeIndex < 0 ||
        episodeIndex >= screenplay.episodes.length) {
      return;
    }

    final episodes = [...screenplay.episodes];
    episodes[episodeIndex] = episodes[episodeIndex].copyWith(
      content: content,
      status: ScreenplayEpisodeStatus.completed,
      errorMessage: '',
    );

    await _replace(
      screenplay.copyWith(
        episodes: episodes,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> addEpisode({
    required String screenplayId,
    required String requestedTitle,
    required String description,
  }) async {
    await ensureLoaded();

    final instruction = description.trim();
    if (instruction.isEmpty) {
      throw ArgumentError('Episode description is required.');
    }

    if (_active.contains(screenplayId)) {
      throw StateError(
        'Please wait for the current episode generation to finish.',
      );
    }

    final current = _screenplays[screenplayId];
    if (current == null) throw StateError('Screenplay not found.');

    if (!current.isCompleted) {
      throw StateError(
        'Complete all existing episodes before adding another episode.',
      );
    }

    _active.add(screenplayId);

    try {
      final nextNumber = current.episodes.length + 1;
      final title = requestedTitle.trim().isEmpty
          ? 'Episode $nextNumber'
          : requestedTitle.trim();

      final prompt = _addedEpisodePrompt(
        current,
        nextNumber: nextNumber,
        requestedTitle: title,
        instruction: instruction,
      );

      String? prose;
      Object? lastError;

      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          prose = (await _request(
            systemPrompt: _episodeSystemPrompt(current.spec),
            userPrompt: prompt,
            maxTokens: _episodeMaxTokens(current.spec.sceneLength),
            temperature: 0.75,
          ))
              .trim();

          if (prose.isEmpty) throw Exception('Empty episode response');
          break;
        } catch (error) {
          lastError = error;
          debugPrint(
            'Added episode attempt ${attempt + 1}/3 failed: $error',
          );
        }
      }

      if (prose == null || prose.isEmpty) {
        throw Exception(
          'Unable to generate the new episode. ${lastError ?? ''}',
        );
      }

      final newPlan = ScreenplayOutlineEpisode(
        title: title,
        mode: 'Continuation',
        setting: '',
        timeframe: '',
        focusCharacters: const [],
        beat: instruction,
        advances: instruction,
      );

      final updatedOutline = ScreenplayOutline(
        title: current.outline.title,
        premise: current.outline.premise,
        throughline: current.outline.throughline,
        arc: current.outline.arc,
        cost: current.outline.cost,
        climaxEpisode: current.outline.climaxEpisode,
        episodes: [...current.outline.episodes, newPlan],
      );

      final updatedSpec = ScreenplayGenerationSpec(
        title: current.spec.title,
        storyLogline: current.spec.storyLogline,
        synopsis: current.spec.synopsis,
        writtenBy: current.spec.writtenBy,
        language: current.spec.language,
        tone: current.spec.tone,
        genre: current.spec.genre,
        sceneLength: current.spec.sceneLength,
        scriptFormat: current.spec.scriptFormat,
        includedElements: current.spec.includedElements,
        contentRating: current.spec.contentRating,
        settingAndEra: current.spec.settingAndEra,
        sceneCount: current.spec.sceneCount + 1,
        characters: current.spec.characters,
      );

      final updated = GeneratedScreenplay(
        id: current.id,
        spec: updatedSpec,
        outline: updatedOutline,
        episodes: [
          ...current.episodes,
          GeneratedScreenplayEpisode(
            number: nextNumber,
            title: title,
            content: prose,
            status: ScreenplayEpisodeStatus.completed,
          ),
        ],
        isGenerating: false,
        isCompleted: true,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      );

      await _replace(updated);
    } finally {
      _active.remove(screenplayId);
    }
  }

  Future<void> _generateEpisodeWithRetry(
    String screenplayId,
    int index,
  ) async {
    Object? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _generateEpisode(screenplayId, index);
        return;
      } catch (error) {
        lastError = error;
        debugPrint(
          'Episode ${index + 1} attempt ${attempt + 1}/3 failed: $error',
        );

        if (attempt < 2) {
          final latest = _screenplays[screenplayId];
          if (latest != null) {
            final episodes = [...latest.episodes];
            episodes[index] = episodes[index].copyWith(
              status: ScreenplayEpisodeStatus.pending,
              errorMessage: '',
            );

            await _replace(
              latest.copyWith(
                episodes: episodes,
                isGenerating: true,
                updatedAt: DateTime.now(),
              ),
            );
          }
        }
      }
    }

    final latest = _screenplays[screenplayId];
    if (latest != null) {
      final episodes = [...latest.episodes];
      episodes[index] = episodes[index].copyWith(
        status: ScreenplayEpisodeStatus.failed,
        errorMessage: lastError?.toString() ?? 'Generation failed',
      );

      await _replace(
        latest.copyWith(
          episodes: episodes,
          isGenerating: false,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _generateEpisode(String screenplayId, int index) async {
    var screenplay = _screenplays[screenplayId];
    if (screenplay == null) return;

    var episodes = [...screenplay.episodes];
    episodes[index] = episodes[index].copyWith(
      status: ScreenplayEpisodeStatus.generating,
      errorMessage: '',
    );

    screenplay = screenplay.copyWith(
      episodes: episodes,
      isGenerating: true,
      updatedAt: DateTime.now(),
    );

    await _replace(screenplay);

    final content = (await _request(
      systemPrompt: _episodeSystemPrompt(screenplay.spec),
      userPrompt: _episodePrompt(screenplay, index),
      maxTokens: _episodeMaxTokens(screenplay.spec.sceneLength),
      temperature: 0.75,
    ))
        .trim();

    if (content.isEmpty) throw Exception('Empty episode response');

    final latest = _screenplays[screenplayId]!;
    episodes = [...latest.episodes];
    episodes[index] = episodes[index].copyWith(
      content: content,
      status: ScreenplayEpisodeStatus.completed,
      errorMessage: '',
    );

    await _replace(
      latest.copyWith(
        episodes: episodes,
        updatedAt: DateTime.now(),
      ),
    );
  }

  ScreenplayOutline _normalizeOutline(
    ScreenplayOutline parsed,
    ScreenplayGenerationSpec spec,
  ) {
    final episodes = <ScreenplayOutlineEpisode>[];

    for (var index = 0; index < spec.resolvedSceneCount; index++) {
      if (index < parsed.episodes.length) {
        final source = parsed.episodes[index];
        episodes.add(
          ScreenplayOutlineEpisode(
            title: source.title.trim().isEmpty
                ? 'Episode ${index + 1}'
                : source.title.trim(),
            mode: source.mode,
            setting: source.setting,
            timeframe: source.timeframe,
            focusCharacters: source.focusCharacters,
            beat: source.beat.trim().isEmpty
                ? _defaultEpisodeBeat(spec)
                : source.beat.trim(),
            advances: source.advances,
          ),
        );
      } else {
        episodes.add(_defaultEpisodePlan(index + 1, spec));
      }
    }

    final climax =
        parsed.climaxEpisode.clamp(1, spec.resolvedSceneCount).toInt();

    return ScreenplayOutline(
      title: parsed.title.trim().isEmpty ? spec.title : parsed.title.trim(),
      premise: parsed.premise.trim().isEmpty
          ? spec.synopsis
          : parsed.premise.trim(),
      throughline: parsed.throughline.trim().isEmpty
          ? spec.storyLogline
          : parsed.throughline.trim(),
      arc: parsed.arc,
      cost: parsed.cost,
      climaxEpisode: climax,
      episodes: episodes,
    );
  }

  ScreenplayOutline _fallbackOutline(ScreenplayGenerationSpec spec) {
    return ScreenplayOutline(
      title: spec.title,
      premise: spec.synopsis,
      throughline: spec.storyLogline,
      arc: '',
      cost: '',
      climaxEpisode: spec.resolvedSceneCount,
      episodes: List<ScreenplayOutlineEpisode>.generate(
        spec.resolvedSceneCount,
        (index) => _defaultEpisodePlan(index + 1, spec),
      ),
    );
  }

  ScreenplayOutlineEpisode _defaultEpisodePlan(
    int number,
    ScreenplayGenerationSpec spec,
  ) {
    return ScreenplayOutlineEpisode(
      title: 'Episode $number',
      mode: '',
      setting: spec.settingAndEra,
      timeframe: '',
      focusCharacters: const [],
      beat: _defaultEpisodeBeat(spec),
      advances: '',
    );
  }

  String _defaultEpisodeBeat(ScreenplayGenerationSpec spec) {
    return 'Advance ${spec.title} through a distinct dramatic episode with '
        'a clear objective, resistance, turn, consequence, and changed state.';
  }

  String _episodeSystemPrompt(ScreenplayGenerationSpec spec) {
    return '''
You are an elite professional screenwriter and continuity editor.

Write screenplay scenes, not novel chapters.

Protect established continuity:
- names
- relationships
- chronology
- injuries
- deaths
- secrets
- locations
- objects and ownership
- character knowledge
- promises
- emotional development

Every episode must create a meaningful change in objective, knowledge,
relationship, power, stakes, plan, possibility, or audience understanding.

Respect the selected format: ${spec.scriptFormat}.
Write in ${spec.language}.
Return only the finished screenplay episode. No JSON, markdown, analysis,
or commentary.
''';
  }

  String _episodePrompt(GeneratedScreenplay screenplay, int index) {
    final spec = screenplay.spec;
    final outline = screenplay.outline;
    final plan = outline.episodes[index];

    final completedBefore = screenplay.episodes
        .take(index)
        .where(
          (e) =>
              e.status == ScreenplayEpisodeStatus.completed &&
              e.content.trim().isNotEmpty,
        )
        .toList();

    final previousTail = completedBefore.isEmpty
        ? 'No previous episode. This is the opening.'
        : _tailWords(completedBefore.last.content, 160);

    final ledger = completedBefore.isEmpty
        ? 'No previous completed episodes.'
        : completedBefore
            .map((e) => '- Episode ${e.number}: ${e.title}')
            .join('\n');

    final characters = spec.characters.isEmpty
        ? 'None specifically supplied.'
        : spec.characters
            .map((e) => '- ${e.name}: ${e.description}')
            .join('\n');

    final nextBoundary = index + 1 < outline.episodes.length
        ? '''
FUTURE BOUNDARY
The next planned episode is:
Title: ${outline.episodes[index + 1].title}
Beat: ${outline.episodes[index + 1].beat}
Do not consume that episode's main dramatic event too early.
'''
        : '';

    return '''
Write only Episode ${index + 1} of ${screenplay.episodes.length}.

SCREENPLAY
Title: ${spec.title}
Written by: ${spec.writtenBy}
Genre: ${spec.genre}
Tone: ${spec.tone}
Format: ${spec.scriptFormat}
Language: ${spec.language}
Content rating: ${spec.contentRating}
Setting & era: ${spec.settingAndEra}
Required elements: ${spec.includedElements}
Target length: ${spec.wordTargetText}

LOGLINE
${spec.storyLogline}

SYNOPSIS
${spec.synopsis}

PREMISE
${outline.premise}

THROUGHLINE
${outline.throughline}

CHARACTER ARC
${outline.arc}

CHARACTERS
$characters

COMPLETED EPISODE LEDGER
$ledger

CURRENT EPISODE PLAN
Title: ${plan.title}
Mode: ${plan.mode}
Setting: ${plan.setting}
Timeframe: ${plan.timeframe}
Focus characters: ${plan.focusCharacters.join(', ')}
Beat: ${plan.beat}
Must advance: ${plan.advances}

PREVIOUS EPISODE TAIL
$previousTail

$nextBoundary

RULES
- Everything already written is canon.
- Continue cause-and-effect from the previous episode.
- Do not reset relationships or repeat resolved conflicts.
- Preserve character voices and motivations.
- Respect ${spec.scriptFormat} conventions.
- Keep the episode close to ${spec.wordTargetText}.
- Prefer purposeful dialogue/action over filler.
- Do not prematurely resolve the whole screenplay before the planned climax.
- Write entirely in ${spec.language}.
- Output only the finished screenplay episode.
''';
  }

  String _addedEpisodePrompt(
    GeneratedScreenplay screenplay, {
    required int nextNumber,
    required String requestedTitle,
    required String instruction,
  }) {
    final previous = screenplay.episodes.isEmpty
        ? 'No previous episode.'
        : _tailWords(screenplay.episodes.last.content, 160);

    final ledger = screenplay.episodes
        .map((e) => '- Episode ${e.number}: ${e.title}')
        .join('\n');

    return '''
Continue this completed screenplay with one new Episode $nextNumber.

SCREENPLAY
Title: ${screenplay.spec.title}
Genre: ${screenplay.spec.genre}
Tone: ${screenplay.spec.tone}
Format: ${screenplay.spec.scriptFormat}
Language: ${screenplay.spec.language}
Target length: ${screenplay.spec.wordTargetText}

REQUESTED TITLE
$requestedTitle

USER DIRECTION
$instruction

ESTABLISHED EPISODES
$ledger

PREVIOUS EPISODE TAIL
$previous

CONTINUITY
Treat every completed episode as canon.
Extend the existing ending naturally; do not erase or reset it.
Preserve established character knowledge, relationships, events, objects,
injuries, promises, timeline, and emotional development.

Output only the finished screenplay episode in ${screenplay.spec.language}.
''';
  }

  int _episodeMaxTokens(String sceneLength) {
    final value = sceneLength.toLowerCase();
    if (value.contains('short')) return 1000;
    if (value.contains('long')) return 2500;
    return 1700;
  }

  String _tailWords(String text, int count) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= count) return text.trim();
    return words.sublist(words.length - count).join(' ');
  }

  Future<String> _request({
    required String systemPrompt,
    required String userPrompt,
    required int maxTokens,
    required double temperature,
  }) async {
    final result = await EasySeekApiManager.shared.completeBookResponse(
      messages: [
        TogetherAIMessage.system(systemPrompt),
        TogetherAIMessage.user(userPrompt),
      ],
      maxTokens: maxTokens,
      temperature: temperature,
      timeout: const Duration(seconds: 120),
    );

    final cleaned = result?.trim() ?? '';
    if (cleaned.isEmpty) {
      throw Exception('Screenplay generation request failed');
    }
    return cleaned;
  }

  Map<String, dynamic> _decodeOutlineObject(String raw) {
    var cleaned = raw.trim();

    cleaned = cleaned.replaceFirst(
      RegExp(r'^```(?:json)?\s*', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');

    final first = cleaned.indexOf('{');
    final last = cleaned.lastIndexOf('}');
    if (first >= 0 && last > first) {
      cleaned = cleaned.substring(first, last + 1);
    }

    final decoded = jsonDecode(cleaned);
    if (decoded is! Map) {
      throw const FormatException('Invalid screenplay outline JSON');
    }

    final map = Map<String, dynamic>.from(decoded);

    if (map['episodes'] == null && map['scenes'] is List) {
      map['episodes'] = map['scenes'];
    }
    if (map['climaxEpisode'] == null && map['climaxScene'] != null) {
      map['climaxEpisode'] = map['climaxScene'];
    }
    if (map['arc'] == null && map['characterArc'] != null) {
      map['arc'] = map['characterArc'];
    }
    map['cost'] ??= '';

    return map;
  }

  Future<void> _replace(GeneratedScreenplay screenplay) async {
    _screenplays[screenplay.id] = screenplay;
    await _persist();
    await _syncHistory(screenplay);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final ordered = _screenplays.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    await prefs.setString(
      _storageKey,
      jsonEncode(ordered.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _syncHistory(GeneratedScreenplay screenplay) async {
    final prefs = await SharedPreferences.getInstance();

    List<dynamic> entries = [];
    final raw = prefs.getString(_historyKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) entries = List<dynamic>.from(decoded);
      } catch (_) {}
    }

    var existingIndex = -1;
    Map<String, dynamic>? existing;

    for (var i = 0; i < entries.length; i++) {
      final item = entries[i];
      if (item is Map &&
          (item['screenplayId'] ?? '').toString() == screenplay.id) {
        existingIndex = i;
        existing = Map<String, dynamic>.from(item);
        break;
      }
    }

    final completedEpisodes = screenplay.episodes
        .where((e) =>
            e.status == ScreenplayEpisodeStatus.completed &&
            e.content.trim().isNotEmpty)
        .toList();
    final completed = completedEpisodes.length;
    final total = screenplay.episodes.length;

    // History must never contain an empty Screenplay item. If an older draft
    // entry exists, remove it until at least one episode has real generated text.
    if (completedEpisodes.isEmpty) {
      entries.removeWhere(
        (item) =>
            item is Map &&
            (item['screenplayId'] ?? '').toString() == screenplay.id,
      );
      await prefs.setString(_historyKey, jsonEncode(entries));
      return;
    }

    final allText =
        completedEpisodes.map((e) => e.content.trim()).join('\n\n');

    final words = allText.trim().isEmpty
        ? 0
        : allText.trim().split(RegExp(r'\s+')).length;

    final entry = <String, dynamic>{
      ...?existing,
      'screenplayId': screenplay.id,
      'contentType': 'Screenplay',
      'text': allText,
      'title': screenplay.spec.title,
      'category': screenplay.spec.genre,
      'lang': screenplay.spec.language,
      'hasTag': '${screenplay.spec.genre},${screenplay.spec.tone}',
      'status': screenplay.isCompleted
          ? 'completed'
          : screenplay.isGenerating
              ? 'generating'
              : 'incomplete',
      'progress': '$completed/$total',
      'wordCount': words,
      'readMinutes': words == 0 ? 0 : (words / 200).ceil(),
      'date': screenplay.updatedAt.toIso8601String(),
    };

    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.insert(0, entry);
    }

    await prefs.setString(_historyKey, jsonEncode(entries));
  }
}
