import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/realtime_db_manager.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({
    super.key,
    required this.story,
  });

  final Story story;

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  static const Color _lightAccent = Color(0xFFFF6435);
  static const Color _darkAccent = Color(0xFFF540B3);

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScreenshotController _screenshotController = ScreenshotController();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<DatabaseEvent>? _viewSubscription;

  bool _isFavorite = false;
  bool _isTranslating = false;
  bool _isExporting = false;
  bool _isMusicPlaying = false;
  bool _isMusicPaused = false;

  int _viewCount = 0;

  double _fontSize = 22;
  String _fontName = 'Roboto';
  String _selectedLanguage = 'English';
  String _displayedText = '';
  StorySoundItem? _selectedTrack;

  // 40+ actual Google Fonts.
  static const List<String> _fontNames = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Inter',
    'Nunito',
    'Raleway',
    'Oswald',
    'Ubuntu',
    'PT Sans',
    'PT Serif',
    'Merriweather',
    'Playfair Display',
    'Lora',
    'Noto Sans',
    'Noto Serif',
    'Noto Sans Bengali',
    'Noto Serif Bengali',
    'Hind Siliguri',
    'Tiro Bangla',
    'Fira Sans',
    'Inconsolata',
    'Libre Baskerville',
    'Libre Franklin',
    'Crimson Text',
    'Cormorant Garamond',
    'EB Garamond',
    'DM Sans',
    'DM Serif Display',
    'Work Sans',
    'Quicksand',
    'Rubik',
    'Manrope',
    'Cabin',
    'Bitter',
    'Arvo',
    'Alegreya',
    'Alegreya Sans',
    'Josefin Sans',
    'Karla',
    'Mulish',
    'Barlow',
    'Exo 2',
    'Titillium Web',
    'Source Sans 3',
    'Source Serif 4',
    'Roboto Slab',
  ];

  static const List<StorySoundItem> _soundItems = [
    StorySoundItem(
      id: '1zTmYezLcC_OVxtkj4C15-VgsWhOXzUQ9',
      name: 'Virtual Relaxation',
    ),
    StorySoundItem(
      id: '1yo3O64_eZ1K_9apm_lS9NStq1oc2IFrT',
      name: 'Relaxing Ambient Meditation',
    ),
    StorySoundItem(
      id: '1sLx17IPVdu6WgLwBtEVxLXu3SFOE_5WX',
      name: 'A Nice Gun Shots Sound',
    ),
    StorySoundItem(
      id: '1q8v6SXw9CuVoQVjm5WfgUGEQcIhbzF2-',
      name: 'Relaxing Background with Rain',
    ),
    StorySoundItem(
      id: '1kyjqMEaExv2R7G7QkV7AF2lYRjssE20Z',
      name: 'Green Watercolor Sound Effect',
    ),
    StorySoundItem(
      id: '1eSCCT_lvR65tb65vPHBvCstSVdu0vbWt',
      name: 'Ultimate Relaxation',
    ),
    StorySoundItem(
      id: '1dYFIbCAxXMwrXSwrxj4O41ZZI6OGL0j7',
      name: 'Air Sound',
    ),
    StorySoundItem(
      id: '1WKpWuWe1oczcFBG1RvoJYaU16CYQhsP0',
      name: 'Relaxing Ambient',
    ),
    StorySoundItem(
      id: '1VUg6J2ULv9BoADfewEiBfPmPfUaQJzFv',
      name: 'Relaxing Light Background',
    ),
    StorySoundItem(
      id: '1UZTgmEDuLtgd6PU0pJKD2OAcHj3tzVqp',
      name: 'Enstasy Raining Circles',
    ),
    StorySoundItem(
      id: '1UAokN8iw0gQr7JoQCz70eDp6BJ7wzamP',
      name: 'Relaxing Gamelan Music',
    ),
    StorySoundItem(
      id: '1A3KeAO01gW4CjCwwym7CAtcMOKO6APnG',
      name: 'Summer Beach Ambience',
    ),
    StorySoundItem(
      id: '10tldyHCM4QTIWSIJaIGqT2LKgb15uiyg',
      name: 'Relaxing Orchestral Music',
    ),
    StorySoundItem(
      id: '1IiJvGZ6ySdYtasqkFv92p1CmJOzIp9R8',
      name: 'Relaxing Ambient Meditation',
    ),
    StorySoundItem(
      id: '1AbRz9pAESMJiBApXGeMXn7mWSo8JLaHE',
      name: 'Piano Melody for Relaxation',
    ),
    StorySoundItem(
      id: '10_XrwLKzwAWJ9IsBjMhZRMo1YGvJwZGM',
      name: 'Atmospheric for Meditation Relaxation',
    ),
    StorySoundItem(
      id: '1DUqTH5r5F4sZADF2hJnbIWSp5fZFDjRG',
      name: 'Relaxing Background Music',
    ),
    StorySoundItem(
      id: '1NK73YZJDrJFa9pvqp3iB80B6_yMgzj9k',
      name: 'Relaxing Underwater Ambience',
    ),
  ];

  static const Map<String, TranslateLanguage> _languages = {
    'English': TranslateLanguage.english,
    'Bengali': TranslateLanguage.bengali,
    'Arabic': TranslateLanguage.arabic,
    'Catalan': TranslateLanguage.catalan,
    'Chinese': TranslateLanguage.chinese,
    'Croatian': TranslateLanguage.croatian,
    'Czech': TranslateLanguage.czech,
    'Danish': TranslateLanguage.danish,
    'Dutch': TranslateLanguage.dutch,
    'Finnish': TranslateLanguage.finnish,
    'French': TranslateLanguage.french,
    'German': TranslateLanguage.german,
    'Greek': TranslateLanguage.greek,
    'Hebrew': TranslateLanguage.hebrew,
    'Hindi': TranslateLanguage.hindi,
    'Hungarian': TranslateLanguage.hungarian,
    'Indonesian': TranslateLanguage.indonesian,
    'Italian': TranslateLanguage.italian,
    'Japanese': TranslateLanguage.japanese,
    'Korean': TranslateLanguage.korean,
    'Malay': TranslateLanguage.malay,
    'Norwegian': TranslateLanguage.norwegian,
    'Polish': TranslateLanguage.polish,
    'Portuguese': TranslateLanguage.portuguese,
    'Romanian': TranslateLanguage.romanian,
    'Russian': TranslateLanguage.russian,
    'Slovak': TranslateLanguage.slovak,
    'Slovenian': TranslateLanguage.slovenian,
    'Spanish': TranslateLanguage.spanish,
    'Swedish': TranslateLanguage.swedish,
    'Tamil': TranslateLanguage.tamil,
    'Telugu': TranslateLanguage.telugu,
    'Thai': TranslateLanguage.thai,
    'Turkish': TranslateLanguage.turkish,
    'Ukrainian': TranslateLanguage.ukrainian,
    'Urdu': TranslateLanguage.urdu,
    'Vietnamese': TranslateLanguage.vietnamese,
  };

  String get _storyTitle {
    final title = widget.story.title?.trim() ?? '';
    return title.isEmpty ? 'Story' : title;
  }

  String get _originalText {
    final text = widget.story.summary?.trim() ?? '';
    return text.isEmpty ? 'Story content is not available.' : text;
  }

  String get _storyPreferenceKey {
    final originalUrl = widget.story.originalUrl?.trim() ?? '';
    if (originalUrl.isNotEmpty) return originalUrl;
    return _storyTitle;
  }

  String get _firebaseStoryKey {
    return base64Url
        .encode(utf8.encode(_storyPreferenceKey))
        .replaceAll('=', '');
  }

  DatabaseReference get _viewRef =>
      FirebaseDatabase.instance.ref('storyViews/$_firebaseStoryKey');

  String? get _storyImage {
    return _resolveImageUrl(widget.story.originalUrl) ??
        _resolveImageUrl(widget.story.thumbUrl);
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // NovelAI accent rule: Light Mode = Orange, Dark Mode = Magenta.
  Color get _accent => _isDark ? _darkAccent : _lightAccent;

  Color get _background =>
      _isDark ? const Color(0xFF19102A) : const Color(0xFFF8F8F8);

  Color get _surface =>
      _isDark ? const Color(0xFF30283E) : Colors.white;

  Color get _text =>
      _isDark ? Colors.white : const Color(0xFF1D1A20);

  Color get _muted =>
      _isDark ? const Color(0xFFD2CDD8) : const Color(0xFF77717C);

  Color get _divider =>
      _isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);

  @override
  void initState() {
    super.initState();

    _displayedText = _originalText;

    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isMusicPlaying = state == PlayerState.playing;
        _isMusicPaused = state == PlayerState.paused;
      });
    });

    unawaited(_loadSavedState());
    unawaited(_incrementAndListenToViews());
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _viewSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _storyPreferenceKey;

    final savedLanguage = prefs.getString('${key}_selectedLanguage') ?? 'English';
    final savedTranslation =
        prefs.getString('${key}_translation_$savedLanguage');

    final savedMusicId = prefs.getString('${key}_musicId');
    StorySoundItem? savedTrack;

    if (savedMusicId != null) {
      for (final item in _soundItems) {
        if (item.id == savedMusicId) {
          savedTrack = item;
          break;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _isFavorite = prefs.getBool('${key}_favorite') ?? false;
      _fontSize = prefs.getDouble('${key}_fontSize') ?? 22;
      _fontName = prefs.getString('${key}_fontName') ?? 'Roboto';
      _selectedLanguage = savedLanguage;
      _selectedTrack = savedTrack;

      if (savedLanguage == 'English') {
        _displayedText = _originalText;
      } else if (savedTranslation != null && savedTranslation.trim().isNotEmpty) {
        _displayedText = savedTranslation;
      }
    });
  }

  Future<void> _incrementAndListenToViews() async {
    _viewSubscription = _viewRef.onValue.listen((event) {
      if (!mounted) return;
      final value = event.snapshot.value;

      setState(() {
        _viewCount = switch (value) {
          int v => v,
          num v => v.toInt(),
          String v => int.tryParse(v) ?? 0,
          _ => 0,
        };
      });
    });

    try {
      await _viewRef.runTransaction((currentValue) {
        final current = switch (currentValue) {
          int v => v,
          num v => v.toInt(),
          String v => int.tryParse(v) ?? 0,
          _ => 0,
        };

        return Transaction.success(current + 1);
      });
    } catch (error) {
      debugPrint('Story view increment failed: $error');
    }
  }

  Future<void> _toggleFavorite() async {
    final newValue = !_isFavorite;

    setState(() {
      _isFavorite = newValue;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      '${_storyPreferenceKey}_favorite',
      newValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _text,
            size: 21,
          ),
        ),
        title: Text(
          'Discover Stories',
          style: TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _showShareOptions,
            icon: Icon(
              Icons.ios_share_rounded,
              color: _accent,
              size: 23,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStoryImage(),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildDownloadButton(),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildActionBar(),
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, thickness: 1, color: _divider),
                  if (_isTranslating)
                    LinearProgressIndicator(
                      minHeight: 2,
                      color: _accent,
                    ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStoryContent(),
                  ),
                ],
              ),
            ),
            if (_isExporting)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.34),
                  child: Center(
                    child: CircularProgressIndicator(color: _accent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.72),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Text(
                  _storyTitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = _storyImage;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: _surface,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: _accent,
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: _surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.auto_stories_rounded,
        size: 70,
        color: _accent.withOpacity(0.75),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isExporting ? null : _showDownloadOptions,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _accent.withOpacity(0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_download_outlined, size: 24),
            SizedBox(width: 8),
            Text(
              'Download',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _action(
            icon: _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _isFavorite ? '1' : '0',
            iconColor: _isFavorite ? Colors.redAccent : null,
            onTap: _toggleFavorite,
          ),
          _action(
            icon: Icons.text_fields_rounded,
            label: 'Aa',
            onTap: _showFontOptions,
          ),
          _action(
            icon: Icons.visibility_outlined,
            label: '$_viewCount',
            onTap: () {},
          ),
          _action(
            icon: Icons.format_size_rounded,
            label: 'Size',
            onTap: _showTextSizeOptions,
          ),
          _action(
            icon: Icons.language_rounded,
            label: _selectedLanguage,
            width: 78,
            onTap: _showLanguageOptions,
          ),
          _action(
            icon: _isMusicPlaying
                ? Icons.music_note_rounded
                : Icons.music_note_outlined,
            label: _isMusicPlaying
                ? 'Playing'
                : (_selectedTrack?.name ?? 'Music'),
            width: 74,
            onTap: _showMusicOptions,
          ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    double width = 58,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 23,
                color: iconColor ?? _muted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    TextStyle style;

    try {
      style = GoogleFonts.getFont(
        _fontName,
        color: _text,
        fontSize: _fontSize,
        height: 1.72,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );
    } catch (_) {
      style = TextStyle(
        color: _text,
        fontSize: _fontSize,
        height: 1.72,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );
    }

    return SelectionArea(
      child: Text(
        _displayedText,
        style: style,
      ),
    );
  }

  void _showFontOptions() {
    String query = '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final visibleFonts = _fontNames
                .where(
                  (font) =>
                      font.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

            return SafeArea(
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.75,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF2A2236)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Text(
                      'Choose Font',
                      style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (value) {
                        setSheetState(() {
                          query = value;
                        });
                      },
                      style: TextStyle(color: _text),
                      decoration: InputDecoration(
                        hintText: 'Search 48 fonts',
                        hintStyle: TextStyle(color: _muted),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _muted,
                        ),
                        filled: true,
                        fillColor: _surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: visibleFonts.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: _divider),
                        itemBuilder: (context, index) {
                          final font = visibleFonts[index];
                          TextStyle previewStyle;

                          try {
                            previewStyle = GoogleFonts.getFont(
                              font,
                              color: _text,
                              fontSize: 18,
                            );
                          } catch (_) {
                            previewStyle = TextStyle(
                              color: _text,
                              fontSize: 18,
                            );
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              font,
                              style: previewStyle,
                            ),
                            subtitle: Text(
                              'The quick brown fox',
                              style: previewStyle.copyWith(
                                fontSize: 13,
                                color: _muted,
                              ),
                            ),
                            trailing: _fontName == font
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: _accent,
                                  )
                                : null,
                            onTap: () async {
                              setState(() {
                                _fontName = font;
                              });

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                '${_storyPreferenceKey}_fontName',
                                font,
                              );

                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
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
    );
  }

  void _showTextSizeOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF2A2236)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Text Size',
                      style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 14,
                            max: 34,
                            divisions: 20,
                            activeColor: _accent,
                            onChanged: (value) {
                              setSheetState(() {
                                _fontSize = value;
                              });

                              setState(() {});
                              unawaited(_saveFontSize());
                            },
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            color: _text,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_fontSize.round()}',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      '${_storyPreferenceKey}_fontSize',
      _fontSize,
    );
  }

  void _showLanguageOptions() {
    String query = '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final names = _languages.keys
                .where(
                  (name) =>
                      name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

            return SafeArea(
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.75,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF2A2236)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Text(
                      'Language',
                      style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (value) {
                        setSheetState(() {
                          query = value;
                        });
                      },
                      style: TextStyle(color: _text),
                      decoration: InputDecoration(
                        hintText: 'Search language',
                        hintStyle: TextStyle(color: _muted),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _muted,
                        ),
                        filled: true,
                        fillColor: _surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: names.length,
                        itemBuilder: (context, index) {
                          final name = names[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.translate_rounded,
                              color: _accent,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(color: _text),
                            ),
                            trailing: _selectedLanguage == name
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: _accent,
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(sheetContext);
                              unawaited(_selectLanguage(name));
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
    );
  }

  Future<void> _selectLanguage(String languageName) async {
    if (_isTranslating) {
      _showMessage(
        'Please wait for the current translation to complete.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (languageName == 'English') {
      await prefs.setString(
        '${_storyPreferenceKey}_selectedLanguage',
        'English',
      );

      if (!mounted) return;

      setState(() {
        _selectedLanguage = 'English';
        _displayedText = _originalText;
      });
      return;
    }

    final cached = prefs.getString(
      '${_storyPreferenceKey}_translation_$languageName',
    );

    if (cached != null && cached.trim().isNotEmpty) {
      await prefs.setString(
        '${_storyPreferenceKey}_selectedLanguage',
        languageName,
      );

      if (!mounted) return;

      setState(() {
        _selectedLanguage = languageName;
        _displayedText = cached;
      });
      return;
    }

    await _translateTo(languageName);
  }

  Future<void> _translateTo(String languageName) async {
    final target = _languages[languageName];
    if (target == null) return;

    setState(() {
      _isTranslating = true;
    });

    final manager = OnDeviceTranslatorModelManager();
    OnDeviceTranslator? translator;

    try {
      _showMessage(
        'Preparing $languageName. First use may download the language model.',
      );

      await manager.downloadModel(
        target.bcpCode,
        isWifiRequired: false,
      );

      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: target,
      );

      final chunks = _splitForTranslation(_originalText);
      final translated = StringBuffer();

      for (final chunk in chunks) {
        final result = await translator.translateText(chunk);

        if (translated.isNotEmpty) {
          translated.write('\n\n');
        }

        translated.write(result);

        if (!mounted) return;

        setState(() {
          _selectedLanguage = languageName;
          _displayedText = translated.toString();
        });
      }

      final completedText = translated.toString().trim();

      if (completedText.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          '${_storyPreferenceKey}_translation_$languageName',
          completedText,
        );

        await prefs.setString(
          '${_storyPreferenceKey}_selectedLanguage',
          languageName,
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage('Translation failed: $error');
    } finally {
      await translator?.close();

      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  List<String> _splitForTranslation(String text) {
    const maxChars = 2200;

    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final chunks = <String>[];
    var current = StringBuffer();

    void flush() {
      final value = current.toString().trim();
      if (value.isNotEmpty) chunks.add(value);
      current = StringBuffer();
    }

    for (final paragraph in paragraphs) {
      if (paragraph.length > maxChars) {
        flush();

        var start = 0;

        while (start < paragraph.length) {
          var end = start + maxChars;

          if (end > paragraph.length) {
            end = paragraph.length;
          }

          chunks.add(paragraph.substring(start, end));
          start = end;
        }

        continue;
      }

      if (current.length + paragraph.length + 2 > maxChars) {
        flush();
      }

      if (current.isNotEmpty) {
        current.write('\n\n');
      }

      current.write(paragraph);
    }

    flush();

    if (chunks.isEmpty) {
      chunks.add(text);
    }

    return chunks;
  }

  void _showMusicOptions() {
    String query = '';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final tracks = _soundItems
                .where(
                  (item) =>
                      item.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

            return SafeArea(
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.72,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF2A2236)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Text(
                      'Story Music',
                      style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedTrack != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              color: _accent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedTrack!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (_isMusicPlaying) {
                                  await _audioPlayer.pause();
                                } else if (_isMusicPaused) {
                                  await _audioPlayer.resume();
                                } else {
                                  await _playTrack(_selectedTrack!);
                                }

                                setSheetState(() {});
                              },
                              icon: Icon(
                                _isMusicPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: _accent,
                                size: 31,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await _audioPlayer.stop();

                                if (mounted) {
                                  setState(() {
                                    _isMusicPlaying = false;
                                    _isMusicPaused = false;
                                  });
                                }

                                setSheetState(() {});
                              },
                              icon: Icon(
                                Icons.stop_circle_outlined,
                                color: _muted,
                                size: 29,
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      onChanged: (value) {
                        setSheetState(() {
                          query = value;
                        });
                      },
                      style: TextStyle(color: _text),
                      decoration: InputDecoration(
                        hintText: 'Search music',
                        hintStyle: TextStyle(color: _muted),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _muted,
                        ),
                        filled: true,
                        fillColor: _surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: tracks.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: _divider),
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          final selected = _selectedTrack?.id == track.id;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _accent.withOpacity(0.14),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: _accent,
                              ),
                            ),
                            title: Text(
                              track.name,
                              style: TextStyle(
                                color: _text,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.equalizer_rounded,
                                    color: _accent,
                                  )
                                : Icon(
                                    Icons.play_arrow_rounded,
                                    color: _accent,
                                  ),
                            onTap: () async {
                              await _selectAndPlayTrack(track);
                              setSheetState(() {});
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
    );
  }

  Future<void> _selectAndPlayTrack(StorySoundItem track) async {
    setState(() {
      _selectedTrack = track;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_storyPreferenceKey}_musicId',
      track.id,
    );

    await _playTrack(track);
  }

  Future<void> _playTrack(StorySoundItem track) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      await _audioPlayer.play(
        UrlSource(track.url),
        volume: 0.35,
      );
    } catch (error) {
      _showMessage('Unable to play music: $error');
    }
  }

  void _showShareOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF2A2236)
                  : Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share',
                  style: TextStyle(
                    color: _text,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Choose how you want to share this story',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                _shareOption(
                  icon: Icons.text_snippet_outlined,
                  title: 'Share as Text',
                  subtitle: 'Share the current story text',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    unawaited(_shareAsText());
                  },
                ),
                const SizedBox(height: 10),
                _shareOption(
                  icon: Icons.image_outlined,
                  title: 'Share as Image',
                  subtitle: 'Create a story image and share it',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    unawaited(_shareAsImage());
                  },
                ),
                const SizedBox(height: 10),
                _shareOption(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Share as PDF',
                  subtitle: 'Create a PDF and share it',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    unawaited(_shareAsPdf());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _accent,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareAsText() async {
    await SharePlus.instance.share(
      ShareParams(
        title: _storyTitle,
        subject: _storyTitle,
        text: '$_storyTitle\n\n$_displayedText',
      ),
    );
  }

  void _showDownloadOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF2A2236)
                  : Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Download',
                  style: TextStyle(
                    color: _text,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Choose how to download the text',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                _shareOption(
                  icon: Icons.image_outlined,
                  title: 'Save as Image',
                  subtitle: 'Create a PNG version of the story',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    unawaited(_shareAsImage());
                  },
                ),
                const SizedBox(height: 10),
                _shareOption(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Save as PDF',
                  subtitle: 'Create a PDF version of the story',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    unawaited(_shareAsPdf());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List> _buildStoryImageBytes() async {
    TextStyle storyStyle;

    try {
      storyStyle = GoogleFonts.getFont(
        _fontName,
        color: const Color(0xFF1D1A20),
        fontSize: _fontSize + 1,
        height: 1.6,
      );
    } catch (_) {
      storyStyle = TextStyle(
        color: const Color(0xFF1D1A20),
        fontSize: _fontSize + 1,
        height: 1.6,
      );
    }

    final widget = Material(
      color: Colors.white,
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(56),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _storyTitle,
              style: const TextStyle(
                color: Color(0xFF8C52FF),
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _displayedText,
              style: storyStyle,
            ),
            const SizedBox(height: 30),
            const Text(
              'NovelAI',
              style: TextStyle(
                color: Color(0xFF77717C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return _screenshotController.captureFromLongWidget(
      widget,
      context: context,
      pixelRatio: 1.5,
      delay: const Duration(milliseconds: 100),
    );
  }

  Future<void> _shareAsImage() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final bytes = await _buildStoryImageBytes();

      await SharePlus.instance.share(
        ShareParams(
          title: _storyTitle,
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
            ),
          ],
          fileNameOverrides: [
            '${_safeFileName(_storyTitle)}.png',
          ],
        ),
      );
    } catch (error) {
      _showMessage('Unable to create image: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _shareAsPdf() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final imageBytes = await _buildStoryImageBytes();

      final document = pw.Document();
      final storyImage = pw.MemoryImage(imageBytes);

      document.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(18),
          build: (_) {
            return pw.Center(
              child: pw.Image(
                storyImage,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      final bytes = await document.save();

      await SharePlus.instance.share(
        ShareParams(
          title: _storyTitle,
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/pdf',
            ),
          ],
          fileNameOverrides: [
            '${_safeFileName(_storyTitle)}.pdf',
          ],
        ),
      );
    } catch (error) {
      _showMessage('Unable to create PDF: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _safeFileName(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    return cleaned.isEmpty ? 'story' : cleaned;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String? _resolveImageUrl(String? rawValue) {
    final value = rawValue?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      if (uri.host.contains('drive.google.com')) {
        final queryId = uri.queryParameters['id'];

        if (queryId != null && queryId.isNotEmpty) {
          return 'https://drive.google.com/uc?export=download&id=$queryId';
        }

        final segments = uri.pathSegments;
        final dIndex = segments.indexOf('d');

        if (dIndex >= 0 && dIndex + 1 < segments.length) {
          final id = segments[dIndex + 1];

          if (id.isNotEmpty) {
            return 'https://drive.google.com/uc?export=download&id=$id';
          }
        }
      }

      return value;
    }

    return 'https://drive.google.com/uc?export=download&id=$value';
  }
}

class StorySoundItem {
  const StorySoundItem({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  String get url =>
      'https://drive.google.com/uc?export=download&id=$id';
}
