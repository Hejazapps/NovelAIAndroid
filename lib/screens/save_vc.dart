import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/easy_seek_api_manager.dart';

typedef SaveVcGenerateCallback = Future<void> Function(
  String prompt,
  void Function(String streamedText) onUpdate,
);

typedef SaveVcVoidCallback = Future<void> Function();
typedef SaveVcTextCallback = Future<void> Function(String text);

class SaveVc extends StatefulWidget {
  const SaveVc({
    super.key,
    this.textToGive = '',
    this.mainTitle = '',
    this.selectedLanguage = 'English',
    this.genre = '',
    this.hasTag = '',
    this.createdDate = '',
    this.contentType = 'Story',
    this.themeId = '',
    this.currentIndex = 0,
    this.shouldNeedToCall = true,
    this.isFromSave = false,
    this.isFromFav = false,
    this.onGenerate,
    this.onRegenerate,
    this.onMusic,
    this.onOpenTheme,
    this.onOpenTextEditor,
    this.onHearText,
    this.onSaved,
  });

  // Mirrors the important public values passed into iOS SaveVc.
  final String textToGive;
  final String mainTitle;
  final String selectedLanguage;
  final String genre;
  final String hasTag;
  final String createdDate;
  final String contentType;
  final String themeId;
  final int currentIndex;
  final bool shouldNeedToCall;
  final bool isFromSave;
  final bool isFromFav;

  // Keep generation outside this UI class so it can use your existing
  // EasySeekApiManager without duplicating API logic here.
  final SaveVcGenerateCallback? onGenerate;
  final SaveVcGenerateCallback? onRegenerate;

  final SaveVcVoidCallback? onMusic;
  final SaveVcVoidCallback? onOpenTheme;
  final SaveVcVoidCallback? onOpenTextEditor;
  final SaveVcTextCallback? onHearText;
  final SaveVcVoidCallback? onSaved;

  @override
  State<SaveVc> createState() => _SaveVcState();
}

class _SaveVcState extends State<SaveVc> {
  static const String _entriesKey = 'textDateEntries';

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;
  String? _activeTtsLocale;

  late String _title;
  late bool _isFavorite;
  late String _themeId;

  bool _isGenerating = false;
  bool _generationCompleted = false;
  bool _isFullScreen = false;

  double _fontSize = 16;
  FontWeight _fontWeight = FontWeight.w500;
  FontStyle _fontStyle = FontStyle.normal;
  TextAlign _textAlign = TextAlign.left;
  bool _underline = false;

  String _fontFamily = 'sans-serif';
  double _textOpacity = 1.0;
  double _lineSpacing = 1.6;
  double _letterSpacing = 0.0;
  double _paragraphSpacing = 0.0;
  double _textWidth = 1.0;
  double _pageMargins = 15.0;
  Color _textColor = const Color(0xFF171717);
  int? _textGradientIndex;
  int _textEditorTab = 0;
  ui.Image? _textTextureImage;

  Color? _backgroundColor;
  List<Color>? _backgroundGradient;
  String? _backgroundAsset;

  Color? _forcedTextColor;
  int? _textureIndex;

  Color get _pageBackground =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : const Color(0xFFF7F7F7);

  Color get _cardBackground =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : Colors.white;

