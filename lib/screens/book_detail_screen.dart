import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_l10n.dart';

import 'book_generation_manager.dart';
import 'book_models.dart';
import 'save_vc.dart';
import 'subscription_screen.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookGenerationManager _manager = BookGenerationManager.shared;
  final Map<int, int> _chapterProgress = <int, int>{};
  Timer? _progressTimer;


  @override
  void initState() {
    super.initState();
    _manager.addListener(_refresh);
    _manager.ensureLoaded();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final book = _manager.bookById(widget.bookId);
      if (book == null) return;

      var changed = false;
      for (var i = 0; i < book.chapters.length; i++) {
        final chapter = book.chapters[i];
        if (chapter.status == BookChapterStatus.generating) {
          final current = _chapterProgress[i] ?? 4;
          final next = current >= 95 ? 95 : current + (current < 55 ? 3 : 1);
          if (next != current) {
            _chapterProgress[i] = next;
            changed = true;
          }
        } else if (chapter.status == BookChapterStatus.completed) {
          if (_chapterProgress[i] != 100) {
            _chapterProgress[i] = 100;
            changed = true;
          }
        } else if (_chapterProgress.remove(i) != null) {
          changed = true;
        }
      }

      if (changed) setState(() {});
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _manager.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<bool> _confirmLeaveIfGenerating() async {
    final book = _manager.bookById(widget.bookId);
    if (book == null || !book.isGenerating) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppL10n.tr('Book is still generating')),
        content: Text(
          AppL10n.tr(
            'You can leave this screen. Generation will continue while the app remains running. If generation is interrupted, you can resume the book later from History.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppL10n.tr('Stay')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppL10n.tr('Leave')),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _handleBack() async {
    final canLeave = await _confirmLeaveIfGenerating();
    if (!canLeave || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _openChapter(int index, {bool replace = false}) async {
    final book = _manager.bookById(widget.bookId);
    if (book == null || index < 0 || index >= book.chapters.length) return;

    final chapter = book.chapters[index];
    if (chapter.status != BookChapterStatus.completed) return;

    final route = MaterialPageRoute(
      builder: (_) => SaveVc(
        textToGive: chapter.content,
        mainTitle: chapter.title,
        selectedLanguage: book.spec.language,
        genre: book.spec.category,
        hasTag: '${book.spec.category},${book.spec.tone}',
        contentType: 'Book',
        shouldNeedToCall: false,
        isFromSave: false,
        isFromFav: false,
        bookId: book.id,
        bookChapterIndex: index,
        bookChapterNumber: index + 1,
        bookChapterCount: book.chapters.length,
        hasBookPrevious: index > 0 &&
            book.chapters[index - 1].status == BookChapterStatus.completed,
        hasBookNext: index < book.chapters.length - 1 &&
            book.chapters[index + 1].status == BookChapterStatus.completed,
        onBookTextChanged: (text) async {
          await _manager.updateChapterContent(book.id, index, text);
        },
        onBookPrevious: index > 0
            ? () async {
                if (!mounted) return;
                await _openChapter(index - 1, replace: true);
              }
            : null,
        onBookNext: index < book.chapters.length - 1
            ? () async {
                if (!mounted) return;
                await _openChapter(index + 1, replace: true);
              }
            : null,
      ),
    );

    if (replace) {
      await Navigator.of(context).pushReplacement(route);
    } else {
      await Navigator.of(context).push(route);
    }
  }

  Future<void> _showAddChapterSheet() async {
    final book = _manager.bookById(widget.bookId);
    if (book == null) return;

    // Adding extra chapters is a PRO feature.
    if (!isSubscription) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SubscriptionScreen(),
        ),
      );
      return;
    }

    if (book.isGenerating) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppL10n.tr('Please wait for the current chapter generation to finish.'),
          ),
        ),
      );
      return;
    }

    String chapterTitle = '';
    String chapterDescription = '';

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark =
            Theme.of(sheetContext).brightness == Brightness.dark;
        final background =
            isDark ? const Color(0xFF21152F) : Colors.white;
        final fieldColor =
            isDark ? const Color(0xFF2B1B3D) : const Color(0xFFF7F7F8);
        final accent =
            isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: BoxDecoration(
              color: background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Chapter',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => chapterTitle = value,
                  decoration: InputDecoration(
                    hintText: AppL10n.tr('Chapter title (optional)'),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  minLines: 4,
                  maxLines: 6,
                  onChanged: (value) => chapterDescription = value,
                  decoration: InputDecoration(
                    hintText: AppL10n.tr('What should happen in this chapter?'),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      final description = chapterDescription.trim();

                      if (description.isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppL10n.tr('Please describe what should happen in this chapter.'),
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.of(sheetContext).pop({
                        'title': chapterTitle.trim(),
                        'description': description,
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      AppL10n.tr('Generate'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null || !mounted) return;

    try {
      await _manager.addChapter(
        bookId: widget.bookId,
        requestedTitle: result['title'] ?? '',
        description: result['description'] ?? '',
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _openFullBook() async {
    final book = _manager.bookById(widget.bookId);
    if (book == null) return;

    final completedChapters = book.chapters
        .where((chapter) => chapter.status == BookChapterStatus.completed)
        .toList();

    if (completedChapters.isEmpty) return;

    final buffer = StringBuffer();

    for (var i = 0; i < completedChapters.length; i++) {
      final chapter = completedChapters[i];

      if (i > 0) {
        buffer.writeln();
        buffer.writeln();
      }

      buffer.writeln(chapter.title);
      buffer.writeln();
      buffer.write(chapter.content.trim());
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveVc(
          textToGive: buffer.toString(),
          mainTitle: book.spec.title,
          selectedLanguage: book.spec.language,
          genre: book.spec.category,
          hasTag: '${book.spec.category},${book.spec.tone}',
          contentType: 'Book',
          shouldNeedToCall: false,
          isFromSave: false,
          isFromFav: false,
          bookId: book.id,
          isBookFullView: true,
        ),
      ),
    );
  }

  String _chapterStatusText(GeneratedBookChapter chapter, int index) {
    final chapterLabel = AppL10n.tr('Chapter');
    switch (chapter.status) {
      case BookChapterStatus.completed:
        return '$chapterLabel ${chapter.number} • ${chapter.wordCount} ${AppL10n.tr('words')} • '
            '${chapter.estimatedReadMinutes} ${AppL10n.tr('min read')}';
      case BookChapterStatus.generating:
        final percent = _chapterProgress[index] ?? 4;
        return '$chapterLabel ${chapter.number} • ${AppL10n.tr('Generating...')} ~$percent%';
      case BookChapterStatus.failed:
        return '$chapterLabel ${chapter.number} • ${AppL10n.tr('Failed')}';
      case BookChapterStatus.pending:
        return '$chapterLabel ${chapter.number} • ${AppL10n.tr('Waiting')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = _manager.bookById(widget.bookId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF160D26) : const Color(0xFFF7F7F8);
    final surface = isDark ? const Color(0xFF21152F) : Colors.white;
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

    if (book == null) {
      return Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(child: Text(AppL10n.tr('Book not found'))),
        ),
      );
    }

    final completed = book.completedChapterCount;
    final total = book.chapters.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        book.spec.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.spec.title,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (book.spec.author.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('${AppL10n.tr('by')} ${book.spec.author}'),
                          ],
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(20),
                            color: accent,
                          ),
                          const SizedBox(height: 8),
                          Text('$completed ${AppL10n.tr('of')} $total ${AppL10n.tr('chapters generated')}'),
                          if (book.totalWordCount > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${book.totalWordCount} ${AppL10n.tr('words')} • '
                              '${book.estimatedReadMinutes} ${AppL10n.tr('min read')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (book.isGenerating) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(AppL10n.tr('Generating book...')),
                              ],
                            ),
                          ],
                          if (completed > 0) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _openFullBook,
                                icon: const Icon(Icons.menu_book_rounded),
                                label: Text(
                                  completed == total
                                      ? AppL10n.tr('Read Full Book')
                                      : '${AppL10n.tr('Read')} $completed ${AppL10n.tr('Available Chapters')}',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accent,
                                  side: BorderSide(color: accent),
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  book.isCompleted ? _showAddChapterSheet : null,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(AppL10n.tr('Add Chapter')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accent,
                                side: BorderSide(color: accent),
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(book.chapters.length, (index) {
                      final chapter = book.chapters[index];

                      final IconData icon;
                      final Color iconColor;

                      switch (chapter.status) {
                        case BookChapterStatus.completed:
                          icon = Icons.check_circle_rounded;
                          iconColor = const Color(0xFF57D45B);
                          break;
                        case BookChapterStatus.generating:
                          icon = Icons.autorenew_rounded;
                          iconColor = accent;
                          break;
                        case BookChapterStatus.failed:
                          icon = Icons.error_outline_rounded;
                          iconColor = Colors.red;
                          break;
                        case BookChapterStatus.pending:
                          icon = Icons.radio_button_unchecked_rounded;
                          iconColor = Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant;
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap:
                                chapter.status == BookChapterStatus.completed
                                    ? () => _openChapter(index)
                                    : null,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 12, 10, 12),
                              child: Row(
                                children: [
                                  Icon(icon, color: iconColor, size: 21),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chapter.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _chapterStatusText(chapter, index),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: chapter.status ==
                                                    BookChapterStatus.failed
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                        if (chapter.status ==
                                            BookChapterStatus.generating) ...[
                                          const SizedBox(height: 7),
                                          LinearProgressIndicator(
                                            value: (_chapterProgress[index] ?? 4) / 100,
                                            minHeight: 4,
                                            borderRadius: BorderRadius.circular(20),
                                            color: accent,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (chapter.status ==
                                          BookChapterStatus.failed)
                                    TextButton(
                                      onPressed: book.isGenerating
                                          ? null
                                          : () async {
                                              try {
                                                await _manager.retryChapter(
                                                  book.id,
                                                  index,
                                                );
                                              } catch (_) {}
                                            },
                                      child: Text(AppL10n.tr('Retry')),
                                    )
                                  else if (chapter.status ==
                                      BookChapterStatus.completed)
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 21,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: book.isCompleted || book.isGenerating
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () async {
                        try {
                          await _manager.resumeBook(book.id);
                        } catch (_) {}
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(AppL10n.tr('Resume Generation')),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
