import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (widget.hasTag.trim().isEmpty) return '';
    return widget.hasTag
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
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            void update(VoidCallback callback) {
              setState(callback);
              sheetSetState(() {});
            }

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
                            'Text Style',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Size'),
                        Expanded(
                          child: Slider(
                            min: 12,
                            max: 30,
                            value: _fontSize,
                            onChanged: (value) {
                              update(() => _fontSize = value);
                            },
                          ),
                        ),
                        Text(_fontSize.round().toString()),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _styleChoice(
                          label: 'Bold',
                          selected: _fontWeight == FontWeight.bold,
                          onTap: () => update(() {
                            _fontWeight = _fontWeight == FontWeight.bold
                                ? FontWeight.w500
                                : FontWeight.bold;
                          }),
                        ),
                        _styleChoice(
                          label: 'Italic',
                          selected: _fontStyle == FontStyle.italic,
                          onTap: () => update(() {
                            _fontStyle = _fontStyle == FontStyle.italic
                                ? FontStyle.normal
                                : FontStyle.italic;
                          }),
                        ),
                        _styleChoice(
                          label: 'Underline',
                          selected: _underline,
                          onTap: () => update(() => _underline = !_underline),
                        ),
                        _styleChoice(
                          label: 'Left',
                          selected: _textAlign == TextAlign.left,
                          onTap: () => update(() => _textAlign = TextAlign.left),
                        ),
                        _styleChoice(
                          label: 'Center',
                          selected: _textAlign == TextAlign.center,
                          onTap: () => update(() => _textAlign = TextAlign.center),
                        ),
                        _styleChoice(
                          label: 'Right',
                          selected: _textAlign == TextAlign.right,
                          onTap: () => update(() => _textAlign = TextAlign.right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 22,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = _textureIndex == index;
                          return GestureDetector(
                            onTap: () => update(() {
                              _textureIndex = selected ? null : index;
                            }),
                            child: Container(
                              width: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: selected ? 2 : 1,
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).dividerColor,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/texture$index.png',
                                  ),
                                  fit: BoxFit.cover,
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
      },
    );
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

  TextStyle get _storyTextStyle {
    return TextStyle(
      fontSize: _fontSize,
      height: 1.6,
      fontWeight: _fontWeight,
      fontStyle: _fontStyle,
      color: _interfaceColor,
      decoration: _underline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  bool get _showRegenerate {
    return widget.contentType.toLowerCase() == 'story' &&
        widget.shouldNeedToCall &&
        !widget.isFromSave &&
        _generationCompleted &&
        !_isGenerating;
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(interfaceColor),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
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
              ],
            ),
            if (_isGenerating) _buildGeneratingOverlay(),
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
          _topAssetButton(
            fallbackIcon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.maybePop(context),
            tint: interfaceColor,
          ),
          _topIconButton(
            icon: Icons.refresh,
            onPressed: _confirmResetDesign,
            tint: interfaceColor,
          ),
          const Spacer(),
          if (_showRegenerate)
            TextButton(
              onPressed: _regenerate,
              child: Text(
                'Regenerate',
                style: TextStyle(
                  color: interfaceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (widget.onMusic != null)
            _topIconButton(
              icon: Icons.music_note_outlined,
              onPressed: widget.onMusic,
              tint: interfaceColor,
            ),
          _topImageButton(
            path: 'assets/images/edit.png',
            onPressed: widget.onOpenTextEditor ?? _showTextStyleSheet,
            tint: interfaceColor,
          ),
          _topImageButton(
            path: 'assets/images/share.png',
            onPressed: _shareText,
            tint: interfaceColor,
          ),
          const SizedBox(width: 4),
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
                  onPressed: _showTextStyleSheet,
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
    if (_textureIndex != null) {
      // Flutter TextField cannot directly paint a bitmap into glyphs like
      // UIColor(patternImage:) on iOS. Keep the same selected texture available
      // to the text editor UI; exact glyph texture rendering can be layered in
      // later without changing this screen structure.
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: TextField(
        controller: _textController,
        scrollController: _scrollController,
        expands: true,
        maxLines: null,
        minLines: null,
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
            _generationCompleted = _textController.text.trim().isNotEmpty;
          }
        },
      ),
    );
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
            onPressed: _toggleFavorite,
            tint: interfaceColor,
          ),
          const SizedBox(width: 10),
          _bottomIconButton(
            icon: Icons.image_outlined,
            onPressed: _showThemeSheet,
            tint: interfaceColor,
          ),
          const SizedBox(width: 10),
          _bottomImageButton(
            path: 'assets/images/small.png',
            onPressed: _showTextStyleSheet,
            tint: interfaceColor,
          ),
          const Spacer(),
          _bottomImageButton(
            path: 'assets/images/vector_1.png',
            onPressed: () async {
              final text = _textController.text.trim();
              if (text.isEmpty) return;
              if (widget.onHearText != null) {
                await widget.onHearText!(text);
              }
            },
            tint: interfaceColor,
          ),
          _bottomImageButton(
            path: 'assets/images/group_1000004153.png',
            onPressed: _copyText,
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
            onPressed: _isGenerating
                ? () async {
                    setState(() {
                      _isGenerating = false;
                    });
                  }
                : null,
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
