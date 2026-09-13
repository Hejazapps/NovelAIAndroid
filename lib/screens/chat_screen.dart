import 'package:flutter/material.dart';

import '../services/realtime_db_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _lightAccent = Color(0xFFFF6435);
  // Same dark accent pattern used by the Home "Try now" buttons.
  static const Color _darkAccent = Color(0xFF9B2CF2);

  final RealtimeDBManager _dbManager = RealtimeDBManager();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _genreScrollController = ScrollController();

  List<StoryTellerItem> _storytellers = const [];
  bool _loadingStorytellers = true;
  String? _storytellerError;

  int _currentStorytellerIndex = -1;
  int _currentGenreIndex = 0;
  int _lengthIndex = 0;
  String _language = 'English';

  final List<_GenreItem> _genres = const [
    _GenreItem(name: 'Adventure', asset: 'assets/genres/adventure.png'),
    _GenreItem(name: 'Fairy Tale', asset: 'assets/genres/fairy_tale.png'),
    _GenreItem(name: 'Historical', asset: 'assets/genres/historical.png'),
    _GenreItem(name: 'Comedy', asset: 'assets/genres/comedy.png'),
    _GenreItem(name: 'Sad', asset: 'assets/genres/sad.png'),
    _GenreItem(name: 'Non-Fiction', asset: 'assets/genres/non_fiction.png'),
    _GenreItem(name: 'Drama', asset: 'assets/genres/drama.png'),
    _GenreItem(name: 'Fantasy', asset: 'assets/genres/fantasy.png'),
    _GenreItem(name: 'Mystery', asset: 'assets/genres/mystery.png'),
    _GenreItem(name: 'Thriller', asset: 'assets/genres/thriller.png'),
    _GenreItem(name: 'Horror', asset: 'assets/genres/horror.png'),
    _GenreItem(name: 'Science Fiction', asset: 'assets/genres/science_fiction.png'),
    _GenreItem(name: 'Romance', asset: 'assets/genres/romance.png'),
    _GenreItem(name: 'Mythology', asset: 'assets/genres/mythology.png'),
    _GenreItem(name: 'Superhero', asset: 'assets/genres/superhero.png'),
    _GenreItem(name: 'Historical Fiction', asset: 'assets/genres/historical_fiction.png'),
    _GenreItem(name: 'Crime', asset: 'assets/genres/crime.png'),
  ];

  static const List<String> _languages = [
    'English', 'Bengali', 'Arabic', 'Chinese Simplified',
    'Chinese Traditional', 'Czech', 'Danish', 'Dutch', 'Finnish', 'French',
    'German', 'Greek', 'Hebrew', 'Hindi', 'Hungarian', 'Indonesian',
    'Italian', 'Japanese', 'Korean', 'Malay', 'Polish', 'Portuguese',
    'Romanian', 'Russian', 'Slovak', 'Spanish', 'Swedish', 'Thai',
    'Turkish', 'Ukrainian', 'Vietnamese',
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accent => _isDark ? _darkAccent : _lightAccent;
  Color get _background =>
      _isDark ? const Color(0xFF1D0B32) : const Color(0xFFF8F8F8);
  Color get _surface =>
      _isDark ? const Color(0xFF493A59) : Colors.white;
  Color get _text => _isDark ? Colors.white : const Color(0xFF1D1A20);
  Color get _subText =>
      _isDark ? const Color(0xFFD8D0DF) : const Color(0xFF77717D);
  Color get _border =>
      _isDark ? Colors.white.withOpacity(.18) : Colors.black.withOpacity(.08);

  @override
  void initState() {
    super.initState();
    _loadStorytellers();
  }

  Future<void> _loadStorytellers() async {
    if (mounted) {
      setState(() {
        _loadingStorytellers = true;
        _storytellerError = null;
      });
    }

    try {
      final items = await _dbManager.fetchAllStoryTeller();
      if (!mounted) return;
      setState(() {
        _storytellers = List<StoryTellerItem>.from(items);
        _loadingStorytellers = false;
        if (_storytellers.isNotEmpty && _currentStorytellerIndex < 0) {
          _currentStorytellerIndex = 0;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingStorytellers = false;
        _storytellerError = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _genreScrollController.dispose();
    _dbManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(),
              const SizedBox(height: 18),
              _buildStorytellerSection(),
              const SizedBox(height: 24),
              _buildGenreSection(),
              const SizedBox(height: 24),
              _buildLengthSection(),
              const SizedBox(height: 22),
              _buildLanguageSection(),
              const SizedBox(height: 22),
              _buildPromptSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chat Box',
              style: TextStyle(
                  color: _text, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('Talk To your',
              style: TextStyle(
                  color: _subText, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Story✨',
              style: TextStyle(
                  color: _text, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Turn Your Favorite Memories Into Beautiful AI-Powered Talking Stories',
            style: TextStyle(
                color: _subText,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          const Spacer(),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text('See All',
                  style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorytellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Storyteller', _showAllStorytellers),
        const SizedBox(height: 12),
        if (_loadingStorytellers)
          SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator(color: _accent)),
          )
        else if (_storytellerError != null)
          SizedBox(
            height: 140,
            child: Center(
              child: TextButton(
                onPressed: _loadStorytellers,
                child: Text('Retry Storytellers',
                    style: TextStyle(color: _accent)),
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _storytellers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (_, index) => _storytellerItem(index),
            ),
          ),
      ],
    );
  }

  Widget _storytellerItem(int index) {
    final item = _storytellers[index];
    final selected = _currentStorytellerIndex == index;
    final locked = index > 1;

    return GestureDetector(
      onTap: () {
        if (locked) {
          _showProDialog();
          return;
        }
        setState(() => _currentStorytellerIndex = index);
      },
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected ? _accent : Colors.transparent,
                        width: 3),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(child: _networkStorytellerImage(item.imageUrl)),
                ),
                if (locked)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecoration(color: _accent, shape: BoxShape.circle),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.name.isEmpty ? 'Storyteller' : item.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: _text, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkStorytellerImage(String value) {
    final url = _resolveImageUrl(value);
    if (url == null) {
      return Container(
        color: _surface,
        alignment: Alignment.center,
        child: Icon(Icons.person_rounded, color: _subText, size: 34),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: _surface,
        alignment: Alignment.center,
        child: Icon(Icons.person_rounded, color: _subText, size: 34),
      ),
    );
  }

  String? _resolveImageUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri != null && uri.host.contains('drive.google.com')) {
        final id = uri.queryParameters['id'] ??
            RegExp(r'/d/([^/]+)').firstMatch(value)?.group(1);
        if (id != null && id.isNotEmpty) {
          return 'https://drive.google.com/uc?export=download&id=$id';
        }
      }
      return value;
    }

    if (RegExp(r'^[A-Za-z0-9_-]{15,}$').hasMatch(value)) {
      return 'https://drive.google.com/uc?export=download&id=$value';
    }
    return null;
  }

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Story Genre', _showAllGenres),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            controller: _genreScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (_, index) => _genreItem(index),
          ),
        ),
      ],
    );
  }

  Widget _genreItem(int index) {
    final item = _genres[index];
    final selected = _currentGenreIndex == index;

    return GestureDetector(
      onTap: () => _selectGenre(index),
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? _accent : Colors.transparent, width: 3),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset(
                  item.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _surface,
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.auto_stories_rounded, color: _subText, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(item.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _text, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _selectGenre(int index) {
    setState(() => _currentGenreIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_genreScrollController.hasClients || !mounted) return;
      const itemWidth = 114.0;
      final width = MediaQuery.sizeOf(context).width;
      double target = index * itemWidth - ((width - 110) / 2);
      target = target.clamp(
          0.0, _genreScrollController.position.maxScrollExtent);
      _genreScrollController.animateTo(target,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic);
    });
  }

  void _showAllGenres() {
    _showSelectionGrid<_GenreItem>(
      title: 'Story Genre',
      items: _genres,
      nameOf: (item) => item.name,
      imageBuilder: (item) => Image.asset(
        item.asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: _surface,
          alignment: Alignment.center,
          child: Icon(Icons.auto_stories_rounded, color: _subText),
        ),
      ),
      selectedIndex: _currentGenreIndex,
      onSelected: (index) => _selectGenre(index),
      isLocked: (_) => false,
    );
  }

  void _showAllStorytellers() {
    if (_loadingStorytellers) return;
    _showSelectionGrid<StoryTellerItem>(
      title: 'Storyteller',
      items: _storytellers,
      nameOf: (item) => item.name.isEmpty ? 'Storyteller' : item.name,
      imageBuilder: (item) => _networkStorytellerImage(item.imageUrl),
      selectedIndex: _currentStorytellerIndex,
      onSelected: (index) {
        if (index > 1) {
          _showProDialog();
          return;
        }
        setState(() => _currentStorytellerIndex = index);
      },
      isLocked: (index) => index > 1,
    );
  }

  void _showSelectionGrid<T>({
    required String title,
    required List<T> items,
    required String Function(T) nameOf,
    required Widget Function(T) imageBuilder,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
    required bool Function(int) isLocked,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .62,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                      color: _border, borderRadius: BorderRadius.circular(10)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Row(
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: _text,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(Icons.close_rounded, color: _text),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 14,
                      childAspectRatio: .78,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final selected = selectedIndex == index;
                      final locked = isLocked(index);
                      return GestureDetector(
                        onTap: () {
                          if (!locked) Navigator.pop(sheetContext);
                          Future.delayed(const Duration(milliseconds: 100),
                              () => onSelected(index));
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: selected
                                              ? _accent
                                              : Colors.transparent,
                                          width: 3),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: ClipOval(
                                      child: SizedBox.expand(
                                          child: imageBuilder(items[index])),
                                    ),
                                  ),
                                  if (locked)
                                    Positioned(
                                      right: 3,
                                      top: 3,
                                      child: CircleAvatar(
                                        radius: 11,
                                        backgroundColor: _accent,
                                        child: const Icon(
                                            Icons.workspace_premium_rounded,
                                            color: Colors.white,
                                            size: 13),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(nameOf(items[index]),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: _text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLengthSection() {
    const titles = ['Short', 'Medium', 'Long'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Story Length',
              style: TextStyle(
                  color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            height: 48,
            decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: List.generate(titles.length, (index) {
                final selected = _lengthIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _lengthIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                          color: selected ? _accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(11)),
                      alignment: Alignment.center,
                      child: Text(titles[index],
                          style: TextStyle(
                              color: selected ? Colors.white : _text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Language',
              style: TextStyle(
                  color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showLanguagePicker,
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_language,
                        style: TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: _text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's create a story...",
              style: TextStyle(
                  color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _accent, width: 1.2)),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _promptController,
                  minLines: 5,
                  maxLines: 8,
                  style: TextStyle(color: _text, fontSize: 14, height: 1.45),
                  decoration: InputDecoration(
                      hintText: 'Describe your prompt here…',
                      hintStyle: TextStyle(color: _subText),
                      border: InputBorder.none),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(color: _accent, shape: BoxShape.circle),
                      child: const Icon(Icons.image_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _startStory,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: _accent, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .62,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: _border, borderRadius: BorderRadius.circular(50)),
              ),
              const SizedBox(height: 12),
              Text('Choose Language',
                  style: TextStyle(
                      color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (_, index) {
                    final language = _languages[index];
                    return ListTile(
                      title: Text(language,
                          style: TextStyle(
                              color: _text, fontWeight: FontWeight.w600)),
                      trailing: _language == language
                          ? Icon(Icons.check_rounded, color: _accent)
                          : null,
                      onTap: () {
                        setState(() => _language = language);
                        Navigator.pop(sheetContext);
                      },
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

  void _showProDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: Text('Unlock PRO', style: TextStyle(color: _text)),
        content: Text('This storyteller is available for PRO users.',
            style: TextStyle(color: _subText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Close', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }

  void _startStory() {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter something before continuing.')));
    }
  }
}

class _GenreItem {
  const _GenreItem({required this.name, required this.asset});
  final String name;
  final String asset;
}