  Color get _interfaceColor {
    if (_forcedTextColor != null) return _forcedTextColor!;

    if (_backgroundColor != null) {
      return _readableColor(_backgroundColor!);
    }

    if (_backgroundGradient != null && _backgroundGradient!.isNotEmpty) {
      return _readableColor(_backgroundGradient!.first);
    }

    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  void initState() {
    super.initState();

    _title = widget.mainTitle.trim().isEmpty ? 'AI Story' : widget.mainTitle;
    _isFavorite = widget.isFromFav;
    _themeId = widget.themeId;
    _textController.text = widget.textToGive;

    _configureAndroidTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.shouldNeedToCall && widget.onGenerate != null) {
        _startGeneration(widget.textToGive);
      } else {
        setState(() {
          _generationCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration(String prompt) async {
    if (prompt.trim().isEmpty || widget.onGenerate == null || _isGenerating) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationCompleted = false;
      _textController.clear();
    });

    try {
      await widget.onGenerate!(
        prompt,
        (streamedText) {
          if (!mounted) return;
          setState(() {
            _textController.text = _cleanGeneratedText(streamedText);
            _textController.selection = TextSelection.collapsed(
              offset: _textController.text.length,
            );
          });
          _scrollToBottom();
        },
      );

      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generationCompleted = _textController.text.trim().isNotEmpty;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
      _showMessage('Generation failed. Please try again.');
    }
  }

  Future<void> _regenerate() async {
    if (widget.onRegenerate == null || _isGenerating) return;

    setState(() {
      _isGenerating = true;
      _generationCompleted = false;
      _textController.clear();
    });

    try {
      await widget.onRegenerate!(
        widget.textToGive,
        (streamedText) {
          if (!mounted) return;
          setState(() {
            _textController.text = _cleanGeneratedText(streamedText);
            _textController.selection = TextSelection.collapsed(
              offset: _textController.text.length,
            );
          });
          _scrollToBottom();
        },
      );

      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generationCompleted = _textController.text.trim().isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      _showMessage('Regeneration failed. Please try again.');
    }
  }

  Future<void> _configureAndroidTts() async {
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((message) {
      debugPrint('Android TTS error: $message');
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
      _showMessage('Unable to play this voice on your device.');
    });
  }

  String? _ttsLocaleForLanguage(String language) {
    final value = language.trim().toLowerCase();

    const exact = <String, String>{
      'afrikaans': 'af-ZA',
      'albanian': 'sq-AL',
      'amharic': 'am-ET',
      'arabic': 'ar-SA',
      'armenian': 'hy-AM',
      'assamese': 'as-IN',
      'azerbaijani': 'az-AZ',
      'basque': 'eu-ES',
      'belarusian': 'be-BY',
      'bengali': 'bn-BD',
      'bangla': 'bn-BD',
      'bosnian': 'bs-BA',
      'bulgarian': 'bg-BG',
      'burmese': 'my-MM',
      'catalan': 'ca-ES',
      'chinese simplified': 'zh-CN',
      'chinese traditional': 'zh-TW',
      'croatian': 'hr-HR',
      'czech': 'cs-CZ',
      'danish': 'da-DK',
      'dutch': 'nl-NL',
      'english': 'en-US',
      'estonian': 'et-EE',
      'filipino': 'fil-PH',
      'finnish': 'fi-FI',
      'french': 'fr-FR',
      'georgian': 'ka-GE',
      'german': 'de-DE',
      'greek': 'el-GR',
      'gujarati': 'gu-IN',
      'hebrew': 'he-IL',
      'hindi': 'hi-IN',
      'hungarian': 'hu-HU',
      'icelandic': 'is-IS',
      'indonesian': 'id-ID',
      'irish': 'ga-IE',
      'italian': 'it-IT',
      'japanese': 'ja-JP',
      'kannada': 'kn-IN',
      'kazakh': 'kk-KZ',
      'khmer': 'km-KH',
      'korean': 'ko-KR',
      'lao': 'lo-LA',
      'latvian': 'lv-LV',
      'lithuanian': 'lt-LT',
      'macedonian': 'mk-MK',
      'malay': 'ms-MY',
      'malayalam': 'ml-IN',
      'marathi': 'mr-IN',
      'nepali': 'ne-NP',
      'norwegian': 'nb-NO',
      'norwegian bokmål': 'nb-NO',
      'persian': 'fa-IR',
      'polish': 'pl-PL',
      'portuguese': 'pt-PT',
      'portuguese (brazil)': 'pt-BR',
      'portuguese (portugal)': 'pt-PT',
      'punjabi': 'pa-IN',
      'romanian': 'ro-RO',
      'russian': 'ru-RU',
      'serbian': 'sr-RS',
      'slovak': 'sk-SK',
      'slovenian': 'sl-SI',
      'spanish': 'es-ES',
      'swahili': 'sw-KE',
      'swedish': 'sv-SE',
      'tamil': 'ta-IN',
      'telugu': 'te-IN',
      'thai': 'th-TH',
      'turkish': 'tr-TR',
      'ukrainian': 'uk-UA',
      'urdu': 'ur-PK',
      'vietnamese': 'vi-VN',
      'welsh': 'cy-GB',
    };

    if (exact.containsKey(value)) return exact[value];

    if (value.contains('bengali') || value.contains('bangla')) return 'bn-BD';
    if (value.contains('english')) return 'en-US';
    if (value.contains('arabic')) return 'ar-SA';
    if (value.contains('hindi')) return 'hi-IN';
    if (value.contains('urdu')) return 'ur-PK';
    if (value.contains('chinese') && value.contains('traditional')) {
      return 'zh-TW';
    }
    if (value.contains('chinese')) return 'zh-CN';
    if (value.contains('japanese')) return 'ja-JP';
    if (value.contains('korean')) return 'ko-KR';
    if (value.contains('portuguese') && value.contains('brazil')) {
      return 'pt-BR';
    }
    if (value.contains('portuguese')) return 'pt-PT';

    return null;
  }

  Future<bool> _isTtsLanguageAvailable(String locale) async {
    try {
      final result = await _flutterTts.isLanguageAvailable(locale);

      if (result is bool) return result;
      if (result is int) return result == 1;
      if (result is String) {
        final normalized = result.toLowerCase();
        return normalized == 'true' || normalized == '1';
      }

      return result == true;
    } catch (error) {
      debugPrint('TTS language availability check failed: $error');
      return false;
    }
  }

  Future<void> _toggleHearText() async {
    if (_isGenerating) return;

    if (_isSpeaking) {
      await _flutterTts.stop();

      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    final storyText = _textController.text.trim();
    if (storyText.isEmpty) return;

    // Preserve the existing external callback if the caller supplied one.
    if (widget.onHearText != null) {
      await widget.onHearText!(storyText);
      return;
    }

    final locale = _ttsLocaleForLanguage(widget.selectedLanguage);

    if (locale == null) {
      _showMessage(
        'This language is not supported for voice playback on your device.',
      );
      return;
    }

    final available = await _isTtsLanguageAvailable(locale);

    if (!available) {
      _showMessage(
        'This language is not supported for voice playback on your device.',
      );
      return;
    }

    try {
      final languageResult = await _flutterTts.setLanguage(locale);

      if (languageResult == 0 || languageResult == false) {
        _showMessage(
          'This language is not supported for voice playback on your device.',
        );
        return;
      }

      _activeTtsLocale = locale;

      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
      });

      final speakResult = await _flutterTts.speak(storyText);

      if (speakResult == 0 && mounted) {
        setState(() {
          _isSpeaking = false;
        });
        _showMessage('Unable to play this voice on your device.');
      }
    } catch (error) {
      debugPrint('Unable to start Android TTS: $error');

      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
      });

      _showMessage(
        'This language is not supported for voice playback on your device.',
      );
    }
  }

  String _cleanGeneratedText(String text) {
    return text
        .replaceAll('The End!', '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trimLeft();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _title);

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Enter Title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(context, title);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value == null || value.trim().isEmpty || !mounted) return;

    setState(() {
      _title = value.trim();
    });

    await _updateExistingEntryTitle(_title);
  }

  String get _formattedTags {
    final raw = widget.hasTag.trim();
    if (raw.isEmpty) return '';

    return raw
        .replaceAll('#', ',')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => '#$e')
        .join();
  }

  String get _dateText {
    if (widget.createdDate.trim().isNotEmpty) return widget.createdDate;
    final now = DateTime.now();
    final hour = now.hour == 0
        ? 12
        : now.hour > 12
            ? now.hour - 12
            : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day}-${months[now.month - 1]}-${now.year} . $hour:$minute $amPm';
  }

  Future<void> _copyText() async {
    await Clipboard.setData(
      ClipboardData(text: _textController.text),
    );
    if (!mounted) return;
    _showMessage('Text has been copied to clipboard.');
  }

  Future<void> _shareText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await Share.share(
      text,
      subject: _title,
    );
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await _updateExistingFavoriteState();
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showMessage('There is no text to save.');
      return;
    }

    if (widget.shouldNeedToCall && !widget.isFromSave) {
      final title = await _askForStoryTitle();
      if (title == null) return;
      if (mounted) {
        setState(() => _title = title);
      }
      await _saveNewEntry(title: title);
    } else {
      await _updateExistingEntry();
    }

    if (widget.onSaved != null) {
      await widget.onSaved!();
    }

    if (!mounted) return;
    _showMessage(widget.isFromSave ? 'Updated!' : 'Saved!');
  }

  Future<String?> _askForStoryTitle() async {
    final controller = TextEditingController(
      text: _title == 'AI Story' ? '' : _title,
    );

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Story Title'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter Title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(context, title);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return value;
  }

  Future<List<Map<String, dynamic>>> _readEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);

    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      // Keep the screen usable even if old storage has another format.
    }

    return [];
  }

  Future<void> _writeEntries(List<Map<String, dynamic>> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, jsonEncode(entries));
  }

  Future<void> _saveNewEntry({required String title}) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _readEntries();

    final nextId = prefs.getInt('TextDateEntryNextID') ?? 0;
    await prefs.setInt('TextDateEntryNextID', nextId + 1);

    entries.add({
      'id': nextId,
      'text': _textController.text,
      'date': _dateText,
      'lang': widget.selectedLanguage,
      'title': title,
      'category': widget.genre,
      'folder': '',
      'isFav': _isFavorite,
      'hasTag': widget.hasTag,
      'font': 'PlusJakartaSans-Medium',
      'contentType': widget.contentType,
      'themeId': _themeId,
      'colortype': '0',
      'textStyle': {
        'fontName': 'PlusJakartaSans-Medium',
        'fontSize': _fontSize,
        'isBold': _fontWeight == FontWeight.bold,
        'isItalic': _fontStyle == FontStyle.italic,
        'isUnderlined': _underline,
        'textAlignment': _textAlign.index,
        'textureIndex': _textureIndex ?? 0,
        'fontFamily': _fontFamily,
        'textOpacity': _textOpacity,
        'lineSpacing': _lineSpacing,
        'letterSpacing': _letterSpacing,
        'paragraphSpacing': _paragraphSpacing,
        'textWidth': _textWidth,
        'pageMargins': _pageMargins,
        'textColor': _textColor.value,
        'textGradientIndex': _textGradientIndex,
      },
    });

    await _writeEntries(entries);
  }

  Future<void> _updateExistingEntry() async {
    final entries = await _readEntries();

    if (widget.currentIndex < 0 || widget.currentIndex >= entries.length) {
      return;
    }

    final entry = entries[widget.currentIndex];
    entry['text'] = _textController.text;
    entry['title'] = _title;
    entry['isFav'] = _isFavorite;
    entry['themeId'] = _themeId;
    entry['font'] = 'PlusJakartaSans-Medium';
    entry['textStyle'] = {
      'fontName': 'PlusJakartaSans-Medium',
      'fontSize': _fontSize,
      'isBold': _fontWeight == FontWeight.bold,
      'isItalic': _fontStyle == FontStyle.italic,
      'isUnderlined': _underline,
      'textAlignment': _textAlign.index,
      'textureIndex': _textureIndex ?? 0,
    };

    await _writeEntries(entries);
  }

  Future<void> _updateExistingEntryTitle(String title) async {
    final entries = await _readEntries();
    if (widget.currentIndex < 0 || widget.currentIndex >= entries.length) {
      return;
    }
    entries[widget.currentIndex]['title'] = title;
    await _writeEntries(entries);
  }

  Future<void> _updateExistingFavoriteState() async {
    final entries = await _readEntries();
    if (widget.currentIndex < 0 || widget.currentIndex >= entries.length) {
      return;
    }
    entries[widget.currentIndex]['isFav'] = _isFavorite;
    await _writeEntries(entries);
  }

  void _resetDesign() {
    setState(() {
      _fontSize = 16;
      _fontWeight = FontWeight.w500;
      _fontStyle = FontStyle.normal;
      _textAlign = TextAlign.left;
      _underline = false;
      _fontFamily = 'sans-serif';
      _textOpacity = 1.0;
      _lineSpacing = 1.6;
      _letterSpacing = 0.0;
      _paragraphSpacing = 0.0;
      _textWidth = 1.0;
      _pageMargins = 15.0;
      _textColor = const Color(0xFF171717);
      _textGradientIndex = null;
      _textEditorTab = 0;
      _backgroundColor = null;
      _backgroundGradient = null;
      _backgroundAsset = null;
      _forcedTextColor = null;
      _textureIndex = null;
      _themeId = 'none';
    });
  }

  Future<void> _confirmResetDesign() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Design?'),
          content: const Text(
            'This will reset the background and text style. Your story will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (reset == true) {
      _resetDesign();
    }
  }

  Future<void> _showTextStyleSheet() async {
    final originalFontSize = _fontSize;
    final originalFontWeight = _fontWeight;
    final originalFontStyle = _fontStyle;
    final originalTextAlign = _textAlign;
    final originalUnderline = _underline;
    final originalFontFamily = _fontFamily;
    final originalTextOpacity = _textOpacity;
    final originalLineSpacing = _lineSpacing;
    final originalLetterSpacing = _letterSpacing;
    final originalParagraphSpacing = _paragraphSpacing;
    final originalTextWidth = _textWidth;
    final originalPageMargins = _pageMargins;
    final originalTextColor = _textColor;
    final originalTextGradientIndex = _textGradientIndex;
    final originalTextureIndex = _textureIndex;
    final originalForcedTextColor = _forcedTextColor;

    bool applied = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            void update(VoidCallback callback) {
              setState(callback);
              sheetSetState(() {});
            }

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetColor =
                isDark ? const Color(0xFF1C1C1E) : Colors.white;
            final cardColor = isDark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFF5F5F7);
            final borderColor = isDark
                ? const Color(0xFF3A3A3C)
                : const Color(0xFFE5E5EA);
            final primary = isDark
                ? const Color(0xFF9146E8)
                : const Color(0xFFFF6435);
            final muted = isDark
                ? const Color(0xFFA9A9AF)
                : const Color(0xFF7A7A80);

            final textColors = <Color>[
              const Color(0xFF111111),
              Colors.white,
              const Color(0xFFFF3B30),
              const Color(0xFFFF9500),
              const Color(0xFFFFCC00),
              const Color(0xFF34C759),
              const Color(0xFF00C7BE),
              const Color(0xFF007AFF),
              const Color(0xFF5856D6),
              const Color(0xFFAF52DE),
              const Color(0xFFFF2D55),
              const Color(0xFF8E8E93),
            ];

            final textGradients = <List<Color>>[
              const [Color(0xFFFF6435), Color(0xFFFF2D55)],
              const [Color(0xFF9146E8), Color(0xFF5856D6)],
              const [Color(0xFF007AFF), Color(0xFF00C7BE)],
              const [Color(0xFF34C759), Color(0xFFFFCC00)],
              const [Color(0xFFFF9500), Color(0xFFFF3B30)],
              const [Color(0xFF111111), Color(0xFF8E8E93)],
            ];

            Widget sectionTitle(String title) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }

            Widget valueSlider({
              required String title,
              required double value,
              required double min,
              required double max,
              required int divisions,
              required String Function(double) valueText,
              required ValueChanged<double> onChanged,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        valueText(value),
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                  Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    activeColor: primary,
                    onChanged: onChanged,
                  ),
                ],
              );
            }

            Widget iconChoice({
              required IconData icon,
              required bool selected,
              required VoidCallback onTap,
            }) {
              return Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withValues(alpha: 0.14)
                          : cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? primary : borderColor,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: selected ? primary : null,
                    ),
                  ),
                ),
              );
            }

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.50,
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 12, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const Expanded(
                          child: Text(
                            'Text Editor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            applied = true;
                            Navigator.pop(sheetContext);
                          },
                          icon: Icon(Icons.check_rounded, color: primary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      _textController.text.trim().isEmpty
                          ? 'Your story text will look like this.'
                          : _textController.text.trim().split('\n').first,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: _textAlign,
                      style: _storyTextStyle,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: ['Color', 'Gradient', 'Texture']
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final selected =
                                    _textEditorTab == entry.key;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => update(
                                      () => _textEditorTab = entry.key,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? sheetColor
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(9),
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.08),
                                                  blurRadius: 5,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color:
                                              selected ? primary : muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_textEditorTab == 0)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: textColors.map((color) {
                                final selected =
                                    _textGradientIndex == null &&
                                        _textureIndex == null &&
                                        _textColor.value == color.value;
                                return GestureDetector(
                                  onTap: () => update(() {
                                    _textColor = color;
                                    _textGradientIndex = null;
                                    _textureIndex = null;
                                    _textTextureImage = null;
                                    _forcedTextColor = color;
                                  }),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: selected ? 3 : 1,
                                        color: selected
                                            ? primary
                                            : borderColor,
                                      ),
                                    ),
                                    child: selected
                                        ? Icon(
                                            Icons.check,
                                            size: 17,
                                            color: _readableColor(color),
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          if (_textEditorTab == 1)
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: textGradients.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.0,
                              ),
                              itemBuilder: (_, index) {
                                final selected =
                                    _textGradientIndex == index;
                                return GestureDetector(
                                  onTap: () => update(() {
                                    _textGradientIndex = index;
                                    _textureIndex = null;
                                    _textTextureImage = null;
                                    _forcedTextColor = null;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: textGradients[index],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      border: Border.all(
                                        color: selected
                                            ? primary
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: selected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          if (_textEditorTab == 2)
                            SizedBox(
                              height: 74,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: 22,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 9),
                                itemBuilder: (_, index) {
                                  final selected =
                                      _textureIndex == index;
                                  return GestureDetector(
                                    onTap: () async {
                                      update(() {
                                        _textureIndex = index;
                                        _textGradientIndex = null;
                                        _forcedTextColor = null;
                                      });
                                      await _loadTextTexture(index);
                                      sheetSetState(() {});
                                    },
                                    child: Container(
                                      width: 62,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected
                                              ? primary
                                              : borderColor,
                                          width: selected ? 2.5 : 1,
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/texture$index.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: selected
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 22),
                          sectionTitle('Font'),
                          DropdownButtonFormField<String>(
                            value: _fontFamily,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: borderColor),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'sans-serif',
                                child: Text('Sans Serif'),
                              ),
                              DropdownMenuItem(
                                value: 'serif',
                                child: Text('Serif'),
                              ),
                              DropdownMenuItem(
                                value: 'monospace',
                                child: Text('Monospace'),
                              ),
                              DropdownMenuItem(
                                value: 'sans-serif-condensed',
                                child: Text('Condensed'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                update(() => _fontFamily = value);
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          valueSlider(
                            title: 'Font Size',
                            value: _fontSize,
                            min: 12,
                            max: 34,
                            divisions: 22,
                            valueText: (v) => '${v.round()}',
                            onChanged: (v) =>
                                update(() => _fontSize = v),
                          ),
                          const SizedBox(height: 4),
                          sectionTitle('Font Alignment'),
                          Row(
                            children: [
                              iconChoice(
                                icon: Icons.format_align_left_rounded,
                                selected:
                                    _textAlign == TextAlign.left,
                                onTap: () => update(
                                  () => _textAlign = TextAlign.left,
                                ),
                              ),
                              const SizedBox(width: 8),
                              iconChoice(
                                icon: Icons.format_align_center_rounded,
                                selected:
                                    _textAlign == TextAlign.center,
                                onTap: () => update(
                                  () => _textAlign = TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              iconChoice(
                                icon: Icons.format_align_right_rounded,
                                selected:
                                    _textAlign == TextAlign.right,
                                onTap: () => update(
                                  () => _textAlign = TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 8),
                              iconChoice(
                                icon:
                                    Icons.format_align_justify_rounded,
                                selected:
                                    _textAlign == TextAlign.justify,
                                onTap: () => update(
                                  () => _textAlign = TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          sectionTitle('Font Style'),
                          Row(
                            children: [
                              iconChoice(
                                icon: Icons.format_bold_rounded,
                                selected:
                                    _fontWeight == FontWeight.bold,
                                onTap: () => update(() {
                                  _fontWeight =
                                      _fontWeight == FontWeight.bold
                                          ? FontWeight.w500
                                          : FontWeight.bold;
                                }),
                              ),
                              const SizedBox(width: 8),
                              iconChoice(
                                icon: Icons.format_italic_rounded,
                                selected:
                                    _fontStyle == FontStyle.italic,
                                onTap: () => update(() {
                                  _fontStyle =
                                      _fontStyle == FontStyle.italic
                                          ? FontStyle.normal
                                          : FontStyle.italic;
                                }),
                              ),
                              const SizedBox(width: 8),
                              iconChoice(
                                icon:
                                    Icons.format_underline_rounded,
                                selected: _underline,
                                onTap: () => update(
                                  () => _underline = !_underline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          valueSlider(
                            title: 'Text Opacity',
                            value: _textOpacity,
                            min: 0.2,
                            max: 1.0,
                            divisions: 8,
                            valueText: (v) =>
                                '${(v * 100).round()}%',
                            onChanged: (v) =>
                                update(() => _textOpacity = v),
                          ),
                          valueSlider(
                            title: 'Line Spacing',
                            value: _lineSpacing,
                            min: 1.0,
                            max: 2.5,
                            divisions: 15,
                            valueText: (v) => v.toStringAsFixed(1),
                            onChanged: (v) =>
                                update(() => _lineSpacing = v),
                          ),
                          valueSlider(
                            title: 'Letter Spacing',
                            value: _letterSpacing,
                            min: -1.0,
                            max: 4.0,
                            divisions: 20,
                            valueText: (v) => v.toStringAsFixed(1),
                            onChanged: (v) =>
                                update(() => _letterSpacing = v),
                          ),
                          valueSlider(
                            title: 'Paragraph Spacing',
                            value: _paragraphSpacing,
                            min: 0,
                            max: 20,
                            divisions: 20,
                            valueText: (v) => '${v.round()}',
                            onChanged: (v) =>
                                update(() => _paragraphSpacing = v),
                          ),
                          valueSlider(
                            title: 'Text Width',
                            value: _textWidth,
                            min: 0.65,
                            max: 1.0,
                            divisions: 7,
                            valueText: (v) =>
                                '${(v * 100).round()}%',
                            onChanged: (v) =>
                                update(() => _textWidth = v),
                          ),
                          valueSlider(
                            title: 'Page Margins',
                            value: _pageMargins,
                            min: 8,
                            max: 40,
                            divisions: 16,
                            valueText: (v) => '${v.round()}',
                            onChanged: (v) =>
                                update(() => _pageMargins = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!applied && mounted) {
      setState(() {
        _fontSize = originalFontSize;
        _fontWeight = originalFontWeight;
        _fontStyle = originalFontStyle;
        _textAlign = originalTextAlign;
        _underline = originalUnderline;
        _fontFamily = originalFontFamily;
        _textOpacity = originalTextOpacity;
        _lineSpacing = originalLineSpacing;
        _letterSpacing = originalLetterSpacing;
        _paragraphSpacing = originalParagraphSpacing;
        _textWidth = originalTextWidth;
        _pageMargins = originalPageMargins;
        _textColor = originalTextColor;
        _textGradientIndex = originalTextGradientIndex;
        _textureIndex = originalTextureIndex;
        _forcedTextColor = originalForcedTextColor;
      });

      if (originalTextureIndex != null) {
        await _loadTextTexture(originalTextureIndex);
      } else if (mounted) {
        setState(() {
          _textTextureImage = null;
        });
      }
    }
  }

  Future<void> _showThemeSheet() async {
    if (widget.onOpenTheme != null) {
      await widget.onOpenTheme!();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = <Color>[
          Colors.white,
          const Color(0xFFFFF4E9),
          const Color(0xFFE9F7FF),
          const Color(0xFFF2EBFF),
          const Color(0xFF161616),
        ];

        final gradients = <List<Color>>[
          const [Color(0xFF01AC84), Color(0xFF00A6D1)],
          const [Color(0xFFFF9966), Color(0xFFFF5E62)],
          const [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)],
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Background',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _backgroundColor = null;
                          _backgroundGradient = null;
                          _backgroundAsset = null;
                          _themeId = 'none';
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('None'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _backgroundColor = color;
                          _backgroundGradient = null;
                          _backgroundAsset = null;
                          _themeId =
                              'color:${color.value.toRadixString(16).substring(2).toUpperCase()}';
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: gradients.map((gradient) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            final index = gradients.indexOf(gradient);
                            setState(() {
                              _backgroundColor = null;
                              _backgroundGradient = gradient;
                              _backgroundAsset = null;
                              _themeId = 'gradient:$index';
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _styleChoice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }

  Color _readableColor(Color color) {
    final brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness < 140 ? Colors.white : Colors.black;
  }

  Decoration _storyBackgroundDecoration() {
    if (_backgroundAsset != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_backgroundAsset!),
          fit: BoxFit.cover,
        ),
      );
    }

    if (_backgroundGradient != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: _backgroundGradient!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    return BoxDecoration(
      color: _backgroundColor ?? _cardBackground,
      borderRadius: BorderRadius.circular(16),
    );
  }

  Future<void> _loadTextTexture(int index) async {
    try {
      final data = await rootBundle.load('assets/images/texture$index.png');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();

      if (!mounted) return;

      setState(() {
        _textTextureImage = frame.image;
      });
    } catch (error) {
      debugPrint('Unable to load text texture $index: $error');

      if (!mounted) return;

      setState(() {
        _textTextureImage = null;
      });
    }
  }

  TextStyle get _storyTextStyle {
    Paint? foreground;

    if (_textureIndex != null && _textTextureImage != null) {
      foreground = Paint()
        ..shader = ui.ImageShader(
          _textTextureImage!,
          ui.TileMode.repeated,
          ui.TileMode.repeated,
          Float64List.fromList(const [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
          ]),
        )
        ..color = Colors.white.withValues(alpha: _textOpacity);
    } else if (_textGradientIndex != null) {
      const gradients = <List<Color>>[
        [Color(0xFFFF6435), Color(0xFFFF2D55)],
        [Color(0xFF9146E8), Color(0xFF5856D6)],
        [Color(0xFF007AFF), Color(0xFF00C7BE)],
        [Color(0xFF34C759), Color(0xFFFFCC00)],
        [Color(0xFFFF9500), Color(0xFFFF3B30)],
        [Color(0xFF111111), Color(0xFF8E8E93)],
      ];

      final index = _textGradientIndex!.clamp(0, gradients.length - 1);

      foreground = Paint()
        ..shader = LinearGradient(
          colors: gradients[index]
              .map((c) => c.withValues(alpha: _textOpacity))
              .toList(),
        ).createShader(const Rect.fromLTWH(0, 0, 700, 100));
    }

    final baseColor =
        (_forcedTextColor ?? _textColor).withValues(alpha: _textOpacity);

    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: _fontSize,
      height: _lineSpacing + (_paragraphSpacing / 100),
      letterSpacing: _letterSpacing,
      fontWeight: _fontWeight,
      fontStyle: _fontStyle,
      color: foreground == null ? baseColor : null,
      foreground: foreground,
      decoration:
          _underline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  bool get _showRegenerate {
    return widget.contentType.toLowerCase() == 'story' &&
        widget.shouldNeedToCall &&
        !widget.isFromSave &&
        _generationCompleted &&
        !_isGenerating;
  }

  Future<void> logStoryLiked() async {
    try {
      final ref = FirebaseDatabase.instance
          .ref()
          .child('story_liked')
          .child('counter');

      final result = await ref.runTransaction((currentValue) {
        final currentCount = currentValue is num ? currentValue.toInt() : 0;
        return Transaction.success(currentCount + 1);
      });

      if (result.committed) {
        debugPrint('Story liked count is now ${result.snapshot.value ?? 0}');
      }
    } catch (error) {
      debugPrint('Transaction failed: $error');
    }
  }

  Future<void> logStoryDisliked() async {
    try {
      final ref = FirebaseDatabase.instance
          .ref()
          .child('story_disliked')
          .child('counter');

      final result = await ref.runTransaction((currentValue) {
        final currentCount = currentValue is num ? currentValue.toInt() : 0;
        return Transaction.success(currentCount + 1);
      });

      if (result.committed) {
        debugPrint('Story disliked count is now ${result.snapshot.value ?? 0}');
      }
    } catch (error) {
      debugPrint('Transaction failed: $error');
    }
  }

  Widget _iosStyleDialog({
    required String title,
    String? message,
    Widget? content,
    required List<Widget> actions,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF242424)
        : const Color(0xFFF8F8F8);
    final primaryText = isDark ? Colors.white : const Color(0xFF111111);
    final secondaryText = isDark
        ? const Color(0xFFB9B9B9)
        : const Color(0xFF5F5F5F);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 42),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          color: background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),
                    if (message != null && message.trim().isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                          color: secondaryText,
                        ),
                      ),
                    ],
                    if (content != null) ...[
                      const SizedBox(height: 16),
                      content,
                    ],
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }

  Widget _iosDialogAction({
    required String title,
    required VoidCallback onPressed,
    bool destructive = false,
    bool bold = false,
    bool showTopDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = isDark
        ? const Color(0xFF414141)
        : const Color(0xFFD2D2D2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTopDivider)
          Container(
            height: 0.7,
            color: divider,
          ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              shape: const RoundedRectangleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: destructive
                    ? const Color(0xFFFF3B30)
                    : const Color(0xFF0A84FF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> gotoEditView() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _iosStyleDialog(
          title: 'Your Opinion',
          message: 'Do you like this story?',
          actions: [
            _iosDialogAction(
              title: 'Like',
              bold: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await logStoryLiked();
                if (mounted) {
                  _showMessage('Story liked successfully');
                }
              },
            ),
            _iosDialogAction(
              title: 'Dislike',
              destructive: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await logStoryDisliked();

                if (mounted) {
                  _showMessage('Story disliked');
                  await askForDislikeReason();
                }
              },
            ),
            _iosDialogAction(
              title: 'Cancel',
              onPressed: () {
                debugPrint('User cancelled opinion');
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> askForDislikeReason() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _iosStyleDialog(
          title: 'Would you like to tell us why?',
          message: 'Your feedback helps us improve future stories.',
          actions: [
            _iosDialogAction(
              title: 'No',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            _iosDialogAction(
              title: 'Yes',
              bold: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Future.microtask(showReasonInput);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showReasonInput() async {
    if (!mounted) return;

    final reasonController = TextEditingController();
    final reasonFocusNode = FocusNode();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (reasonFocusNode.canRequestFocus) {
            reasonFocusNode.requestFocus();
          }
        });

        final fieldBackground = isDark
            ? const Color(0xFF171717)
            : Colors.white;
        final fieldBorder = isDark
            ? const Color(0xFF4A4A4A)
            : const Color(0xFFD0D0D0);

        return _iosStyleDialog(
          title: 'Tell us the reason',
          message: 'Your feedback helps improve the app',
          content: TextField(
            controller: reasonController,
            focusNode: reasonFocusNode,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF111111),
            ),
            decoration: InputDecoration(
              hintText: 'Reason for dislike',
              hintStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF858585)
                    : const Color(0xFF8E8E93),
              ),
              filled: true,
              fillColor: fieldBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF0A84FF),
                  width: 1.4,
                ),
              ),
            ),
          ),
          actions: [
            _iosDialogAction(
              title: 'Cancel',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            _iosDialogAction(
              title: 'Send',
              bold: true,
              onPressed: () async {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop();
                await sendReasonEmail(reason: reason);
              },
            ),
          ],
        );
      },
    );

    reasonController.dispose();
    reasonFocusNode.dispose();
  }

  Future<void> sendReasonEmail({required String reason}) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'apaceapps2025@gmail.com',
      queryParameters: {
        'subject': 'Story Dislike Reason',
        'body': 'User reason:\n\n$reason',
      },
    );

    try {
      final canOpenMail = await canLaunchUrl(emailUri);

      if (!canOpenMail) {
        if (mounted) {
          await _showMailNotConfiguredDialog();
        }
        return;
      }

      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        await _showMailNotConfiguredDialog();
      }
    } catch (error) {
      debugPrint('Unable to open mail composer: $error');

      if (mounted) {
        await _showMailNotConfiguredDialog();
      }
    }
  }

  Future<void> _showMailNotConfiguredDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _iosStyleDialog(
          title: 'Mail Not Configured',
          message: 'Please set up a mail account in order to send email.',
          actions: [
            _iosDialogAction(
              title: 'OK',
              bold: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interfaceColor = _interfaceColor;

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: _backgroundColor ?? _pageBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: _storyBackgroundDecoration(),
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: interfaceColor,
                          ),
                        ),
                        if (_formattedTags.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formattedTags,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFFFF6435),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          _dateText,
                          style: TextStyle(
                            fontSize: 14,
                            color: interfaceColor.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _textController.text,
                          textAlign: _textAlign,
                          style: _storyTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  onPressed: () => setState(() => _isFullScreen = false),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(interfaceColor),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                    child: AbsorbPointer(
                      absorbing: _isGenerating,
                      child: Opacity(
                        opacity: _isGenerating ? 0.72 : 1,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: _storyBackgroundDecoration(),
                          child: Column(
                            children: [
                              _buildStoryHeader(interfaceColor),
                              Expanded(
                                child: _buildStoryEditor(interfaceColor),
                              ),
                              _buildBottomBar(interfaceColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Show the blocking progress only while we are still waiting
          // for the first streamed text. As soon as text starts arriving,
          // the story itself becomes the progress indicator.
          if (_isGenerating && _textController.text.trim().isEmpty)
            _buildGeneratingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color interfaceColor) {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          const SizedBox(width: 8),

          // Back is intentionally the ONLY active control during generation.
          _topAssetButton(
            fallbackIcon: Icons.arrow_back_ios_new,
            onPressed: () async {
              await Navigator.maybePop(context);
            },
            tint: interfaceColor,
          ),

          Expanded(
            child: AbsorbPointer(
              absorbing: _isGenerating,
              child: Row(
                children: [
                  _topIconButton(
                    icon: Icons.refresh,
                    onPressed: _confirmResetDesign,
                    tint: interfaceColor.withValues(
                      alpha: _isGenerating ? 0.35 : 1,
                    ),
                  ),
                  const Spacer(),
                  if (_showRegenerate)
                    TextButton(
                      onPressed: _regenerate,
                      child: Text(
                        'Regenerate',
                        style: TextStyle(
                          color: interfaceColor.withValues(
                            alpha: _isGenerating ? 0.35 : 1,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (widget.onMusic != null)
                    _topIconButton(
                      icon: Icons.music_note_outlined,
                      onPressed: widget.onMusic,
                      tint: interfaceColor.withValues(
                        alpha: _isGenerating ? 0.35 : 1,
                      ),
                    ),
                  _topImageButton(
                    path: 'assets/images/edit.png',
                    onPressed:
                        widget.onOpenTextEditor ?? _showTextStyleSheet,
                    tint: interfaceColor.withValues(
                      alpha: _isGenerating ? 0.35 : 1,
                    ),
                  ),
                  _topImageButton(
                    path: 'assets/images/share.png',
                    onPressed: _shareText,
                    tint: interfaceColor.withValues(
                      alpha: _isGenerating ? 0.35 : 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryHeader(Color interfaceColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 15, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _editTitle,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: interfaceColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: interfaceColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_formattedTags.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formattedTags,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFF6435),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  _dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: interfaceColor.withValues(alpha: 0.60),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _isFullScreen = true),
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: interfaceColor,
                    size: 22,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: gotoEditView,
                  icon: Icon(
                    Icons.thumb_up_alt_outlined,
                    color: interfaceColor,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryEditor(Color interfaceColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            (constraints.maxWidth - (_pageMargins * 2))
                .clamp(80.0, constraints.maxWidth);
        final editorWidth = availableWidth * _textWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: editorWidth,
            height: constraints.maxHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                controller: _textController,
                scrollController: _scrollController,
                expands: true,
                maxLines: null,
                minLines: null,
                readOnly: _isGenerating,
                textAlign: _textAlign,
                textAlignVertical: TextAlignVertical.top,
                style: _storyTextStyle,
                cursorColor: interfaceColor,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                onChanged: (_) {
                  if (!_isGenerating) {
                    _generationCompleted =
                        _textController.text.trim().isNotEmpty;
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmStopStory() async {
    if (!_isGenerating || !mounted) return;

    final shouldStop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Stop Story?'),
          content: const Text(
            'Do you want to stop generating this story?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Stop',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldStop != true || !mounted) return;

    try {
      EasySeekApiManager.shared.stopStreaming();
    } catch (_) {}

    setState(() {
      _isGenerating = false;
    });
  }

  Widget _buildBottomBar(Color interfaceColor) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          _bottomImageButton(
            path: _isFavorite
                ? 'assets/images/full.png'
                : 'assets/images/empty.png',
            onPressed: _isGenerating ? null : _toggleFavorite,
            tint: interfaceColor,
          ),
          const SizedBox(width: 10),
          _bottomIconButton(
            icon: Icons.image_outlined,
            onPressed: _isGenerating ? null : _showThemeSheet,
            tint: interfaceColor,
          ),
          const SizedBox(width: 10),
          _bottomImageButton(
            path: 'assets/images/small.png',
            onPressed: _isGenerating ? null : _showTextStyleSheet,
            tint: interfaceColor,
          ),
          const Spacer(),
          _bottomImageButton(
            path: _isSpeaking
                ? 'assets/images/pause.png'
                : 'assets/images/vector_1.png',
            onPressed: _isGenerating ? null : _toggleHearText,
            tint: interfaceColor,
          ),
          _bottomImageButton(
            path: 'assets/images/group_1000004153.png',
            onPressed: _isGenerating ? null : _copyText,
            tint: interfaceColor,
          ),
          _bottomImageButton(
            path: 'assets/images/download_2.png',
            onPressed: _isGenerating ? null : _save,
            tint: interfaceColor,
            opacity: _isGenerating ? 0.4 : 1,
          ),
          _bottomImageButton(
            path: 'assets/images/forbidden.png',
            onPressed: _isGenerating ? _confirmStopStory : null,
            tint: interfaceColor,
            opacity: _isGenerating ? 1 : 0.35,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.18),
        child: Center(
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Generating...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topImageButton({
    required String path,
    required Future<void> Function()? onPressed,
    required Color tint,
  }) {
    return SizedBox(
      width: 50,
      height: 46,
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          path,
          width: 24,
          height: 24,
          color: tint,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (_, __, ___) => Icon(
            Icons.circle_outlined,
            color: tint,
          ),
        ),
      ),
    );
  }

  Widget _topIconButton({
    required IconData icon,
    required Future<void> Function()? onPressed,
    required Color tint,
  }) {
    return SizedBox(
      width: 50,
      height: 46,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: tint),
      ),
    );
  }

  Widget _topAssetButton({
    required IconData fallbackIcon,
    required Future<void> Function()? onPressed,
    required Color tint,
  }) {
    return SizedBox(
      width: 45,
      height: 45,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          fallbackIcon,
          color: tint,
          size: 22,
        ),
      ),
    );
  }

  Widget _bottomImageButton({
    required String path,
    required Future<void> Function()? onPressed,
    required Color tint,
    double opacity = 1,
  }) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: 46,
        height: 46,
        child: IconButton(
          onPressed: onPressed,
          padding: const EdgeInsets.all(10),
          icon: Image.asset(
            path,
            width: 25,
            height: 25,
            color: tint,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (_, __, ___) => Icon(
              Icons.circle_outlined,
              color: tint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomIconButton({
    required IconData icon,
    required Future<void> Function()? onPressed,
    required Color tint,
  }) {
    return SizedBox(
      width: 56,
      height: 46,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: tint),
      ),
    );
  }
}
