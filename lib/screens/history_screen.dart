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
  static const String _foldersKey = 'historyFolders';

  final List<String> _contentTypes = const [
    'All',
    'Story',
    'Book',
    'Screenplay',
    'Poem',
    'Lyrics',
    'Character',
    'Letter',
    'Speech',
    'Article',
  ];

  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  List<String> _folders = <String>[];

  bool _isLoading = true;
  bool _showFavorites = false;
  String _selectedType = 'All';

  final ScrollController _typeScrollController = ScrollController();
  late final List<GlobalKey> _typeChipKeys =
      List.generate(_contentTypes.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    saveVcHistoryRevision.addListener(_handleHistoryChanged);
    _loadAll();
  }

  @override
  void dispose() {
    saveVcHistoryRevision.removeListener(_handleHistoryChanged);
    _typeScrollController.dispose();
    super.dispose();
  }

  void _handleHistoryChanged() {
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final rawEntries = prefs.getString(_entriesKey);
    final rawFolders = prefs.getString(_foldersKey);

    final loadedEntries = <Map<String, dynamic>>[];
    final loadedFolders = <String>[];

    if (rawEntries != null && rawEntries.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawEntries);
        if (decoded is List) {
          for (int index = 0; index < decoded.length; index++) {
            final item = decoded[index];
            if (item is Map) {
              final map = Map<String, dynamic>.from(item);
              map['_storageIndex'] = index;
              loadedEntries.add(map);
            }
          }
        }
      } catch (_) {}
    }

    if (rawFolders != null && rawFolders.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawFolders);
        if (decoded is List) {
          loadedFolders.addAll(
            decoded
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty),
          );
        }
      } catch (_) {}
    }

    loadedEntries.sort((a, b) {
      final ai = (a['_storageIndex'] as int?) ?? 0;
      final bi = (b['_storageIndex'] as int?) ?? 0;
      return bi.compareTo(ai);
    });

    if (!mounted) return;

    setState(() {
      _entries = loadedEntries;
      _folders = loadedFolders;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _rootEntries {
    return _filteredEntries(folder: '');
  }

  void _selectContentType(int index) {
    setState(() {
      _selectedType = _contentTypes[index];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chipContext = _typeChipKeys[index].currentContext;
      if (chipContext == null) return;

      Scrollable.ensureVisible(
        chipContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  List<Map<String, dynamic>> _filteredEntries({required String folder}) {
    return _entries.where((entry) {
      final entryFolder = (entry['folder'] ?? '').toString().trim();
      if (entryFolder != folder) return false;

      if (_showFavorites && entry['isFav'] != true) {
        return false;
      }

      if (_selectedType != 'All') {
        final type = (entry['contentType'] ?? 'Story').toString().trim();
        if (type.toLowerCase() != _selectedType.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _readOriginalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);

    if (raw == null || raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}

    return <Map<String, dynamic>>[];
  }

  Future<void> _writeOriginalEntries(
    List<Map<String, dynamic>> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, jsonEncode(entries));
    saveVcHistoryRevision.value++;
  }

  Future<void> _openEntry(Map<String, dynamic> entry) async {
    final storageIndex = (entry['_storageIndex'] as int?) ?? -1;
    if (storageIndex < 0) return;

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
          currentIndex: storageIndex,
          shouldNeedToCall: false,
          isFromSave: true,
          isFromFav: entry['isFav'] == true,
        ),
      ),
    );

    await _loadAll();
  }

  Future<void> _createFolder() async {
    String folderName = '';

    final value = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Folder'),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Folder name',
            ),
            onChanged: (value) => folderName = value,
            onSubmitted: (value) {
              final name = value.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop(name);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = folderName.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    final name = value?.trim();
    if (name == null || name.isEmpty) return;

    if (_folders.any((folder) => folder.toLowerCase() == name.toLowerCase())) {
      _showMessage('A folder with this name already exists.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final updated = <String>[..._folders, name];
    await prefs.setString(_foldersKey, jsonEncode(updated));

    if (!mounted) return;
    setState(() => _folders = updated);
  }

  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: const Text(
            'Do you want to remove this item from your history?',
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

    final storageIndex = (entry['_storageIndex'] as int?) ?? -1;
    final original = await _readOriginalEntries();

    if (storageIndex < 0 || storageIndex >= original.length) return;

    original.removeAt(storageIndex);
    await _writeOriginalEntries(original);
    await _loadAll();
  }

  Future<void> _moveEntryToFolder(
    Map<String, dynamic> entry,
  ) async {
    if (_folders.isEmpty) {
      _showMessage('Create a folder first.');
      return;
    }

    final selectedFolder = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Text(
                  'Select Folder',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ..._folders.map(
                (folder) => ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(folder),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selectedFolder == null) return;

    final storageIndex = (entry['_storageIndex'] as int?) ?? -1;
    final original = await _readOriginalEntries();

    if (storageIndex < 0 || storageIndex >= original.length) return;

    original[storageIndex]['folder'] = selectedFolder;
    await _writeOriginalEntries(original);
    await _loadAll();
  }

  Future<void> _removeFromFolder(
    Map<String, dynamic> entry,
  ) async {
    final storageIndex = (entry['_storageIndex'] as int?) ?? -1;
    final original = await _readOriginalEntries();

    if (storageIndex < 0 || storageIndex >= original.length) return;

    original[storageIndex]['folder'] = '';
    await _writeOriginalEntries(original);
    await _loadAll();
  }

  Future<void> _showItemOptions(
    Map<String, dynamic> entry, {
    required bool insideFolder,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark =
            Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetColor =
            isDark ? const Color(0xFF242424) : const Color(0xFFF7F7F7);

        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    'Option',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Center(
                    child: Text(
                      'Delete Item',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop('delete'),
                ),
                if (insideFolder)
                  ListTile(
                    title: const Center(
                      child: Text('Remove from folder'),
                    ),
                    onTap: () =>
                        Navigator.of(sheetContext).pop('remove'),
                  )
                else
                  ListTile(
                    title: const Center(
                      child: Text('Move to folder'),
                    ),
                    onTap: () =>
                        Navigator.of(sheetContext).pop('move'),
                  ),
                const Divider(height: 1),
                ListTile(
                  title: const Center(
                    child: Text('Cancel'),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop('cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == 'delete') {
      await _deleteEntry(entry);
    } else if (action == 'move') {
      await _moveEntryToFolder(entry);
    } else if (action == 'remove') {
      await _removeFromFolder(entry);
    }
  }

  Future<void> _openFolder(String folder) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HistoryFolderScreen(
          folderName: folder,
          loadEntries: () async {
            await _loadAll();
            return _filteredEntries(folder: folder);
          },
          openEntry: _openEntry,
          showOptions: (entry) => _showItemOptions(
            entry,
            insideFolder: true,
          ),
        ),
      ),
    );

    await _loadAll();
  }

  String _previewFor(Map<String, dynamic> entry) {
    final text = (entry['text'] ?? '').toString().trim();
    if (text.isEmpty) return 'No text';
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF121212) : const Color(0xFFF4F4F4);
    final primary =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: primary),
              )
            : RefreshIndicator(
                color: primary,
                onRefresh: _loadAll,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(context),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFolderStrip(context),
                    ),
                    SliverToBoxAdapter(
                      child: _buildHistoryFavoriteTabs(context),
                    ),
                    SliverToBoxAdapter(
                      child: _buildTypeFilter(context),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        10,
                        14,
                        110,
                      ),
                      sliver: _rootEntries.isEmpty
                          ? SliverToBoxAdapter(
                              child: _buildEmptyState(context),
                            )
                          : SliverList.separated(
                              itemCount: _rootEntries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final entry = _rootEntries[index];
                                return _HistoryCard(
                                  entry: entry,
                                  preview: _previewFor(entry),
                                  onTap: () => _openEntry(entry),
                                  onOptions: () => _showItemOptions(
                                    entry,
                                    insideFolder: false,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Center(
        child: Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildFolderStrip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final textColor =
        isDark ? Colors.white : const Color(0xFF202020);

    return SizedBox(
      height: 76,
      child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          _FolderButton(
            label: '',
            icon: Icons.create_new_folder_rounded,
            color: primary,
            onTap: _createFolder,
          ),
          ..._folders.map(
            (folder) => _FolderButton(
              label: folder,
              icon: Icons.folder_rounded,
              color: primary,
              textColor: textColor,
              onTap: () => _openFolder(folder),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryFavoriteTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final containerColor =
        isDark ? const Color(0xFF1D1D1F) : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _TopTabButton(
              title: 'History',
              selected: !_showFavorites,
              selectedColor: primary,
              onTap: () => setState(() => _showFavorites = false),
            ),
            _TopTabButton(
              title: 'Favourites',
              selected: _showFavorites,
              selectedColor: primary,
              onTap: () => setState(() => _showFavorites = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final chipColor =
        isDark ? const Color(0xFF1D1D1F) : Colors.white;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        controller: _typeScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _contentTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final type = _contentTypes[index];
          final selected = type == _selectedType;

          return GestureDetector(
            onTap: () => _selectContentType(index),
            child: Container(
              key: _typeChipKeys[index],
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: selected ? primary : chipColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? const Color(0xFF9A9A9F)
        : const Color(0xFF8E8E93);

    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          Icon(
            _showFavorites
                ? Icons.favorite_border_rounded
                : Icons.history_rounded,
            size: 54,
            color: muted.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),
          Text(
            _showFavorites
                ? 'No Favourite Items'
                : 'No History Yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryFolderScreen extends StatefulWidget {
  const _HistoryFolderScreen({
    required this.folderName,
    required this.loadEntries,
    required this.openEntry,
    required this.showOptions,
  });

  final String folderName;
  final Future<List<Map<String, dynamic>>> Function() loadEntries;
  final Future<void> Function(Map<String, dynamic>) openEntry;
  final Future<void> Function(Map<String, dynamic>) showOptions;

  @override
  State<_HistoryFolderScreen> createState() =>
      _HistoryFolderScreenState();
}

class _HistoryFolderScreenState extends State<_HistoryFolderScreen> {
  List<Map<String, dynamic>> _entries = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final values = await widget.loadEntries();
    if (!mounted) return;

    setState(() {
      _entries = values;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _visibleEntries {
    if (!_showFavorites) return _entries;
    return _entries.where((e) => e['isFav'] == true).toList();
  }

  String _preview(Map<String, dynamic> entry) {
    final text = (entry['text'] ?? '').toString().trim();
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF121212) : const Color(0xFFF4F4F4);
    final primary =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 62,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.folderName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1D1D1F)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _TopTabButton(
                      title: 'History',
                      selected: !_showFavorites,
                      selectedColor: primary,
                      onTap: () =>
                          setState(() => _showFavorites = false),
                    ),
                    _TopTabButton(
                      title: 'Favourites',
                      selected: _showFavorites,
                      selectedColor: primary,
                      onTap: () =>
                          setState(() => _showFavorites = true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                  : RefreshIndicator(
                      color: primary,
                      onRefresh: _reload,
                      child: _visibleEntries.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text('No items in this folder'),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                4,
                                14,
                                30,
                              ),
                              itemCount: _visibleEntries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final entry = _visibleEntries[index];
                                return _HistoryCard(
                                  entry: entry,
                                  preview: _preview(entry),
                                  onTap: () async {
                                    await widget.openEntry(entry);
                                    await _reload();
                                  },
                                  onOptions: () async {
                                    await widget.showOptions(entry);
                                    await _reload();
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderButton extends StatelessWidget {
  const _FolderButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.textColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 44,
                color: color,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    color: textColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.title,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.preview,
    required this.onTap,
    required this.onOptions,
  });

  final Map<String, dynamic> entry;
  final String preview;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1D1D1F) : Colors.white;
    final muted =
        isDark ? const Color(0xFF9A9A9F) : const Color(0xFF8E8E93);

    final title =
        (entry['title'] ?? 'AI Story').toString().trim();
    final date = (entry['date'] ?? '').toString().trim();

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 11, 6, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
                onPressed: onOptions,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
