import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'save_vc.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const String _entriesKey = 'textDateEntries';

  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    saveVcHistoryRevision.addListener(_handleHistoryChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    saveVcHistoryRevision.removeListener(_handleHistoryChanged);
    super.dispose();
  }

  void _handleHistoryChanged() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);

    List<Map<String, dynamic>> loaded = <Map<String, dynamic>>[];

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          loaded = decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      } catch (_) {}
    }

    loaded = loaded.reversed.toList();

    if (!mounted) return;
    setState(() {
      _entries = loaded;
      _isLoading = false;
    });
  }

  Future<void> _openEntry(int visibleIndex) async {
    final entry = _entries[visibleIndex];
    final originalIndex = _entries.length - 1 - visibleIndex;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveVc(
          textToGive: (entry['text'] ?? '').toString(),
          mainTitle: (entry['title'] ?? 'AI Story').toString(),
          selectedLanguage: (entry['lang'] ?? 'English').toString(),
          genre: (entry['category'] ?? '').toString(),
          hasTag: (entry['hasTag'] ?? '').toString(),
          createdDate: (entry['date'] ?? '').toString(),
          contentType: (entry['contentType'] ?? 'Story').toString(),
          themeId: (entry['themeId'] ?? '').toString(),
          currentIndex: originalIndex,
          shouldNeedToCall: false,
          isFromSave: true,
          isFromFav: entry['isFav'] == true,
        ),
      ),
    );

    await _loadHistory();
  }

  Future<void> _deleteEntry(int visibleIndex) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Story?'),
          content: const Text(
            'Do you want to remove this story from your history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final original = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final originalIndex = original.length - 1 - visibleIndex;
      if (originalIndex < 0 || originalIndex >= original.length) return;

      original.removeAt(originalIndex);
      await prefs.setString(_entriesKey, jsonEncode(original));
      saveVcHistoryRevision.value++;
      await _loadHistory();
    } catch (_) {}
  }

  String _previewFor(Map<String, dynamic> entry) {
    final text = (entry['text'] ?? '').toString().trim();
    if (text.isEmpty) return 'No story text';
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _typeFor(Map<String, dynamic> entry) {
    final value = (entry['contentType'] ?? 'Story').toString().trim();
    return value.isEmpty ? 'Story' : value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F8F8);
    final cardColor = isDark ? const Color(0xFF1D1D1F) : Colors.white;
    final primary =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final secondary =
        isDark ? const Color(0xFFB9B9BE) : const Color(0xFF71717A);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          color: primary,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _entries.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.23,
                        ),
                        Icon(
                          Icons.history_rounded,
                          size: 64,
                          color: secondary.withValues(alpha: 0.55),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'No History Yet',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stories you save will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                      itemCount: _entries.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Text(
                              'History',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          );
                        }

                        final visibleIndex = index - 1;
                        final entry = _entries[visibleIndex];
                        final title =
                            (entry['title'] ?? 'AI Story').toString();
                        final date = (entry['date'] ?? '').toString();
                        final category =
                            (entry['category'] ?? '').toString();
                        final isFavorite = entry['isFav'] == true;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _openEntry(visibleIndex),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 15, 10, 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.auto_stories_rounded,
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              if (isFavorite)
                                                Icon(
                                                  Icons.favorite_rounded,
                                                  size: 17,
                                                  color: primary,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            _previewFor(entry),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              height: 1.35,
                                              color: secondary,
                                            ),
                                          ),
                                          const SizedBox(height: 9),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              _HistoryChip(
                                                text: _typeFor(entry),
                                                color: primary,
                                              ),
                                              if (category.trim().isNotEmpty)
                                                _HistoryChip(
                                                  text: category,
                                                  color: primary,
                                                ),
                                              if (date.trim().isNotEmpty)
                                                Text(
                                                  date,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: secondary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      tooltip: '',
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _deleteEntry(visibleIndex);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 10),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
