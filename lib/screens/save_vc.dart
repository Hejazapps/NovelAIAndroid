import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/easy_seek_api_manager.dart';
import '../services/realtime_db_manager.dart';

typedef SaveVcGenerateCallback = Future<void> Function(
  String prompt,
  void Function(String streamedText) onUpdate,
);

typedef SaveVcVoidCallback = Future<void> Function();
typedef SaveVcTextCallback = Future<void> Function(String text);
typedef SaveVcBookTextCallback = Future<void> Function(String text);
typedef SaveVcBookNavigationCallback = Future<void> Function();

final ValueNotifier<int> saveVcHistoryRevision = ValueNotifier<int>(0);
final ValueNotifier<int> saveVcOpenHistoryRequest = ValueNotifier<int>(0);

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
    this.bookId = '',
    this.bookChapterIndex = -1,
    this.bookChapterNumber = 0,
    this.bookChapterCount = 0,
    this.isBookFullView = false,
    this.hasBookPrevious = false,
    this.hasBookNext = false,
    this.onBookTextChanged,
    this.onBookPrevious,
    this.onBookNext,
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

  final String bookId;
  final int bookChapterIndex;
  final int bookChapterNumber;
  final int bookChapterCount;
  final bool isBookFullView;
  final bool hasBookPrevious;
  final bool hasBookNext;
  final SaveVcBookTextCallback? onBookTextChanged;
  final SaveVcBookNavigationCallback? onBookPrevious;
  final SaveVcBookNavigationCallback? onBookNext;

  bool get isBookMode => bookId.trim().isNotEmpty;

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
  String? _backgroundNetworkUrl;

  Color? _forcedTextColor;
  int? _textureIndex;

  Timer? _historyAutosaveTimer;
  Timer? _bookDesignAutosaveTimer;
  Timer? _bookTextAutosaveTimer;
  bool _historyStateReady = false;
  bool _bookStateReady = false;
  bool _isNavigatingToHistory = false;

  Color get _pageBackground =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111111)
          : const Color(0xFFF7F7F7);

  Color get _cardBackground =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : Colors.white;

  bool get _hasCustomStoryBackground =>
      _backgroundColor != null ||
      (_backgroundGradient != null && _backgroundGradient!.isNotEmpty) ||
      _backgroundAsset != null ||
      (_backgroundNetworkUrl != null &&
          _backgroundNetworkUrl!.trim().isNotEmpty);

  Color get _interfaceColor {
    // On the normal app background, UI controls must always follow
    // the current Light/Dark app appearance. This also prevents an old
    // saved white text color from making the whole UI disappear in Light Mode.
    if (!_hasCustomStoryBackground) {
      return Theme.of(context).colorScheme.onSurface;
    }

    // For a custom story background, keep an explicitly chosen text color.
    if (_forcedTextColor != null) return _forcedTextColor!;

    if (_backgroundColor != null) {
      return _readableColor(_backgroundColor!);
    }

    if (_backgroundGradient != null && _backgroundGradient!.isNotEmpty) {
      return _readableColor(_backgroundGradient!.first);
    }

    // Image backgrounds do not have a single reliable sampled color.
    // White is the safest existing behaviour unless the user explicitly
    // selected another text color.
    if (_backgroundAsset != null ||
        (_backgroundNetworkUrl != null &&
            _backgroundNetworkUrl!.trim().isNotEmpty)) {
      return Colors.white;
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
    _textController.addListener(_handleBookTextChanged);

    _configureAndroidTts();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (widget.isBookMode) {
        await _restoreBookDesign();
        if (!mounted) return;
        _bookStateReady = true;
      }

      if (widget.isFromSave && !widget.isBookMode) {
        await _restoreHistoryEntry();
        if (!mounted) return;

        _historyStateReady = true;
        setState(() {
          _generationCompleted = _textController.text.trim().isNotEmpty;
        });
        return;
      }

      if (widget.shouldNeedToCall && widget.onGenerate != null) {
        await _startGeneration(widget.textToGive);
      } else {
        setState(() {
          _generationCompleted = true;
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    if (widget.isFromSave && _historyStateReady && !widget.isBookMode) {
      _scheduleHistoryAutosave();
    }

    if (widget.isBookMode && _bookStateReady) {
      _scheduleBookDesignAutosave();
    }
  }

  void _scheduleHistoryAutosave() {
    _historyAutosaveTimer?.cancel();
    _historyAutosaveTimer = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted || !widget.isFromSave || !_historyStateReady) return;
      await _updateExistingEntry();
    });
  }

  String get _bookDesignKey => 'bookDesignV1_${widget.bookId.trim()}';

  void _handleBookTextChanged() {
    if (!widget.isBookMode ||
        widget.isBookFullView ||
        !_bookStateReady ||
        widget.onBookTextChanged == null) {
      return;
    }

    _bookTextAutosaveTimer?.cancel();
    _bookTextAutosaveTimer = Timer(
      const Duration(milliseconds: 450),
      () async {
        if (!mounted || widget.onBookTextChanged == null) return;
        await widget.onBookTextChanged!(_textController.text);
      },
    );
  }

  void _scheduleBookDesignAutosave() {
    _bookDesignAutosaveTimer?.cancel();
    _bookDesignAutosaveTimer = Timer(
      const Duration(milliseconds: 250),
      () async {
        if (!mounted || !widget.isBookMode || !_bookStateReady) return;
        await _saveBookDesign();
      },
    );
  }

  Future<void> _saveBookDesign() async {
    if (!widget.isBookMode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookDesignKey,
      jsonEncode({
        'themeId': _themeId,
        'textStyle': _currentTextStyleData(),
        'design': _currentDesignData(),
      }),
    );
  }

  Future<void> _restoreBookDesign() async {
    if (!widget.isBookMode) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookDesignKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final data = Map<String, dynamic>.from(decoded);
      final styleRaw = data['textStyle'];
      final designRaw = data['design'];

      final style = styleRaw is Map
          ? Map<String, dynamic>.from(styleRaw)
          : <String, dynamic>{};
      final design = designRaw is Map
          ? Map<String, dynamic>.from(designRaw)
          : <String, dynamic>{};

      final alignmentIndex =
          (_nullableInt(style['textAlignment']) ?? TextAlign.left.index)
              .clamp(0, TextAlign.values.length - 1);

      final backgroundColorValue = _nullableInt(design['backgroundColor']);
      final forcedTextColorValue = _nullableInt(design['forcedTextColor']);
      final textureIndex = _nullableInt(style['textureIndex']);

      List<Color>? restoredGradient;
      final gradientRaw = design['backgroundGradient'];
      if (gradientRaw is List && gradientRaw.isNotEmpty) {
        restoredGradient = gradientRaw
            .map(_nullableInt)
            .whereType<int>()
            .map(Color.new)
            .toList();
        if (restoredGradient.isEmpty) restoredGradient = null;
      }

      if (!mounted) return;

      setState(() {
        _themeId = (data['themeId'] ?? widget.themeId).toString();

        _fontSize = _doubleValue(style['fontSize'], 16);
        _fontWeight =
            style['isBold'] == true ? FontWeight.bold : FontWeight.w500;
        _fontStyle =
            style['isItalic'] == true ? FontStyle.italic : FontStyle.normal;
        _underline = style['isUnderlined'] == true;
        _textAlign = TextAlign.values[alignmentIndex];

        final family = style['fontFamily']?.toString().trim();
        _fontFamily =
            family == null || family.isEmpty ? 'sans-serif' : family;

        _textOpacity =
            _doubleValue(style['textOpacity'], 1.0).clamp(0.1, 1.0);
        _lineSpacing =
            _doubleValue(style['lineSpacing'], 1.6).clamp(0.8, 3.0);
        _letterSpacing =
            _doubleValue(style['letterSpacing'], 0.0).clamp(-2.0, 10.0);
        _paragraphSpacing =
            _doubleValue(style['paragraphSpacing'], 0.0).clamp(0.0, 60.0);
        _textWidth =
            _doubleValue(style['textWidth'], 1.0).clamp(0.4, 1.0);
        _pageMargins =
            _doubleValue(style['pageMargins'], 15.0).clamp(0.0, 80.0);

        final textColorValue = _nullableInt(style['textColor']);
        _textColor = textColorValue == null
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF171717))
            : Color(textColorValue);

        _textGradientIndex = _nullableInt(style['textGradientIndex']);
        _textureIndex = textureIndex;

        _backgroundColor =
            backgroundColorValue == null ? null : Color(backgroundColorValue);
        _backgroundGradient = restoredGradient;

        _backgroundAsset = design['backgroundAsset']?.toString();
        if (_backgroundAsset != null && _backgroundAsset!.trim().isEmpty) {
          _backgroundAsset = null;
        }

        _backgroundNetworkUrl = design['backgroundNetworkUrl']?.toString();
        if (_backgroundNetworkUrl != null &&
            _backgroundNetworkUrl!.trim().isEmpty) {
          _backgroundNetworkUrl = null;
        }

        _forcedTextColor =
            forcedTextColorValue == null ? null : Color(forcedTextColorValue);
      });

      if (textureIndex != null) {
        await _loadTextTexture(textureIndex);
      }
    } catch (error) {
      debugPrint('Unable to restore book design: $error');
    }
  }

  Future<void> _flushBookState() async {
    if (!widget.isBookMode) return;

    _bookDesignAutosaveTimer?.cancel();
    _bookTextAutosaveTimer?.cancel();

    await _saveBookDesign();

    if (widget.onBookTextChanged != null) {
      await widget.onBookTextChanged!(_textController.text);
    }
  }

  @override
  void dispose() {
    _historyAutosaveTimer?.cancel();
    _bookDesignAutosaveTimer?.cancel();
    _bookTextAutosaveTimer?.cancel();
    _textController.removeListener(_handleBookTextChanged);
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

  Future<void> _openHistoryAndCloseEditors() async {
    if (!mounted) return;

    saveVcHistoryRevision.value++;
    saveVcOpenHistoryRequest.value++;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleBackToHistory() async {
    if (widget.isBookMode) {
      await _flushBookState();
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    if (_isNavigatingToHistory) return;
    _isNavigatingToHistory = true;

    _historyAutosaveTimer?.cancel();

    if (_isGenerating) {
      try {
        EasySeekApiManager.shared.stopStreaming();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }

    final text = _textController.text.trim();

    if (text.isNotEmpty) {
      if (widget.isFromSave) {
        await _updateExistingEntry();
      } else {
        final fallbackTitle = _title.trim().isEmpty
            ? (widget.contentType.toLowerCase() == 'poem'
                ? 'AI Poem'
                : 'AI Story')
            : _title.trim();

        await _saveNewEntry(title: fallbackTitle);
      }

      if (widget.onSaved != null) {
        await widget.onSaved!();
      }
    }

    if (!mounted) return;
    await _openHistoryAndCloseEditors();
  }

  Future<void> _save() async {
    if (widget.isBookMode) {
      await _flushBookState();
      if (!mounted) return;
      _showMessage('Chapter and book design saved.');
      return;
    }

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
    await _openHistoryAndCloseEditors();
  }

  Future<String?> _askForStoryTitle() async {
    String typedTitle = _title == 'AI Story' ? '' : _title;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Story Title'),
          content: TextFormField(
            initialValue: typedTitle,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Enter Title',
            ),
            onChanged: (value) {
              typedTitle = value;
            },
            onFieldSubmitted: (value) {
              final title = value.trim();
              if (title.isNotEmpty) {
                Navigator.of(dialogContext).pop(title);
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
                final title = typedTitle.trim();
                if (title.isNotEmpty) {
                  Navigator.of(dialogContext).pop(title);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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

  Map<String, dynamic> _currentTextStyleData() {
    return {
      'fontName': 'PlusJakartaSans-Medium',
      'fontSize': _fontSize,
      'isBold': _fontWeight == FontWeight.bold,
      'isItalic': _fontStyle == FontStyle.italic,
      'isUnderlined': _underline,
      'textAlignment': _textAlign.index,
      'textureIndex': _textureIndex,
      'fontFamily': _fontFamily,
      'textOpacity': _textOpacity,
      'lineSpacing': _lineSpacing,
      'letterSpacing': _letterSpacing,
      'paragraphSpacing': _paragraphSpacing,
      'textWidth': _textWidth,
      'pageMargins': _pageMargins,
      'textColor': _textColor.value,
      'textGradientIndex': _textGradientIndex,
    };
  }

  Map<String, dynamic> _currentDesignData() {
    return {
      'backgroundColor': _backgroundColor?.value,
      'backgroundGradient':
          _backgroundGradient?.map((color) => color.value).toList(),
      'backgroundAsset': _backgroundAsset,
      'backgroundNetworkUrl': _backgroundNetworkUrl,
      'forcedTextColor': _forcedTextColor?.value,
    };
  }

  double _doubleValue(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> _restoreHistoryEntry() async {
    final entries = await _readEntries();

    if (widget.currentIndex < 0 || widget.currentIndex >= entries.length) {
      return;
    }

    final entry = entries[widget.currentIndex];
    final styleRaw = entry['textStyle'];
    final designRaw = entry['design'];

    final style = styleRaw is Map
        ? Map<String, dynamic>.from(styleRaw)
        : <String, dynamic>{};

    final design = designRaw is Map
        ? Map<String, dynamic>.from(designRaw)
        : <String, dynamic>{};

    final restoredTextureIndex = _nullableInt(style['textureIndex']);
    final restoredGradientIndex = _nullableInt(style['textGradientIndex']);

    final alignmentIndex =
        (_nullableInt(style['textAlignment']) ?? TextAlign.left.index)
            .clamp(0, TextAlign.values.length - 1);

    final backgroundColorValue = _nullableInt(design['backgroundColor']);
    final forcedTextColorValue = _nullableInt(design['forcedTextColor']);

    List<Color>? restoredBackgroundGradient;
    final gradientRaw = design['backgroundGradient'];
    if (gradientRaw is List && gradientRaw.isNotEmpty) {
      restoredBackgroundGradient = gradientRaw
          .map(_nullableInt)
          .whereType<int>()
          .map(Color.new)
          .toList();

      if (restoredBackgroundGradient.isEmpty) {
        restoredBackgroundGradient = null;
      }
    }

    if (!mounted) return;

    setState(() {
      _textController.text = (entry['text'] ?? widget.textToGive).toString();
      _title = (entry['title'] ?? widget.mainTitle).toString();
      _isFavorite = entry['isFav'] == true;
      _themeId = (entry['themeId'] ?? widget.themeId).toString();

      _fontSize = _doubleValue(style['fontSize'], 16);
      _fontWeight =
          style['isBold'] == true ? FontWeight.bold : FontWeight.w500;
      _fontStyle =
          style['isItalic'] == true ? FontStyle.italic : FontStyle.normal;
      _underline = style['isUnderlined'] == true;
      _textAlign = TextAlign.values[alignmentIndex];

      final savedFontFamily = style['fontFamily']?.toString().trim();
      _fontFamily =
          savedFontFamily == null || savedFontFamily.isEmpty
              ? 'sans-serif'
              : savedFontFamily;

      _textOpacity =
          _doubleValue(style['textOpacity'], 1.0).clamp(0.1, 1.0);
      _lineSpacing =
          _doubleValue(style['lineSpacing'], 1.6).clamp(0.8, 3.0);
      _letterSpacing =
          _doubleValue(style['letterSpacing'], 0.0).clamp(-2.0, 10.0);
      _paragraphSpacing =
          _doubleValue(style['paragraphSpacing'], 0.0).clamp(0.0, 60.0);
      _textWidth =
          _doubleValue(style['textWidth'], 1.0).clamp(0.4, 1.0);
      _pageMargins =
          _doubleValue(style['pageMargins'], 15.0).clamp(0.0, 80.0);

      final textColorValue = _nullableInt(style['textColor']);
      _textColor = textColorValue == null
          ? (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF171717))
          : Color(textColorValue);

      _textGradientIndex = restoredGradientIndex;
      _textureIndex = restoredTextureIndex;

      _backgroundColor = backgroundColorValue == null
          ? null
          : Color(backgroundColorValue);
      _backgroundGradient = restoredBackgroundGradient;
      _backgroundAsset = design['backgroundAsset']?.toString();
      if (_backgroundAsset != null && _backgroundAsset!.trim().isEmpty) {
        _backgroundAsset = null;
      }

      _backgroundNetworkUrl = design['backgroundNetworkUrl']?.toString();
      if (_backgroundNetworkUrl != null &&
          _backgroundNetworkUrl!.trim().isEmpty) {
        _backgroundNetworkUrl = null;
      }

      _forcedTextColor = forcedTextColorValue == null
          ? null
          : Color(forcedTextColorValue);
    });

    if (restoredTextureIndex != null) {
      await _loadTextTexture(restoredTextureIndex);
    }
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
      'textStyle': _currentTextStyleData(),
      'design': _currentDesignData(),
    });

    await _writeEntries(entries);
    saveVcHistoryRevision.value++;
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
    entry['textStyle'] = _currentTextStyleData();
    entry['design'] = _currentDesignData();

    await _writeEntries(entries);
    saveVcHistoryRevision.value++;
  }

  Future<void> _updateExistingEntryTitle(String title) async {
    final entries = await _readEntries();
    if (widget.currentIndex < 0 || widget.currentIndex >= entries.length) {
      return;
    }
    entries[widget.currentIndex]['title'] = title;
    await _writeEntries(entries);
    saveVcHistoryRevision.value++;
  }

  Future<void> _updateExistingFavoriteState() async {
    final entries = await _readEntries();
    if (widget.currentIndex < 0 || widget.currentIndex >= entries.length) {
      return;
    }
    entries[widget.currentIndex]['isFav'] = _isFavorite;
    await _writeEntries(entries);
    saveVcHistoryRevision.value++;
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

      // Reset follows the CURRENT app appearance immediately:
      // Dark Mode  -> white text
      // Light Mode -> black text
      _textColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF171717);

      _textGradientIndex = null;
      _textEditorTab = 0;
      _backgroundColor = null;
      _backgroundGradient = null;
      _backgroundAsset = null;
      _backgroundNetworkUrl = null;
      _forcedTextColor = null;
      _textureIndex = null;
      _textTextureImage = null;
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

    final result = await Navigator.of(context).push<_ThemeSelection>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _ThemePickerScreen(),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      switch (result.type) {
        case _ThemeSelectionType.none:
          _backgroundColor = null;
          _backgroundGradient = null;
          _backgroundAsset = null;
          _backgroundNetworkUrl = null;
          _forcedTextColor = null;
          _themeId = 'none';
          break;

        case _ThemeSelectionType.color:
          _backgroundColor = result.color;
          _backgroundGradient = null;
          _backgroundAsset = null;
          _backgroundNetworkUrl = null;
          _forcedTextColor = null;

          final value = result.color?.value ?? Colors.white.value;
          _themeId =
              'color:${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
          break;

        case _ThemeSelectionType.gradient:
          _backgroundColor = null;
          _backgroundGradient = result.gradient;
          _backgroundAsset = null;
          _backgroundNetworkUrl = null;
          _forcedTextColor = null;
          _themeId = 'gradient:${result.gradientIndex ?? 0}';
          break;

        case _ThemeSelectionType.theme:
          _backgroundColor = null;
          _backgroundGradient = null;
          _backgroundAsset = null;
          _backgroundNetworkUrl = result.themeUrl;
          _themeId = 'theme:${result.themeId ?? ''}';

          // Same iOS rule: Firebase theme name "white" means white interface.
          _forcedTextColor =
              result.themeName?.toLowerCase() == 'white'
                  ? Colors.white
                  : Colors.black;
          break;
      }
    });
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
    if (_backgroundNetworkUrl != null &&
        _backgroundNetworkUrl!.trim().isNotEmpty) {
      return BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            _themeDisplayUrl(_backgroundNetworkUrl!, width: 1200),
          ),
          fit: BoxFit.cover,
        ),
      );
    }

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

    Color resolvedTextColor = _forcedTextColor ?? _textColor;

    // History can contain a white forcedTextColor saved while the app was
    // in Dark Mode. If the story is using the normal app background, that
    // stale value must not be reused in Light Mode or the text becomes white
    // on white. Treat the app's old default dark/white colors as automatic.
    if (!_hasCustomStoryBackground) {
      final forcedValue = _forcedTextColor?.value;
      final textValue = _textColor.value;

      final looksLikeAutomaticDefault =
          forcedValue == null ||
          forcedValue == Colors.white.value ||
          forcedValue == const Color(0xFF171717).value ||
          textValue == Colors.white.value ||
          textValue == const Color(0xFF171717).value;

      if (looksLikeAutomaticDefault) {
        resolvedTextColor = Theme.of(context).colorScheme.onSurface;
      }
    }

    final baseColor =
        resolvedTextColor.withValues(alpha: _textOpacity);

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackToHistory();
        }
      },
      child: _buildSaveContent(context),
    );
  }

  Widget _buildSaveContent(BuildContext context) {
    final interfaceColor = _interfaceColor;

    if (_isFullScreen) {
      final mediaPadding = MediaQuery.paddingOf(context);

      return Scaffold(
        backgroundColor: _backgroundColor ?? _pageBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: _storyBackgroundDecoration(),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  26,
                  mediaPadding.top + 24,
                  26,
                  mediaPadding.bottom + 24,
                ),
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
              top: mediaPadding.top + 8,
              right: 8,
              child: IconButton.filledTonal(
                onPressed: () => setState(() => _isFullScreen = false),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      body: Container(
        decoration: _storyBackgroundDecoration(),
        child: Stack(
          children: [
            SafeArea(
            child: Column(
              children: [
                _buildTopBar(interfaceColor),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                    child: Opacity(
                      opacity: _isGenerating ? 0.72 : 1,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Column(
                          children: [
                            AbsorbPointer(
                              absorbing: _isGenerating,
                              child: _buildStoryHeader(interfaceColor),
                            ),
                            Expanded(
                              child: AbsorbPointer(
                                absorbing: _isGenerating,
                                child: _buildStoryEditor(interfaceColor),
                              ),
                            ),
                            _buildBottomBar(interfaceColor),
                          ],
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
            onPressed: _handleBackToHistory,
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
                readOnly: _isGenerating || widget.isBookFullView,
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

  Widget _buildBookChapterNavigation(Color interfaceColor) {
    final muted = interfaceColor.withValues(alpha: 0.42);

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: widget.hasBookPrevious &&
                      widget.onBookPrevious != null &&
                      !_isGenerating
                  ? () async {
                      await _flushBookState();
                      if (!mounted) return;
                      await widget.onBookPrevious!();
                    }
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('Previous'),
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.hasBookPrevious ? interfaceColor : muted,
              ),
            ),
          ),
          if (widget.bookChapterCount > 0)
            Text(
              '${widget.bookChapterNumber} / ${widget.bookChapterCount}',
              style: TextStyle(
                color: interfaceColor.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          Expanded(
            child: TextButton.icon(
              onPressed: widget.hasBookNext &&
                      widget.onBookNext != null &&
                      !_isGenerating
                  ? () async {
                      await _flushBookState();
                      if (!mounted) return;
                      await widget.onBookNext!();
                    }
                  : null,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('Next'),
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.hasBookNext ? interfaceColor : muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color interfaceColor) {
    final actionBar = SizedBox(
      height: 60,
      child: Row(
        children: [
          _bottomImageButton(
            path: _isFavorite
                ? 'assets/images/full.png'
                : 'assets/images/empty.png',
            onPressed:
                (_isGenerating || widget.isBookMode) ? null : _toggleFavorite,
            tint: interfaceColor,
          ),
          const SizedBox(width: 10),
          _bottomIconButton(
            icon: Icons.wallpaper_rounded,
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

    if (!widget.isBookMode || widget.isBookFullView) return actionBar;

    return SizedBox(
      height: 108,
      child: Column(
        children: [
          _buildBookChapterNavigation(interfaceColor),
          actionBar,
        ],
      ),
    );
  }

  Widget _buildGeneratingOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
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



String _googleDriveFileId(String url) {
  final trimmed = url.trim();

  try {
    final uri = Uri.parse(trimmed);

    // https://drive.google.com/uc?export=download&id=FILE_ID
    final queryId = uri.queryParameters['id'];
    if (queryId != null && queryId.isNotEmpty) {
      return queryId;
    }

    // https://drive.google.com/file/d/FILE_ID/view
    final segments = uri.pathSegments;
    final dIndex = segments.indexOf('d');
    if (dIndex >= 0 && dIndex + 1 < segments.length) {
      return segments[dIndex + 1];
    }

    // https://drive.usercontent.google.com/download?id=FILE_ID...
    if (uri.host.contains('drive.usercontent.google.com')) {
      return queryId ?? '';
    }
  } catch (_) {
    // Keep fallback below.
  }

  final match = RegExp(r'[?&]id=([^&]+)').firstMatch(trimmed);
  return match?.group(1) ?? '';
}

String _themeDisplayUrl(
  String original, {
  int width = 1200,
}) {
  final fileId = _googleDriveFileId(original);

  if (fileId.isEmpty) {
    return original.trim();
  }

  // Google Drive "uc?export=download" frequently redirects to
  // drive.usercontent.google.com and can close the connection midway.
  // The thumbnail endpoint is intended for image delivery and is much
  // more reliable for displaying Drive-hosted images in Flutter.
  return Uri.https(
    'drive.google.com',
    '/thumbnail',
    <String, String>{
      'id': fileId,
      'sz': 'w$width',
    },
  ).toString();
}


enum _ThemeSelectionType {
  none,
  color,
  gradient,
  theme,
}

class _ThemeSelection {
  const _ThemeSelection._({
    required this.type,
    this.color,
    this.gradient,
    this.gradientIndex,
    this.themeId,
    this.themeName,
    this.themeUrl,
  });

  const _ThemeSelection.none()
      : this._(type: _ThemeSelectionType.none);

  const _ThemeSelection.color(Color color)
      : this._(
          type: _ThemeSelectionType.color,
          color: color,
        );

  const _ThemeSelection.gradient(
    List<Color> gradient,
    int index,
  ) : this._(
          type: _ThemeSelectionType.gradient,
          gradient: gradient,
          gradientIndex: index,
        );

  const _ThemeSelection.theme({
    required String id,
    required String name,
    required String url,
  }) : this._(
          type: _ThemeSelectionType.theme,
          themeId: id,
          themeName: name,
          themeUrl: url,
        );

  final _ThemeSelectionType type;
  final Color? color;
  final List<Color>? gradient;
  final int? gradientIndex;
  final String? themeId;
  final String? themeName;
  final String? themeUrl;
}

class _ThemePickerScreen extends StatefulWidget {
  const _ThemePickerScreen();

  @override
  State<_ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<_ThemePickerScreen> {
  final RealtimeDBManager _realtimeDBManager = RealtimeDBManager();

  static List<ThemeItem>? _cachedThemes;

  int _selectedTab = 0; // Video order: Theme, Color, Gradient.
  bool _isLoadingThemes = true;
  List<ThemeItem> _themes = const [];

  static const List<Color> _colors = [
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFFF8B011),
    Color(0xFFEA5D9A),
    Color(0xFFF6864B),
    Color(0xFFFFE07A),
    Color(0xFF00A34C),
    Color(0xFFF9DDAE),
    Color(0xFFC7DB66),
    Color(0xFFE1F179),
    Color(0xFF00A6D1),
    Color(0xFFC0EAF2),
    Color(0xFF00B894),
    Color(0xFF94FFEB),
    Color(0xFF1F4CAD),
    Color(0xFFCACDE8),
    Color(0xFF019EDF),
    Color(0xFF80D0FF),
    Color(0xFFD21D8D),
    Color(0xFFE1C2AD),
    Color(0xFF6A5FAA),
    Color(0xFF8C80F5),
    Color(0xFFE62E34),
    Color(0xFFE58090),
    Color(0xFFEE5890),
    Color(0xFF5BBD76),
    Color(0xFF798D71),
    Color(0xFFEFDDCC),
    Color(0xFF01C0DF),
    Color(0xFFF19EB8),
    Color(0xFF8F786B),
    Color(0xFFE7AB83),
    Color(0xFF2A65B6),
    Color(0xFFCA68A6),
    Color(0xFFBFBFBF),
    Color(0xFFB270FF),
    Color(0xFFCFFFBD),
    Color(0xFFF05E57),
    Color(0xFFE7602C),
    Color(0xFFFD5E7B),
    Color(0xFF99EFFF),
    Color(0xFFCFB395),
    Color(0xFF91BF40),
    Color(0xFFCAB1D2),
    Color(0xFF898D81),
    Color(0xFF01AC84),
    Color(0xFFDAE9C3),
    Color(0xFF8F6356),
    Color(0xFF0174C1),
    Color(0xFFDF9C7C),
    Color(0xFFFEF8C3),
    Color(0xFF7F3B9B),
    Color(0xFFF7E289),
    Color(0xFFB9E0F9),
    Color(0xFFEE3584),
    Color(0xFF8AC3D4),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFFA78BFA),
    Color(0xFF55EFC4),
    Color(0xFFFF9E7D),
    Color(0xFF6BD6FF),
    Color(0xFFFFD166),
    Color(0xFF7BEFB2),
    Color(0xFFD4A5A5),
    Color(0xFFFFDD59),
    Color(0xFFA2D2FF),
    Color(0xFFCDB4DB),
    Color(0xFFFFAFCC),
    Color(0xFFBDE0FE),
    Color(0xFFFFC8DD),
    Color(0xFFA0E7E5),
    Color(0xFFFF85A1),
    Color(0xFFFEE440),
    Color(0xFF00BBF9),
    Color(0xFFFF5E5B),
    Color(0xFF9BF6FF),
    Color(0xFFCAFFBF),
    Color(0xFFFDFFB6),
    Color(0xFFBDB2FF),
    Color(0xFFFFC6FF),
    Color(0xFFA0C4FF),
    Color(0xFFFDFFAB),
    Color(0xFFD9ED92),
    Color(0xFFB5E48C),
    Color(0xFF99D98C),
    Color(0xFF76C893),
    Color(0xFF52B69A),
    Color(0xFF34A0A4),
    Color(0xFF168AAD),
    Color(0xFF1A759F),
  ];

  static const List<List<Color>> _gradients = [
    [Color(0xFFEA84DD), Color(0xFF97E3EF)],
    [Color(0xFFEB5372), Color(0xFFF3B39D)],
    [Color(0xFFA9A0FF), Color(0xFFCD81E7)],
    [Color(0xFFFFE3FB), Color(0xFFC4F7FF)],
    [Color(0xFFF08AE7), Color(0xFFFF557C)],
    [Color(0xFF6190E8), Color(0xFFA7BFE8)],
    [Color(0xFF4AFAEF), Color(0xFFE0F793)],
    [Color(0xFFDCEA7A), Color(0xFFBB9BF7)],
    [Color(0xFFF6CD68), Color(0xFFFF9B6A)],
    [Color(0xFFF2D850), Color(0xFFF657AA)],
    [Color(0xFFFFB082), Color(0xFFFF67E2)],
    [Color(0xFF8575FA), Color(0xFFD77CED)],
    [Color(0xFF04BEFD), Color(0xFF86FBB7)],
    [Color(0xFFEA8A97), Color(0xFFAEBBF3)],
    [Color(0xFF37F0CB), Color(0xFFEEED40)],
    [Color(0xFFF6C6F9), Color(0xFFAC93FF)],
    [Color(0xFFFF8AAD), Color(0xFF9FFFAD)],
    [Color(0xFF55BBF9), Color(0xFFA9FCB9)],
    [Color(0xFFEF629F), Color(0xFFEECDA3)],
    [Color(0xFF9CE9A4), Color(0xFFD6718E)],
    [Color(0xFFEF85FC), Color(0xFF8686FF)],
    [Color(0xFFFACCC1), Color(0xFFFDA7A7)],
    [Color(0xFF7F8DC3), Color(0xFFED99AE)],
    [Color(0xFFFDD648), Color(0xFFFA7C90)],
    [Color(0xFFBA94F9), Color(0xFF8572F0)],
    [Color(0xFF767AE5), Color(0xFFF3DCE4)],
    [Color(0xFFFFD900), Color(0xFFFF6B90)],
    [Color(0xFFFF7F66), Color(0xFFE03883)],
    [Color(0xFF00B1C0), Color(0xFF95E587)],
    [Color(0xFFF9C58D), Color(0xFFF492F0)],
    [Color(0xFF9FEDF9), Color(0xFFF7C7C3)],
    [Color(0xFFF0FD89), Color(0xFFA4E018)],
    [Color(0xFFFF0097), Color(0xFFFC7373)],
    [Color(0xFF6C94EE), Color(0xFF11CDF7)],
    [Color(0xFFFF4370), Color(0xFFFFAF98)],
    [Color(0xFF27B7E9), Color(0xFFE078F1)],
    [Color(0xFF13E1F9), Color(0xFF8AE7AD)],
    [Color(0xFFF7857E), Color(0xFFCCFAD2)],
    [Color(0xFFFCBC9C), Color(0xFF6EE7A8)],
    [Color(0xFFEFA2AC), Color(0xFFFED8DC)],
    [Color(0xFFFA4545), Color(0xFFF57073)],
    [Color(0xFFFA7099), Color(0xFFFF7040)],
    [Color(0xFFF094FA), Color(0xFFF5576E)],
    [Color(0xFFFF144E), Color(0xFFF17550)],
    [Color(0xFFFF0845), Color(0xFF97E3EF)],
    [Color(0xFFFF5208), Color(0xFFF29393)],
    [Color(0xFFFA4545), Color(0xFFFAC74D)],
    [Color(0xFFFF8C21), Color(0xFFFFE040)],
    [Color(0xFFFF8C21), Color(0xFFF5576E)],
    [Color(0xFFFF8C21), Color(0xFFFF6121)],
    [Color(0xFFFF8C21), Color(0xFFFFB099)],
    [Color(0xFFFF8C21), Color(0xFFE5F294)],
    [Color(0xFFCCC938), Color(0xFFF2C754)],
    [Color(0xFFA3DE61), Color(0xFFF0CF29)],
    [Color(0xFFEBC43D), Color(0xFFFFD18F)],
    [Color(0xFFF5ED47), Color(0xFF80F5E8)],
    [Color(0xFFF5FFA6), Color(0xFFF5B080)],
    [Color(0xFFF5FFA6), Color(0xFFF5E380)],
    [Color(0xFFD4FC79), Color(0xFF96E6A1)],
    [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    [Color(0xFF2AF598), Color(0xFF009EFD)],
    [Color(0xFF37ECBA), Color(0xFF72AFD3)],
    [Color(0xFF37ECBA), Color(0xFF75D473)],
    [Color(0xFF3A65D3), Color(0xFF75D473)],
    [Color(0xFF0538FF), Color(0xFF70E3F5)],
    [Color(0xFF0538FF), Color(0xFF40FFC7)],
    [Color(0xFF0538FF), Color(0xFF6B57F5)],
    [Color(0xFF1F4CFF), Color(0xFF6197E4)],
    [Color(0xFF0538FF), Color(0xFF5799F7)],
    [Color(0xFF0596FF), Color(0xFF5799F7)],
    [Color(0xFF30D8EE), Color(0xFF3E89F5)],
    [Color(0xFF3D8CFA), Color(0xFF40FFC7)],
    [Color(0xFF94EDFA), Color(0xFF6B57F5)],
    [Color(0xFF08F0FF), Color(0xFF3C89F6)],
    [Color(0xFF08E3FF), Color(0xFF5799F7)],
    [Color(0xFF08FFB8), Color(0xFF5799F7)],
    [Color(0xFFC238CC), Color(0xFFB554F2)],
    [Color(0xFFA6E8FF), Color(0xFFB280F5)],
    [Color(0xFFB23DEB), Color(0xFFDE8FFF)],
    [Color(0xFF3D73EB), Color(0xFFDE8FFF)],
    [Color(0xFFCCFFA6), Color(0xFFB280F5)],
    [Color(0xFFF3A6FF), Color(0xFFB280F5)],
  ];

  @override
  void initState() {
    super.initState();

    final cached = _cachedThemes;
    if (cached != null && cached.isNotEmpty) {
      _themes = List<ThemeItem>.of(cached);
      _isLoadingThemes = false;
    } else {
      _loadThemes();
    }
  }

  Future<void> _loadThemes() async {
    try {
      final fetchedValues = await _realtimeDBManager.fetchAllThemes();
      final values = List<ThemeItem>.of(fetchedValues);

      values.sort((a, b) {
        final ai = int.tryParse(a.id) ?? 1 << 30;
        final bi = int.tryParse(b.id) ?? 1 << 30;
        return ai.compareTo(bi);
      });

      _cachedThemes = List<ThemeItem>.of(values);

      if (!mounted) return;
      setState(() {
        _themes = values;
        _isLoadingThemes = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        for (final theme in values.take(12)) {
          precacheImage(
            CachedNetworkImageProvider(_themeDisplayUrl(theme.url, width: 1200)),
            context,
          ).catchError((_) {});
        }
      });
    } catch (error) {
      debugPrint('Unable to load themes: $error');

      if (!mounted) return;
      setState(() {
        _themes = _cachedThemes ?? const [];
        _isLoadingThemes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final background =
        Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111111)
            : const Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Themes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          _buildSegmentedControl(),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_selectedTab) {
                0 => _buildThemeGrid(),
                1 => _buildColorGrid(),
                _ => _buildGradientGrid(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shell =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE9E9EB);
    final selected =
        isDark ? const Color(0xFF48484A) : Colors.white;

    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: shell,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentItem('Theme', 0, selected),
          _segmentItem('Color', 1, selected),
          _segmentItem('Gradient', 2, selected),
        ],
      ),
    );
  }

  Widget _segmentItem(
    String title,
    int index,
    Color selectedColor,
  ) {
    final active = _selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_selectedTab == index) return;
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [
                  BoxShadow(
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _grid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return GridView.builder(
      key: ValueKey(_selectedTab),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 900 / 1600,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  Widget _buildThemeGrid() {
    if (_isLoadingThemes) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return _grid(
      itemCount: _themes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: () {
              Navigator.of(context).pop(
                const _ThemeSelection.none(),
              );
            },
            borderRadius: BorderRadius.circular(2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.block,
                  size: 62,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }

        final theme = _themes[index - 1];

        return InkWell(
          onTap: () async {
            final displayUrl = _themeDisplayUrl(theme.url, width: 1200);

            try {
              await precacheImage(
                CachedNetworkImageProvider(displayUrl),
                context,
              );
            } catch (error) {
              debugPrint('Unable to precache selected theme: $error');
            }

            if (!mounted) return;

            Navigator.of(context).pop(
              _ThemeSelection.theme(
                id: theme.id,
                name: theme.name,
                url: theme.url,
              ),
            );
          },
          child: ClipRect(
            child: CachedNetworkImage(
              imageUrl: _themeDisplayUrl(theme.url, width: 1200),
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (_, url, error) {
                debugPrint(
                  '❌ THEME IMAGE LOAD FAILED: ${theme.url}\n'
                  '❌ DISPLAY URL: $url\n'
                  '❌ IMAGE ERROR: $error',
                );

                return Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorGrid() {
    return _grid(
      itemCount: _colors.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: _openCustomColorPicker,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: const Icon(
                Icons.palette,
                size: 62,
                color: Color(0xFFC52CE8),
              ),
            ),
          );
        }

        final color = _colors[index - 1];

        return InkWell(
          onTap: () {
            Navigator.of(context).pop(
              _ThemeSelection.color(color),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: color == Colors.white
                    ? Colors.black12
                    : Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientGrid() {
    return _grid(
      itemCount: _gradients.length,
      itemBuilder: (context, index) {
        final gradient = _gradients[index];

        return InkWell(
          onTap: () {
            Navigator.of(context).pop(
              _ThemeSelection.gradient(
                gradient,
                index,
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCustomColorPicker() async {
    double red = 197;
    double green = 44;
    double blue = 232;

    final color = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final preview = Color.fromARGB(
              255,
              red.round(),
              green.round(),
              blue.round(),
            );

            return AlertDialog(
              title: const Text('Choose Color'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: preview,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _rgbSlider(
                      'R',
                      red,
                      (value) => setDialogState(() => red = value),
                    ),
                    _rgbSlider(
                      'G',
                      green,
                      (value) => setDialogState(() => green = value),
                    ),
                    _rgbSlider(
                      'B',
                      blue,
                      (value) => setDialogState(() => blue = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(preview);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (color == null || !mounted) return;

    Navigator.of(context).pop(
      _ThemeSelection.color(color),
    );
  }

  Widget _rgbSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
