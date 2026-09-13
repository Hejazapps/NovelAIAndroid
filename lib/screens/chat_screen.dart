import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/realtime_db_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _lightAccent = Color(0xFFFF6435);
  static const Color _darkAccent = Color(0xFF9146E8);

  final RealtimeDBManager _dbManager = RealtimeDBManager();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _genreScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _profileImagePath;
  String? _selectedAvatarAsset;

  List<StoryTellerItem> _storytellers = const [];
  bool _loadingStorytellers = true;
  String? _storytellerError;

  int _selectedStorytellerIndex = -1;
  int _selectedGenreIndex = 0;
  int _selectedLengthIndex = 0;
  String _selectedLanguage = 'English';

  static const List<String> _languages = [
    'Afrikaans',
    'Albanian',
    'Amharic',
    'Arabic',
    'Armenian',
    'Assamese',
    'Aymara',
    'Azerbaijani',
    'Bambara',
    'Basque',
    'Belarusian',
    'Bengali',
    'Bhojpuri',
    'Bosnian',
    'Bulgarian',
    'Burmese',
    'Catalan',
    'Cebuano',
    'Chichewa',
    'Chinese Simplified',
    'Chinese Traditional',
    'Corsican',
    'Croatian',
    'Czech',
    'Danish',
    'Dhivehi',
    'Dogri',
    'Dutch',
    'English',
    'Esperanto',
    'Estonian',
    'Ewe',
    'Filipino',
    'Finnish',
    'French',
    'Frisian',
    'Galician',
    'Georgian',
    'German',
    'Greek',
    'Guarani',
    'Gujarati',
    'Haitian Creole',
    'Hausa',
    'Hawaiian',
    'Hebrew',
    'Hindi',
    'Hmong',
    'Hungarian',
    'Icelandic',
    'Igbo',
    'Ilocano',
    'Indonesian',
    'Irish',
    'Italian',
    'Japanese',
    'Javanese',
    'Kannada',
    'Kazakh',
    'Khmer',
    'Kinyarwanda',
    'Konkani',
    'Korean',
    'Krio',
    'Kurdish',
    'Kurdish (Sorani)',
    'Kyrgyz',
    'Lao',
    'Latin',
    'Latvian',
    'Lingala',
    'Lithuanian',
    'Luganda',
    'Luxembourgish',
    'Macedonian',
    'Maithili',
    'Malagasy',
    'Malay',
    'Malayalam',
    'Maltese',
    'Maori',
    'Marathi',
    'Meiteilon (Manipuri)',
    'Mizo',
    'Mongolian',
    'Nepali',
    'Norwegian',
    'Norwegian Bokmål',
    'Odia (Oriya)',
    'Oromo',
    'Pashto',
    'Persian',
    'Polish',
    'Portuguese',
    'Portuguese (Brazil)',
    'Portuguese (Portugal)',
    'Punjabi',
    'Quechua',
    'Romanian',
    'Russian',
    'Samoan',
    'Sanskrit',
    'Scots Gaelic',
    'Sepedi',
    'Serbian',
    'Sesotho',
    'Shona',
    'Sindhi',
    'Sinhala',
    'Slovak',
    'Slovenian',
    'Somali',
    'Spanish',
    'Sundanese',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Tajik',
    'Tamil',
    'Tatar',
    'Telugu',
    'Thai',
    'Tigrinya',
    'Tsonga',
    'Turkish',
    'Turkmen',
    'Twi',
    'Ukrainian',
    'Urdu',
    'Uyghur',
    'Uzbek',
    'Vietnamese',
    'Welsh',
    'Xhosa',
    'Yiddish',
    'Yoruba',
    'Zulu',
    'Acehnese',
    'Acholi',
    'Afar',
    'Alur',
    'Awadhi',
    'Balinese',
    'Baluchi',
    'Batak Karo',
    'Batak Simalungun',
    'Batak Toba',
    'Bemba',
    'Betawi',
    'Bikol',
    'Breton',
    'Buryat',
    'Cantonese',
    'Chamorro',
    'Chechen',
    'Chuukese',
    'Chuvash',
    'Crimean Tatar',
    'Dari',
    'Dinka',
    'Dombe',
    'Dzongkha',
    'Faroese',
    'Fijian',
    'Fon',
    'Friulian',
    'Ga',
    'Greenlandic',
    'Hakha Chin',
    'Herero',
    'Hiligaynon',
    'Iban',
    'Jingpo',
    'Kalaallisut',
    'Kanuri',
    'Kapampangan',
    'Khasi',
    'Kituba',
    'Kokborok',
    'Komering',
    'Limburgish',
    'Lombard',
    'Madurese',
    'Makassar',
    'Marshallese',
    'Minangkabau',
    'Ndebele (South)',
    'NKo',
    'Occitan',
    'Ossetian',
    'Pangasinan',
    'Papiamento',
    'Romani',
    'Rundi',
    'Sango',
    'Santali',
    'Seychellois Creole',
    'Sicilian',
    'Silesian',
    'Swati',
    'Tahitian',
    'Tiv',
    'Tok Pisin',
    'Tshiluba',
    'Tswana',
    'Tulu',
    'Venda',
    'Waray',
    'Wolof',
    'Yakut',
    'Zapotec',
  ];

  final List<_GenreItem> _genres = const [
    _GenreItem(name: 'Horror', image: 'assets/genres/horror.png'),
    _GenreItem(name: 'Comedy', image: 'assets/genres/comedy.png'),
    _GenreItem(name: 'Sad', image: 'assets/genres/sad.png'),
    _GenreItem(name: 'Romance', image: 'assets/genres/romance.png'),
    _GenreItem(name: 'Adventure', image: 'assets/genres/adventure.png'),
    _GenreItem(name: 'Fantasy', image: 'assets/genres/fantasy.png'),
    _GenreItem(name: 'Mystery', image: 'assets/genres/mystery.png'),
    _GenreItem(name: 'Thriller', image: 'assets/genres/thriller.png'),
    _GenreItem(name: 'Drama', image: 'assets/genres/drama.png'),
    _GenreItem(name: 'Crime', image: 'assets/genres/crime.png'),
    _GenreItem(name: 'Science Fiction', image: 'assets/genres/science_fiction.png'),
    _GenreItem(name: 'Mythology', image: 'assets/genres/mythology.png'),
    _GenreItem(name: 'Superhero', image: 'assets/genres/superhero.png'),
    _GenreItem(name: 'Fairy Tale', image: 'assets/genres/fairy_tale.png'),
    _GenreItem(name: 'Historical', image: 'assets/genres/historical.png'),
    _GenreItem(name: 'Historical Fiction', image: 'assets/genres/historical_fiction.png'),
    _GenreItem(name: 'Non-Fiction', image: 'assets/genres/non_fiction.png'),
    _GenreItem(name: 'Detective', image: 'assets/genres/detective.png'),
    _GenreItem(name: 'Young Adult', image: 'assets/genres/young_adult.png'),
    _GenreItem(name: 'Dystopian', image: 'assets/genres/dystopian.png'),
    _GenreItem(name: 'Time Travel', image: 'assets/genres/time_travel.png'),
    _GenreItem(name: 'Dark Fantasy', image: 'assets/genres/dark_fantasy.png'),
    _GenreItem(name: 'Cyberpunk', image: 'assets/genres/cyberpunk.png'),
    _GenreItem(name: 'Post-Apocalyptic', image: 'assets/genres/post_apocalyptic.png'),
    _GenreItem(name: 'Spy', image: 'assets/genres/spy.png'),
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accent => _isDark ? _darkAccent : _lightAccent;
  Color get _page => _isDark ? const Color(0xFF140D20) : const Color(0xFFF9F9F9);
  Color get _surface => _isDark ? const Color(0xFF21182E) : Colors.white;
  Color get _surfaceAlt => _isDark ? const Color(0xFF2A1A3B) : const Color(0xFFF2F0F4);
  Color get _text => _isDark ? Colors.white : const Color(0xFF111111);
  Color get _muted => _isDark ? const Color(0xFFB9AEC8) : const Color(0xFF666166);
  Color get _hint => _isDark ? const Color(0xFF81758F) : const Color(0xFFC4C1C5);
  Color get _border => _isDark ? const Color(0xFF49305F) : const Color(0xFFE9E6EA);

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadStorytellers();
  }

  Future<void> _loadStorytellers() async {
    setState(() {
      _loadingStorytellers = true;
      _storytellerError = null;
    });

    try {
      final items = await _dbManager.fetchAllStoryTeller();
      if (!mounted) return;
      setState(() {
        _storytellers = List<StoryTellerItem>.from(items);
        _loadingStorytellers = false;
        if (_storytellers.isNotEmpty && _selectedStorytellerIndex < 0) {
          _selectedStorytellerIndex = 0;
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


  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('ChatScreen.profileImagePath');
    final savedAvatar = prefs.getString('ChatScreen.selectedAvatarAsset');

    if (!mounted) return;

    setState(() {
      if (savedPath != null &&
          savedPath.isNotEmpty &&
          File(savedPath).existsSync()) {
        _profileImagePath = savedPath;
      }

      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        _selectedAvatarAsset = savedAvatar;
      }
    });
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1200,
      );

      if (picked == null || !mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ChatScreen.profileImagePath', picked.path);
      await prefs.remove('ChatScreen.selectedAvatarAsset');

      if (!mounted) return;
      setState(() {
        _profileImagePath = picked.path;
        _selectedAvatarAsset = null;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $error')),
      );
    }
  }

  Future<void> _removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ChatScreen.profileImagePath');
    await prefs.remove('ChatScreen.selectedAvatarAsset');

    if (!mounted) return;
    setState(() {
      _profileImagePath = null;
      _selectedAvatarAsset = null;
    });
  }

  Future<void> _selectAvatar(String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ChatScreen.selectedAvatarAsset', assetPath);
    await prefs.remove('ChatScreen.profileImagePath');

    if (!mounted) return;
    setState(() {
      _selectedAvatarAsset = assetPath;
      _profileImagePath = null;
    });
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.62,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose Avatar',
                          style: TextStyle(
                            color: _text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
                      crossAxisCount: 4,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: 30,
                    itemBuilder: (_, index) {
                      final asset = 'assets/avatars/Avatar$index.png';
                      final selected = _selectedAvatarAsset == asset;

                      return GestureDetector(
                        onTap: () async {
                          await _selectAvatar(asset);
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? _accent : _border,
                              width: selected ? 3 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              asset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
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

  void _showProfileImageOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Profile Picture',
                  style: TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _profileOption(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickProfileImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _profileOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Gallery',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickProfileImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _profileOption(
                        icon: Icons.face_rounded,
                        title: 'Avatar',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Future.delayed(
                            const Duration(milliseconds: 150),
                            _showAvatarPicker,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (_profileImagePath != null || _selectedAvatarAsset != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _removeProfileImage();
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Remove Photo'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: _surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _accent, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: _page,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 190),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 22),
                    _buildHero(),
                    const SizedBox(height: 28),
                    _buildPromptBox(),
                    const SizedBox(height: 22),
                    _buildLanguage(),
                    const SizedBox(height: 30),
                    _buildStorytellerSection(),
                    const SizedBox(height: 18),
                    _buildGenreSection(),
                    const SizedBox(height: 30),
                    _buildLengthSection(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 18,
              child: _buildBottomComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _showProfileImageOptions,
                child: Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent, width: 2.5),
                  ),
                  child: ClipOval(
                    child: _profileImagePath != null
                        ? Image.file(
                            File(_profileImagePath!),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person_rounded,
                              color: _accent,
                              size: 25,
                            ),
                          )
                        : _selectedAvatarAsset != null
                            ? Image.asset(
                                _selectedAvatarAsset!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : Icon(
                                Icons.person_rounded,
                                color: _accent,
                                size: 25,
                              ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Chat Box',
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  debugPrint('History tapped');
                },
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Center(
                    child: Icon(
                      Icons.access_time_rounded,
                      color: _accent,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/chaticons/Bot.png',
          width: 84,
          height: 84,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          errorBuilder: (_, __, ___) => const SizedBox(height: 84),
        ),
        const SizedBox(height: 18),
        Text(
          'Talk To your',
          style: TextStyle(
            color: _text,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: -1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Story✨',
          style: TextStyle(
            color: _accent,
            fontSize: 40,
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Turn Your Favorite Memories Into Beautiful AI-Powered\nTalking Stories',
          style: TextStyle(
            color: _muted,
            fontSize: 17,
            height: 1.18,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.15,
          ),
        ),
      ],
    );
  }

  Widget _buildPromptBox() {
    return Container(
      height: 178,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: TextField(
        controller: _promptController,
        minLines: null,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(color: _text, fontSize: 17, height: 1.35),
        decoration: InputDecoration(
          hintText: 'Describe your prompt here...',
          hintStyle: TextStyle(
            color: _hint,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(28, 26, 24, 20),
        ),
      ),
    );
  }

  Widget _buildLanguage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Language',
          style: TextStyle(
            color: _text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showLanguagePicker,
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLanguage == 'English'
                        ? 'Choose Language'
                        : _selectedLanguage,
                    style: TextStyle(
                      color: _selectedLanguage == 'English' ? _hint : _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: _text, size: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorytellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: 'Select Storyteller',
          actionText: 'See All',
          onAction: _showAllStorytellers,
        ),
        const SizedBox(height: 20),
        if (_loadingStorytellers)
          SizedBox(
            height: 122,
            child: Center(child: CircularProgressIndicator(color: _accent)),
          )
        else if (_storytellerError != null)
          SizedBox(
            height: 122,
            child: Center(
              child: TextButton(
                onPressed: _loadStorytellers,
                child: Text('Retry', style: TextStyle(color: _accent, fontSize: 15)),
              ),
            ),
          )
        else
          SizedBox(
            height: 115,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _storytellers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 11),
              itemBuilder: (_, index) => _buildStoryteller(index),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _text,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            child: Text(
              actionText,
              style: TextStyle(
                color: _text,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryteller(int index) {
    final item = _storytellers[index];
    final selected = index == _selectedStorytellerIndex;
    final locked = index > 1;

    return GestureDetector(
      onTap: () {
        if (locked) {
          _showProDialog();
          return;
        }
        setState(() => _selectedStorytellerIndex = index);
      },
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 78,
              padding: EdgeInsets.all(selected ? 3 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: selected ? Border.all(color: _accent, width: 2) : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(selected ? 13 : 16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _storytellerImage(item.imageUrl),
                    if (selected)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: _accent,
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      )
                    else if (locked)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: _accent,
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.name.isEmpty ? 'Storyteller' : item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _accent : _text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storytellerImage(String raw) {
    final url = _resolveImageUrl(raw);
    if (url == null) {
      return Container(
        color: _surfaceAlt,
        alignment: Alignment.center,
        child: Icon(Icons.person_rounded, color: _muted, size: 34),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: _surfaceAlt,
        alignment: Alignment.center,
        child: Icon(Icons.person_rounded, color: _muted, size: 34),
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
        _sectionHeader(
          title: 'Story Genre',
          actionText: 'View All',
          onAction: _showAllGenres,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 115,
          child: ListView.separated(
            controller: _genreScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (_, index) => _buildGenreItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreItem(int index) {
    final genre = _genres[index];
    final selected = _selectedGenreIndex == index;

    return GestureDetector(
      onTap: () => _selectGenre(index),
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 78,
              padding: EdgeInsets.all(selected ? 3 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: selected ? Border.all(color: _accent, width: 2) : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(selected ? 13 : 16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      genre.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _surfaceAlt,
                        alignment: Alignment.center,
                        child: Icon(Icons.auto_stories_outlined, color: _muted),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: _accent,
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              genre.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _accent : _text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectGenre(int index) {
    setState(() => _selectedGenreIndex = index);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_genreScrollController.hasClients || !mounted) return;
      const itemExtent = 93.0;
      const itemWidth = 82.0;
      final screenWidth = MediaQuery.sizeOf(context).width;
      double targetOffset = (index * itemExtent) - ((screenWidth - itemWidth) / 2);
      targetOffset = targetOffset.clamp(
        0.0,
        _genreScrollController.position.maxScrollExtent,
      );
      _genreScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Widget _buildLengthSection() {
    const values = ['Short', 'Medium', 'Long'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Story Length',
          style: TextStyle(
            color: _text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: List.generate(values.length, (index) {
              final selected = _selectedLengthIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLengthIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(_isDark ? 0.22 : 0.07),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      values[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? _accent : _muted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomComposer() {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            _isDark ? _darkAccent : const Color(0xFF00C63B),
            _accent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.22 : 0.09),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 0, 7, 0),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: _accent, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                "Let's create a story...",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _hint,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: _startStory,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final searchController = TextEditingController();
    String query = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final filtered = _languages.where((language) {
              if (query.trim().isEmpty) return true;
              return language
                  .toLowerCase()
                  .contains(query.trim().toLowerCase());
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .72,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Choose Language',
                          style: TextStyle(
                            color: _text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: TextField(
                        controller: searchController,
                        autofocus: false,
                        onChanged: (value) {
                          setSheetState(() => query = value);
                        },
                        style: TextStyle(
                          color: _text,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search language...',
                          hintStyle: TextStyle(color: _hint),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _muted,
                          ),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setSheetState(() => query = '');
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: _muted,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: _surfaceAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _accent,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No language found',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : ListView.builder(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final language = filtered[index];
                                final selected =
                                    _selectedLanguage == language;

                                return ListTile(
                                  title: Text(
                                    language,
                                    style: TextStyle(
                                      color: selected ? _accent : _text,
                                      fontSize: 16,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  trailing: selected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: _accent,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(
                                      () => _selectedLanguage = language,
                                    );
                                    Navigator.pop(sheetContext);
                                  },
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
      },
    ).whenComplete(searchController.dispose);
  }

  void _showAllStorytellers() {
    if (_loadingStorytellers || _storytellers.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .58,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Storyteller',
                      style: TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 15,
                      childAspectRatio: .82,
                    ),
                    itemCount: _storytellers.length,
                    itemBuilder: (_, index) {
                      final item = _storytellers[index];
                      final selected = index == _selectedStorytellerIndex;
                      final locked = index > 1;

                      return GestureDetector(
                        onTap: () {
                          if (locked) {
                            _showProDialog();
                            return;
                          }
                          Navigator.pop(sheetContext);
                          setState(() => _selectedStorytellerIndex = index);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(selected ? 3 : 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: selected
                                          ? Border.all(color: _accent, width: 2)
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: _storytellerImage(item.imageUrl),
                                    ),
                                  ),
                                  if (locked)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: _accent,
                                        child: const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              item.name.isEmpty ? 'Storyteller' : item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected ? _accent : _text,
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
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

  void _showAllGenres() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .56,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Genre',
                      style: TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 15,
                      childAspectRatio: .82,
                    ),
                    itemCount: _genres.length,
                    itemBuilder: (_, index) {
                      final genre = _genres[index];
                      final selected = index == _selectedGenreIndex;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Future.delayed(const Duration(milliseconds: 120), () {
                            if (mounted) _selectGenre(index);
                          });
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(selected ? 3 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: selected
                                      ? Border.all(color: _accent, width: 2)
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        genre.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: _surfaceAlt,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.auto_stories_outlined,
                                            color: _muted,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: CircleAvatar(
                                            radius: 10,
                                            backgroundColor: _accent,
                                            child: const Icon(
                                              Icons.check_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              genre.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? _accent : _text,
                              ),
                            ),
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

  void _showProDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text('Unlock PRO', style: TextStyle(color: _text)),
          content: Text(
            'This storyteller is available for PRO users.',
            style: TextStyle(color: _muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Close', style: TextStyle(color: _accent)),
            ),
          ],
        );
      },
    );
  }

  void _startStory() {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter something before continuing.')),
      );
      return;
    }

    debugPrint('==============================================');
    debugPrint('CHAT STORY');
    debugPrint('Prompt      : ${_promptController.text.trim()}');
    debugPrint('Language    : $_selectedLanguage');
    debugPrint('Genre       : ${_genres[_selectedGenreIndex].name}');
    debugPrint('Length      : ${['Short', 'Medium', 'Long'][_selectedLengthIndex]}');

    if (_selectedStorytellerIndex >= 0 &&
        _selectedStorytellerIndex < _storytellers.length) {
      debugPrint('Storyteller : ${_storytellers[_selectedStorytellerIndex].name}');
      debugPrint('AI Prompt   : ${_storytellers[_selectedStorytellerIndex].prompt}');
    }
    debugPrint('==============================================');
  }
}

class _GenreItem {
  const _GenreItem({required this.name, required this.image});

  final String name;
  final String image;
}
