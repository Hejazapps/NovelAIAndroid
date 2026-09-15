import 'package:flutter/material.dart';

import 'screenplay_generation_manager.dart';
import 'screenplay_models.dart';
import 'save_vc.dart';
import 'subscription_screen.dart';

class ScreenplayDetailScreen extends StatefulWidget {
  const ScreenplayDetailScreen({
    super.key,
    required this.screenplayId,
  });

  final String screenplayId;

  @override
  State<ScreenplayDetailScreen> createState() => _ScreenplayDetailScreenState();
}

class _ScreenplayDetailScreenState extends State<ScreenplayDetailScreen> {
  final ScreenplayGenerationManager _manager = ScreenplayGenerationManager.shared;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_refresh);
    _manager.ensureLoaded();
  }

  @override
  void dispose() {
    _manager.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<bool> _confirmLeaveIfGenerating() async {
    final screenplay = _manager.screenplayById(widget.screenplayId);
    if (screenplay == null || !screenplay.isGenerating) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Screenplay is still generating'),
        content: const Text(
          'You can leave this screen. Generation will continue while the app '
          'remains running. If generation is interrupted, you can resume the '
          'screenplay later from History.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave'),
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

  Future<void> _openEpisode(int index, {bool replace = false}) async {
    final screenplay = _manager.screenplayById(widget.screenplayId);
    if (screenplay == null || index < 0 || index >= screenplay.episodes.length) return;

    final episode = screenplay.episodes[index];
    if (episode.status != ScreenplayEpisodeStatus.completed) return;

    final route = MaterialPageRoute(
      builder: (_) => SaveVc(
        textToGive: episode.content,
        mainTitle: episode.title,
        selectedLanguage: screenplay.spec.language,
        genre: screenplay.spec.genre,
        hasTag: '${screenplay.spec.genre},${screenplay.spec.tone}',
        contentType: 'Screenplay',
        shouldNeedToCall: false,
        isFromSave: false,
        isFromFav: false,
        bookId: screenplay.id,
        bookChapterIndex: index,
        bookChapterNumber: index + 1,
        bookChapterCount: screenplay.episodes.length,
        hasBookPrevious: index > 0 &&
            screenplay.episodes[index - 1].status == ScreenplayEpisodeStatus.completed,
        hasBookNext: index < screenplay.episodes.length - 1 &&
            screenplay.episodes[index + 1].status == ScreenplayEpisodeStatus.completed,
        onBookTextChanged: (text) async {
          await _manager.updateEpisodeContent(screenplay.id, index, text);
        },
        onBookPrevious: index > 0
            ? () async {
                if (!mounted) return;
                await _openEpisode(index - 1, replace: true);
              }
            : null,
        onBookNext: index < screenplay.episodes.length - 1
            ? () async {
                if (!mounted) return;
                await _openEpisode(index + 1, replace: true);
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

  Future<void> _showAddEpisodeSheet() async {
    final screenplay = _manager.screenplayById(widget.screenplayId);
    if (screenplay == null) return;

    // Adding an extra episode is a PRO feature.
    if (!isSubscription) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SubscriptionScreen(),
        ),
      );
      return;
    }

    if (!screenplay.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please finish all current episodes before adding a new episode.',
          ),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddEpisodeSheet(),
    );

    if (!mounted || result == null) return;

    try {
      await _manager.addEpisode(
        screenplayId: widget.screenplayId,
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

  Future<void> _openFullScreenplay() async {
    final screenplay = _manager.screenplayById(widget.screenplayId);
    if (screenplay == null) return;

    final completedEpisodes = screenplay.episodes
        .where((episode) => episode.status == ScreenplayEpisodeStatus.completed)
        .toList();

    if (completedEpisodes.isEmpty) return;

    final buffer = StringBuffer();

    for (var i = 0; i < completedEpisodes.length; i++) {
      final episode = completedEpisodes[i];

      if (i > 0) {
        buffer.writeln();
        buffer.writeln();
      }

      buffer.writeln(episode.title);
      buffer.writeln();
      buffer.write(episode.content.trim());
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveVc(
          textToGive: buffer.toString(),
          mainTitle: screenplay.spec.title,
          selectedLanguage: screenplay.spec.language,
          genre: screenplay.spec.genre,
          hasTag: '${screenplay.spec.genre},${screenplay.spec.tone}',
          contentType: 'Screenplay',
          shouldNeedToCall: false,
          isFromSave: false,
          isFromFav: false,
          bookId: screenplay.id,
          isBookFullView: true,
        ),
      ),
    );
  }

  String _episodeStatusText(GeneratedScreenplayEpisode episode) {
    switch (episode.status) {
      case ScreenplayEpisodeStatus.completed:
        return 'Episode ${episode.number} • ${episode.wordCount} words • '
            '${episode.estimatedReadMinutes} min read';
      case ScreenplayEpisodeStatus.generating:
        return 'Episode ${episode.number} • Generating...';
      case ScreenplayEpisodeStatus.failed:
        return 'Episode ${episode.number} • Failed';
      case ScreenplayEpisodeStatus.pending:
        return 'Episode ${episode.number} • Waiting';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenplay = _manager.screenplayById(widget.screenplayId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF160D26) : const Color(0xFFF7F7F8);
    final surface = isDark ? const Color(0xFF21152F) : Colors.white;
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

    if (screenplay == null) {
      return Scaffold(
        backgroundColor: background,
        body: const SafeArea(
          child: Center(child: Text('Screenplay not found')),
        ),
      );
    }

    final completed = screenplay.completedEpisodeCount;
    final total = screenplay.episodes.length;
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
                        screenplay.spec.title,
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
                            screenplay.spec.title,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (screenplay.spec.writtenBy.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('by ${screenplay.spec.writtenBy}'),
                          ],
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(20),
                            color: accent,
                          ),
                          const SizedBox(height: 8),
                          Text('$completed of $total episodes generated'),
                          if (screenplay.totalWordCount > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${screenplay.totalWordCount} words • '
                              '${screenplay.estimatedReadMinutes} min read',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (screenplay.isGenerating) ...[
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
                                const Text('Generating screenplay...'),
                              ],
                            ),
                          ],
                          if (completed > 0) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _openFullScreenplay,
                                icon: const Icon(Icons.movie_creation_outlined),
                                label: Text(
                                  completed == total
                                      ? 'Read Full Screenplay'
                                      : 'Read $completed Available Episodes',
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
                                  screenplay.isCompleted ? _showAddEpisodeSheet : null,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Episode'),
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
                    ...List.generate(screenplay.episodes.length, (index) {
                      final episode = screenplay.episodes[index];

                      final IconData icon;
                      final Color iconColor;

                      switch (episode.status) {
                        case ScreenplayEpisodeStatus.completed:
                          icon = Icons.check_circle_rounded;
                          iconColor = const Color(0xFF57D45B);
                          break;
                        case ScreenplayEpisodeStatus.generating:
                          icon = Icons.autorenew_rounded;
                          iconColor = accent;
                          break;
                        case ScreenplayEpisodeStatus.failed:
                          icon = Icons.error_outline_rounded;
                          iconColor = Colors.red;
                          break;
                        case ScreenplayEpisodeStatus.pending:
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
                                episode.status == ScreenplayEpisodeStatus.completed
                                    ? () => _openEpisode(index)
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
                                          episode.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _episodeStatusText(episode),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: episode.status ==
                                                    ScreenplayEpisodeStatus.failed
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (episode.status ==
                                          ScreenplayEpisodeStatus.failed)
                                    TextButton(
                                      onPressed: screenplay.isGenerating
                                          ? null
                                          : () async {
                                              try {
                                                await _manager.retryEpisode(
                                                  screenplay.id,
                                                  index,
                                                );
                                              } catch (_) {}
                                            },
                                      child: const Text('Retry'),
                                    )
                                  else if (episode.status ==
                                      ScreenplayEpisodeStatus.completed)
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
        bottomNavigationBar: screenplay.isCompleted || screenplay.isGenerating
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
                          await _manager.resumeScreenplay(screenplay.id);
                        } catch (_) {}
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Resume Generation'),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}


class _AddEpisodeSheet extends StatefulWidget {
  const _AddEpisodeSheet();

  @override
  State<_AddEpisodeSheet> createState() => _AddEpisodeSheetState();
}

class _AddEpisodeSheetState extends State<_AddEpisodeSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generate() {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe what should happen in this episode.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'description': description,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF21152F) : Colors.white;
    final fieldColor =
        isDark ? const Color(0xFF2B1B3D) : const Color(0xFFF7F7F8);
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Episode',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _descriptionFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'Episode title (optional)',
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
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  minLines: 4,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'What should happen in this episode?',
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
                    onPressed: _generate,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Generate',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
