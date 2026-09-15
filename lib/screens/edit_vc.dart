import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../services/realtime_db_manager.dart';

class EditVcThemeSelection {
  const EditVcThemeSelection({
    required this.themeId,
    required this.themeUrl,
    this.preferredTextColor,
  });

  final String themeId;
  final String themeUrl;
  final Color? preferredTextColor;
}

class EditVcResult {
  const EditVcResult({
    required this.text,
    required this.fontSize,
    required this.textAlign,
    required this.textColor,
    required this.backgroundColor,
    required this.backgroundGradient,
    required this.backgroundNetworkUrl,
    required this.backgroundFilePath,
    required this.themeId,
    required this.aspectRatio,
    this.fontWeight = FontWeight.w500,
    this.fontStyle = FontStyle.normal,
    this.underline = false,
    this.fontFamily = 'sans-serif',
    this.textOpacity = 1.0,
    this.lineSpacing = 1.6,
    this.letterSpacing = 0.0,
    this.paragraphSpacing = 0.0,
    this.textWidth = 1.0,
    this.pageMargins = 15.0,
    this.textGradientIndex,
    this.textureIndex,
  });

  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final Color textColor;
  final Color? backgroundColor;
  final List<Color>? backgroundGradient;
  final String? backgroundNetworkUrl;
  final String? backgroundFilePath;
  final String themeId;
  final double aspectRatio;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final bool underline;
  final String fontFamily;
  final double textOpacity;
  final double lineSpacing;
  final double letterSpacing;
  final double paragraphSpacing;
  final double textWidth;
  final double pageMargins;
  final int? textGradientIndex;
  final int? textureIndex;
}

class EditVc extends StatefulWidget {
  const EditVc({
    super.key,
    required this.text,
    required this.fontSize,
    required this.textAlign,
    required this.textColor,
    this.backgroundColor,
    this.backgroundGradient,
    this.backgroundNetworkUrl,
    this.backgroundFilePath,
    this.themeId = 'none',
    this.onPickTheme,
    this.fontWeight = FontWeight.w500,
    this.fontStyle = FontStyle.normal,
    this.underline = false,
    this.fontFamily = 'sans-serif',
    this.textOpacity = 1.0,
    this.lineSpacing = 1.6,
    this.letterSpacing = 0.0,
    this.paragraphSpacing = 0.0,
    this.textWidth = 1.0,
    this.pageMargins = 15.0,
    this.textGradientIndex,
    this.textureIndex,
  });

  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final Color textColor;
  final Color? backgroundColor;
  final List<Color>? backgroundGradient;
  final String? backgroundNetworkUrl;
  final String? backgroundFilePath;
  final String themeId;
  final Future<EditVcThemeSelection?> Function()? onPickTheme;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final bool underline;
  final String fontFamily;
  final double textOpacity;
  final double lineSpacing;
  final double letterSpacing;
  final double paragraphSpacing;
  final double textWidth;
  final double pageMargins;
  final int? textGradientIndex;
  final int? textureIndex;

  @override
  State<EditVc> createState() => _EditVcState();
}

class _EditVcState extends State<EditVc> {
  final GlobalKey _canvasKey = GlobalKey();
  late final TextEditingController _controller;
  late double _fontSize;
  late TextAlign _textAlign;
  late Color _textColor;
  late FontWeight _fontWeight;
  late FontStyle _fontStyle;
  late bool _underline;
  late String _fontFamily;
  late double _textOpacity;
  late double _lineSpacing;
  late double _letterSpacing;
  late double _paragraphSpacing;
  late double _textWidth;
  late double _pageMargins;
  int? _textGradientIndex;
  int? _textureIndex;
  int _textEditorTab = 0;
  ui.Image? _textTextureImage;
  final RealtimeDBManager _realtimeDBManager = RealtimeDBManager();
  bool _isLoadingThemes = false;
  List<ThemeItem> _themes = const [];
  Color? _backgroundColor;
  List<Color>? _backgroundGradient;
  String? _backgroundNetworkUrl;
  String? _backgroundFilePath;
  late String _themeId;
  double _aspectRatio = 1.0;
  int _selectedTool = -1;
  int _backgroundTab = 0;
  bool _sharing = false;

  static const _backgroundColors = <Color>[
    Colors.white, Color(0xFFF3F3F3), Color(0xFF171717), Color(0xFF2C2C2E),
    Color(0xFFEEE6FF), Color(0xFFFFE9DF), Color(0xFFE5F4FF), Color(0xFFE7F7EC),
    Color(0xFFFFF3CC), Color(0xFFFFE5EC), Color(0xFFE8EAFD), Color(0xFFE0F7FA),
  ];

  static const _gradients = <List<Color>>[
    [Color(0xFFFF6435), Color(0xFFFF2D55)],
    [Color(0xFF9146E8), Color(0xFF5856D6)],
    [Color(0xFF007AFF), Color(0xFF00C7BE)],
    [Color(0xFF34C759), Color(0xFFFFCC00)],
    [Color(0xFFFF9500), Color(0xFFFF3B30)],
    [Color(0xFF111111), Color(0xFF8E8E93)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
    [Color(0xFF30CFD0), Color(0xFF330867)],
  ];

  static const _textColors = <Color>[
    Color(0xFF171717), Colors.white, Color(0xFFFF3B30), Color(0xFFFF9500),
    Color(0xFF34C759), Color(0xFF007AFF), Color(0xFF5856D6), Color(0xFFAF52DE),
  ];

  static const _ratios = <_CanvasRatio>[
    _CanvasRatio('Original', 1.0),
    _CanvasRatio('1:1', 1.0),
    _CanvasRatio('4:5', 4 / 5),
    _CanvasRatio('5:4', 5 / 4),
    _CanvasRatio('3:4', 3 / 4),
    _CanvasRatio('4:3', 4 / 3),
    _CanvasRatio('2:3', 2 / 3),
    _CanvasRatio('3:2', 3 / 2),
    _CanvasRatio('9:16', 9 / 16),
    _CanvasRatio('16:9', 16 / 9),
    _CanvasRatio('A4 Portrait', 210 / 297),
    _CanvasRatio('A4 Landscape', 297 / 210),
    _CanvasRatio('Instagram Post', 1.0),
    _CanvasRatio('Instagram Portrait', 4 / 5),
    _CanvasRatio('Instagram Story', 9 / 16),
    _CanvasRatio('Facebook Post', 1.91),
    _CanvasRatio('Facebook Story', 9 / 16),
    _CanvasRatio('YouTube', 16 / 9),
    _CanvasRatio('Pinterest', 2 / 3),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _fontSize = widget.fontSize;
    _textAlign = widget.textAlign;
    _textColor = widget.textColor;
    _fontWeight = widget.fontWeight;
    _fontStyle = widget.fontStyle;
    _underline = widget.underline;
    _fontFamily = widget.fontFamily;
    _textOpacity = widget.textOpacity;
    _lineSpacing = widget.lineSpacing;
    _letterSpacing = widget.letterSpacing;
    _paragraphSpacing = widget.paragraphSpacing;
    _textWidth = widget.textWidth;
    _pageMargins = widget.pageMargins;
    _textGradientIndex = widget.textGradientIndex;
    _textureIndex = widget.textureIndex;
    if (_textureIndex != null) _loadTextTexture(_textureIndex!);
    _backgroundColor = widget.backgroundColor;
    _backgroundGradient = widget.backgroundGradient == null ? null : List<Color>.from(widget.backgroundGradient!);
    _backgroundNetworkUrl = widget.backgroundNetworkUrl;
    _backgroundFilePath = widget.backgroundFilePath;
    _themeId = widget.themeId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<_EditImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose Image', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                subtitle: const Text('Choose a photo from your device'),
                onTap: () => Navigator.pop(sheetContext, _EditImageSource.device),
              ),
              ListTile(
                leading: const Icon(Icons.grid_view_rounded),
                title: const Text('App Gallery'),
                subtitle: const Text('Choose from the app image gallery'),
                onTap: () => Navigator.pop(sheetContext, _EditImageSource.appGallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || source == null) return;

    if (source == _EditImageSource.device) {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 92);
      if (image == null || !mounted) return;
      setState(() {
        _backgroundFilePath = image.path;
        _backgroundColor = null;
        _backgroundGradient = null;
        _backgroundNetworkUrl = null;
        _themeId = 'image';
      });
      return;
    }

    final selected = await Navigator.of(context).push<_AppGalleryItem>(
      MaterialPageRoute(builder: (_) => const _AppGalleryScreen()),
    );
    if (selected == null || !mounted) return;

    // Apply immediately. CachedNetworkImageProvider handles memory/disk caching,
    // so selecting the same App Gallery image again is much faster.
    setState(() {
      _backgroundNetworkUrl = selected.original;
      _backgroundFilePath = null;
      _backgroundColor = null;
      _backgroundGradient = null;
      _themeId = 'app-gallery:${selected.id}';
    });
    precacheImage(CachedNetworkImageProvider(selected.original), context);
  }

  Future<void> _pickExistingTheme() async {
    final callback = widget.onPickTheme;
    if (callback == null) return;
    final result = await callback();
    if (result == null || !mounted) return;
    setState(() {
      _backgroundNetworkUrl = result.themeUrl;
      _themeId = result.themeId;
      _backgroundColor = null;
      _backgroundGradient = null;
      _backgroundFilePath = null;
      if (result.preferredTextColor != null) _textColor = result.preferredTextColor!;
    });
  }

  void _done() {
    Navigator.of(context).pop(EditVcResult(
      text: _controller.text,
      fontSize: _fontSize,
      textAlign: _textAlign,
      textColor: _textColor,
      backgroundColor: _backgroundColor,
      backgroundGradient: _backgroundGradient,
      backgroundNetworkUrl: _backgroundNetworkUrl,
      backgroundFilePath: _backgroundFilePath,
      themeId: _themeId,
      aspectRatio: _aspectRatio,
      fontWeight: _fontWeight,
      fontStyle: _fontStyle,
      underline: _underline,
      fontFamily: _fontFamily,
      textOpacity: _textOpacity,
      lineSpacing: _lineSpacing,
      letterSpacing: _letterSpacing,
      paragraphSpacing: _paragraphSpacing,
      textWidth: _textWidth,
      pageMargins: _pageMargins,
      textGradientIndex: _textGradientIndex,
      textureIndex: _textureIndex,
    ));
  }

  Future<void> _shareVisibleCanvas() async {
    if (_sharing) return;
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    setState(() => _sharing = true);
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      final file = File('${Directory.systemTemp.path}/NovelAI_Edit_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')]);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Decoration _canvasDecoration(bool isDark) {
    if (_backgroundFilePath != null && _backgroundFilePath!.trim().isNotEmpty) {
      return BoxDecoration(image: DecorationImage(image: FileImage(File(_backgroundFilePath!)), fit: BoxFit.cover));
    }
    if (_backgroundNetworkUrl != null && _backgroundNetworkUrl!.trim().isNotEmpty) {
      return BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(_backgroundNetworkUrl!), fit: BoxFit.cover));
    }
    if (_backgroundGradient != null && _backgroundGradient!.isNotEmpty) {
      return BoxDecoration(gradient: LinearGradient(colors: _backgroundGradient!, begin: Alignment.topLeft, end: Alignment.bottomRight));
    }
    return BoxDecoration(color: _backgroundColor ?? (isDark ? const Color(0xFF242424) : Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageColor = isDark ? const Color(0xFF151515) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF171717);
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: pageColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(tooltip: 'Done', onPressed: _done, icon: const Icon(Icons.check)),
          IconButton(tooltip: 'Share visible canvas', onPressed: _sharing ? null : _shareVisibleCanvas, icon: _sharing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.share_outlined)),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: Center(child: LayoutBuilder(builder: (context, constraints) {
            var width = constraints.maxWidth - 28;
            var height = width / _aspectRatio;
            if (height > constraints.maxHeight - 18) { height = constraints.maxHeight - 18; width = height * _aspectRatio; }
            return RepaintBoundary(
              key: _canvasKey,
              child: Container(
                width: width, height: height, clipBehavior: Clip.antiAlias,
                decoration: _canvasDecoration(isDark),
                child: TextField(
                  controller: _controller, expands: true, maxLines: null, minLines: null,
                  textAlign: _textAlign, textAlignVertical: TextAlignVertical.top,
                  style: _editorTextStyle,
                  decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: _pageMargins, vertical: 10)),
                ),
              ),
            );
          }))),
          AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: _toolPanel()),
          Container(
            height: 74,
            decoration: BoxDecoration(color: pageColor, border: Border(top: BorderSide(color: iconColor.withValues(alpha: 0.08)))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _tool(0, Icons.image_outlined, 'Image', () { setState(() => _selectedTool = 0); _pickImage(); }),
              _tool(1, Icons.text_fields, 'Text', () { setState(() => _selectedTool = 1); _showTextStyleSheet(); }),
              _tool(2, Icons.crop_square_outlined, 'Canvas', () => setState(() => _selectedTool = 2)),
              _tool(3, Icons.format_color_fill_outlined, 'Background', () => setState(() => _selectedTool = 3)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tool(int index, IconData icon, String label, VoidCallback onTap) {
    final selected = _selectedTool == index;
    final color = selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: SizedBox(width: 78, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 24), const SizedBox(height: 5),
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
    ])));
  }

  Widget _toolPanel() {
    if (_selectedTool == 1) {
      return const SizedBox(key: ValueKey('text'), height: 0);
    }

    if (_selectedTool == 2) {
      return Container(key: const ValueKey('canvas'), height: 72, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: _ratios.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) { final item = _ratios[i]; return ChoiceChip(label: Text(item.label), selected: (_aspectRatio - item.ratio).abs() < .001, onSelected: (_) => setState(() => _aspectRatio = item.ratio)); },
      ));
    }

    if (_selectedTool == 3) {
      return Container(key: const ValueKey('background'), padding: const EdgeInsets.fromLTRB(12, 8, 12, 10), child: Column(mainAxisSize: MainAxisSize.min, children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, icon: Icon(Icons.palette_outlined), label: Text('Color')),
            ButtonSegment(value: 1, icon: Icon(Icons.gradient_outlined), label: Text('Gradient')),
            ButtonSegment(value: 2, icon: Icon(Icons.wallpaper_outlined), label: Text('Theme')),
          ],
          selected: {_backgroundTab}, showSelectedIcon: false,
          onSelectionChanged: (value) => setState(() => _backgroundTab = value.first),
        ),
        const SizedBox(height: 10),
        if (_backgroundTab == 0) _colorPicker(),
        if (_backgroundTab == 1) _gradientPicker(),
        if (_backgroundTab == 2) _themePicker(),
      ]));
    }
    return const SizedBox(key: ValueKey('none'), height: 0);
  }

  Widget _colorPicker() => SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _backgroundColors.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
    final color = _backgroundColors[i];
    return GestureDetector(onTap: () => setState(() { _backgroundColor = color; _backgroundGradient = null; _backgroundNetworkUrl = null; _backgroundFilePath = null; _themeId = 'color'; }), child: CircleAvatar(radius: 19, backgroundColor: color, child: _backgroundColor == color ? Icon(Icons.check, size: 18, color: color.computeLuminance() > .5 ? Colors.black : Colors.white) : null));
  }));

  Widget _gradientPicker() => SizedBox(height: 48, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _gradients.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
    final gradient = _gradients[i];
    return GestureDetector(onTap: () => setState(() { _backgroundGradient = List<Color>.from(gradient); _backgroundColor = null; _backgroundNetworkUrl = null; _backgroundFilePath = null; _themeId = 'gradient:$i'; }), child: Container(width: 58, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: gradient), border: Border.all(color: _themeId == 'gradient:$i' ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2))));
  }));

  Widget _themePicker() {
    if (_themes.isEmpty && !_isLoadingThemes) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadThemes());
    }
    if (_isLoadingThemes) {
      return const SizedBox(height: 92, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_themes.isEmpty) {
      return SizedBox(height: 58, child: Center(child: TextButton.icon(onPressed: _loadThemes, icon: const Icon(Icons.refresh), label: const Text('Retry themes'))));
    }
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _themes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, index) {
          final theme = _themes[index];
          final id = 'theme:${theme.id}';
          final selected = _themeId == id;
          return GestureDetector(
            onTap: () => setState(() {
              _backgroundNetworkUrl = theme.url;
              _themeId = id;
              _backgroundColor = null;
              _backgroundGradient = null;
              _backgroundFilePath = null;
              _textColor = theme.name.toLowerCase() == 'white' ? Colors.white : Colors.black;
            }),
            child: Container(
              width: 82,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor, width: selected ? 2.5 : 1),
              ),
              child: CachedNetworkImage(
                imageUrl: _themeDisplayUrl(theme.url, width: 500),
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadThemes() async {
    if (_isLoadingThemes) return;
    setState(() => _isLoadingThemes = true);
    try {
      final values = List<ThemeItem>.of(await _realtimeDBManager.fetchAllThemes());
      values.sort((a, b) => (int.tryParse(a.id) ?? 1 << 30).compareTo(int.tryParse(b.id) ?? 1 << 30));
      if (!mounted) return;
      setState(() { _themes = values; _isLoadingThemes = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingThemes = false);
      debugPrint('Unable to load themes: $e');
    }
  }

  Future<void> _loadTextTexture(int index) async {
    try {
      final data = await DefaultAssetBundle.of(context).load('assets/images/texture$index.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (!mounted || _textureIndex != index) return;
      setState(() => _textTextureImage = frame.image);
    } catch (e) {
      debugPrint('Unable to load text texture: $e');
    }
  }

  Color _readableColor(Color color) {
    final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness < 140 ? Colors.white : Colors.black;
  }

  List<Color>? get _activeTextGradient {
    const gradients = <List<Color>>[
      [Color(0xFFFF6435), Color(0xFFFF2D55)],
      [Color(0xFF9146E8), Color(0xFF5856D6)],
      [Color(0xFF007AFF), Color(0xFF00C7BE)],
      [Color(0xFF34C759), Color(0xFFFFCC00)],
      [Color(0xFFFF9500), Color(0xFFFF3B30)],
      [Color(0xFF111111), Color(0xFF8E8E93)],
    ];
    final i = _textGradientIndex;
    return i == null || i < 0 || i >= gradients.length ? null : gradients[i];
  }

  TextStyle get _editorTextStyle {
    Paint? foreground;
    final gradient = _activeTextGradient;
    if (gradient != null) {
      foreground = Paint()..shader = LinearGradient(colors: gradient).createShader(const Rect.fromLTWH(0, 0, 900, 1800));
    } else if (_textureIndex != null && _textTextureImage != null) {
      foreground = Paint()..shader = ui.ImageShader(_textTextureImage!, TileMode.repeated, TileMode.repeated, Matrix4.identity().storage);
    }
    return TextStyle(
      fontFamily: _fontFamily == 'sans-serif' ? null : _fontFamily,
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      fontStyle: _fontStyle,
      decoration: _underline ? TextDecoration.underline : TextDecoration.none,
      color: foreground == null ? _textColor.withValues(alpha: _textOpacity) : null,
      foreground: foreground,
      height: _lineSpacing,
      letterSpacing: _letterSpacing,
    );
  }

  Future<void> _showTextStyleSheet() async {
    final original = _TextSnapshot.fromState(this);
    bool applied = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(builder: (context, sheetSetState) {
        void update(VoidCallback fn) { setState(fn); sheetSetState(() {}); }
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final cardColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F7);
        final borderColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
        final primary = isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
        final muted = isDark ? const Color(0xFFA9A9AF) : const Color(0xFF7A7A80);
        const textColors = <Color>[Color(0xFF111111), Colors.white, Color(0xFFFF3B30), Color(0xFFFF9500), Color(0xFFFFCC00), Color(0xFF34C759), Color(0xFF00C7BE), Color(0xFF007AFF), Color(0xFF5856D6), Color(0xFFAF52DE), Color(0xFFFF2D55), Color(0xFF8E8E93)];
        const textGradients = <List<Color>>[[Color(0xFFFF6435),Color(0xFFFF2D55)],[Color(0xFF9146E8),Color(0xFF5856D6)],[Color(0xFF007AFF),Color(0xFF00C7BE)],[Color(0xFF34C759),Color(0xFFFFCC00)],[Color(0xFFFF9500),Color(0xFFFF3B30)],[Color(0xFF111111),Color(0xFF8E8E93)]];
        Widget sectionTitle(String t) => Padding(padding: const EdgeInsets.only(bottom:10), child: Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(fontSize:14,fontWeight:FontWeight.w700))));
        Widget slider(String title,double value,double min,double max,int divisions,String Function(double) label,ValueChanged<double> change)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w600))),Text(label(value),style:TextStyle(fontSize:13,color:muted))]),Slider(value:value.clamp(min,max).toDouble(),min:min,max:max,divisions:divisions,activeColor:primary,onChanged:change)]);
        Widget iconChoice(IconData icon,bool selected,VoidCallback tap)=>Expanded(child:GestureDetector(onTap:tap,child:AnimatedContainer(duration:const Duration(milliseconds:150),height:42,decoration:BoxDecoration(color:selected?primary.withValues(alpha:.14):cardColor,borderRadius:BorderRadius.circular(10),border:Border.all(color:selected?primary:borderColor)),child:Icon(icon,size:20,color:selected?primary:null))));
        return Container(
          height: MediaQuery.sizeOf(context).height * .50,
          decoration: BoxDecoration(color:sheetColor,borderRadius:const BorderRadius.vertical(top:Radius.circular(26))),
          child: Column(children:[
            Padding(padding:const EdgeInsets.fromLTRB(18,12,12,8),child:Row(children:[IconButton(onPressed:()=>Navigator.pop(sheetContext),icon:const Icon(Icons.close_rounded)),const Expanded(child:Text('Text Editor',textAlign:TextAlign.center,style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))),IconButton(onPressed:(){applied=true;Navigator.pop(sheetContext);},icon:Icon(Icons.check_rounded,color:primary))])),
            Container(margin:const EdgeInsets.fromLTRB(18,4,18,14),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:cardColor,borderRadius:BorderRadius.circular(16),border:Border.all(color:borderColor)),child:Text(_controller.text.trim().isEmpty?'Your story text will look like this.':_controller.text.trim().split('\n').first,maxLines:3,overflow:TextOverflow.ellipsis,textAlign:_textAlign,style:_editorTextStyle)),
            Expanded(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(18,0,18,28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Container(height:42,padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:cardColor,borderRadius:BorderRadius.circular(12)),child:Row(children:['Color','Gradient','Texture'].asMap().entries.map((e){final selected=_textEditorTab==e.key;return Expanded(child:GestureDetector(onTap:()=>update(()=>_textEditorTab=e.key),child:AnimatedContainer(duration:const Duration(milliseconds:160),alignment:Alignment.center,decoration:BoxDecoration(color:selected?sheetColor:Colors.transparent,borderRadius:BorderRadius.circular(9),boxShadow:selected?[BoxShadow(color:Colors.black.withValues(alpha:.08),blurRadius:5)]:null),child:Text(e.value,style:TextStyle(fontSize:13,fontWeight:selected?FontWeight.w700:FontWeight.w500,color:selected?primary:muted)))));}).toList())),
              const SizedBox(height:14),
              if(_textEditorTab==0) Wrap(spacing:12,runSpacing:12,children:textColors.map((c){final selected=_textGradientIndex==null&&_textureIndex==null&&_textColor.value==c.value;return GestureDetector(onTap:()=>update((){_textColor=c;_textGradientIndex=null;_textureIndex=null;_textTextureImage=null;}),child:Container(width:38,height:38,decoration:BoxDecoration(color:c,shape:BoxShape.circle,border:Border.all(width:selected?3:1,color:selected?primary:borderColor)),child:selected?Icon(Icons.check,size:17,color:_readableColor(c)):null));}).toList()),
              if(_textEditorTab==1) GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:textGradients.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:2),itemBuilder:(_,i){final selected=_textGradientIndex==i;return GestureDetector(onTap:()=>update((){_textGradientIndex=i;_textureIndex=null;_textTextureImage=null;}),child:Container(decoration:BoxDecoration(gradient:LinearGradient(colors:textGradients[i]),borderRadius:BorderRadius.circular(10),border:Border.all(color:selected?primary:Colors.transparent,width:2.5)),child:selected?const Icon(Icons.check,color:Colors.white):null));}),
              if(_textEditorTab==2) SizedBox(height:74,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:22,separatorBuilder:(_,__)=>const SizedBox(width:9),itemBuilder:(_,i){final selected=_textureIndex==i;return GestureDetector(onTap:()async{update((){_textureIndex=i;_textGradientIndex=null;});await _loadTextTexture(i);sheetSetState((){});},child:Container(width:62,decoration:BoxDecoration(borderRadius:BorderRadius.circular(10),border:Border.all(color:selected?primary:borderColor,width:selected?2.5:1),image:DecorationImage(image:AssetImage('assets/images/texture$i.png'),fit:BoxFit.cover)),child:selected?const Icon(Icons.check_circle,color:Colors.white):null));})),
              const SizedBox(height:22),sectionTitle('Font'),
              DropdownButtonFormField<String>(value:_fontFamily,decoration:InputDecoration(filled:true,fillColor:cardColor,border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide(color:borderColor)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide(color:borderColor)),contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:12)),items:const [DropdownMenuItem(value:'sans-serif',child:Text('Sans Serif')),DropdownMenuItem(value:'serif',child:Text('Serif')),DropdownMenuItem(value:'monospace',child:Text('Monospace')),DropdownMenuItem(value:'sans-serif-condensed',child:Text('Condensed'))],onChanged:(v){if(v!=null)update(()=>_fontFamily=v);}),
              const SizedBox(height:18),slider('Font Size',_fontSize,12,34,22,(v)=>'${v.round()}',(v)=>update(()=>_fontSize=v)),const SizedBox(height:4),sectionTitle('Font Alignment'),
              Row(children:[iconChoice(Icons.format_align_left_rounded,_textAlign==TextAlign.left,()=>update(()=>_textAlign=TextAlign.left)),const SizedBox(width:8),iconChoice(Icons.format_align_center_rounded,_textAlign==TextAlign.center,()=>update(()=>_textAlign=TextAlign.center)),const SizedBox(width:8),iconChoice(Icons.format_align_right_rounded,_textAlign==TextAlign.right,()=>update(()=>_textAlign=TextAlign.right)),const SizedBox(width:8),iconChoice(Icons.format_align_justify_rounded,_textAlign==TextAlign.justify,()=>update(()=>_textAlign=TextAlign.justify))]),
              const SizedBox(height:18),sectionTitle('Font Style'),Row(children:[iconChoice(Icons.format_bold_rounded,_fontWeight==FontWeight.bold,()=>update(()=>_fontWeight=_fontWeight==FontWeight.bold?FontWeight.w500:FontWeight.bold)),const SizedBox(width:8),iconChoice(Icons.format_italic_rounded,_fontStyle==FontStyle.italic,()=>update(()=>_fontStyle=_fontStyle==FontStyle.italic?FontStyle.normal:FontStyle.italic)),const SizedBox(width:8),iconChoice(Icons.format_underline_rounded,_underline,()=>update(()=>_underline=!_underline))]),
              const SizedBox(height:18),slider('Text Opacity',_textOpacity,.2,1,8,(v)=>'${(v*100).round()}%',(v)=>update(()=>_textOpacity=v)),slider('Line Spacing',_lineSpacing,1,2.5,15,(v)=>v.toStringAsFixed(1),(v)=>update(()=>_lineSpacing=v)),slider('Letter Spacing',_letterSpacing,-1,4,20,(v)=>v.toStringAsFixed(1),(v)=>update(()=>_letterSpacing=v)),slider('Paragraph Spacing',_paragraphSpacing,0,20,20,(v)=>'${v.round()}',(v)=>update(()=>_paragraphSpacing=v)),slider('Text Width',_textWidth,.65,1,7,(v)=>'${(v*100).round()}%',(v)=>update(()=>_textWidth=v)),slider('Page Margins',_pageMargins,8,40,16,(v)=>'${v.round()}',(v)=>update(()=>_pageMargins=v)),
            ])))
          ]),
        );
      }),
    );
    if(!applied && mounted){ original.restore(this); }
  }
}

class _TextSnapshot {
  _TextSnapshot(this.fontSize,this.fontWeight,this.fontStyle,this.align,this.underline,this.family,this.opacity,this.line,this.letter,this.paragraph,this.width,this.margins,this.color,this.gradient,this.texture);
  factory _TextSnapshot.fromState(_EditVcState s)=>_TextSnapshot(s._fontSize,s._fontWeight,s._fontStyle,s._textAlign,s._underline,s._fontFamily,s._textOpacity,s._lineSpacing,s._letterSpacing,s._paragraphSpacing,s._textWidth,s._pageMargins,s._textColor,s._textGradientIndex,s._textureIndex);
  final double fontSize,opacity,line,letter,paragraph,width,margins; final FontWeight fontWeight; final FontStyle fontStyle; final TextAlign align; final bool underline; final String family; final Color color; final int? gradient,texture;
  void restore(_EditVcState s){s.setState((){s._fontSize=fontSize;s._fontWeight=fontWeight;s._fontStyle=fontStyle;s._textAlign=align;s._underline=underline;s._fontFamily=family;s._textOpacity=opacity;s._lineSpacing=line;s._letterSpacing=letter;s._paragraphSpacing=paragraph;s._textWidth=width;s._pageMargins=margins;s._textColor=color;s._textGradientIndex=gradient;s._textureIndex=texture;}); if(texture!=null)s._loadTextTexture(texture!);}
}

String _googleDriveFileId(String url) {
  final trimmed=url.trim();
  try{final uri=Uri.parse(trimmed);final q=uri.queryParameters['id'];if(q!=null&&q.isNotEmpty)return q;final seg=uri.pathSegments;final d=seg.indexOf('d');if(d>=0&&d+1<seg.length)return seg[d+1];}catch(_){}
  return RegExp(r'[?&]id=([^&]+)').firstMatch(trimmed)?.group(1)??'';
}
String _themeDisplayUrl(String original,{int width=1200}){final id=_googleDriveFileId(original);return id.isEmpty?original.trim():Uri.https('drive.google.com','/thumbnail',{'id':id,'sz':'w$width'}).toString();}


class _CanvasRatio {
  const _CanvasRatio(this.label, this.ratio);
  final String label;
  final double ratio;
}


enum _EditImageSource { device, appGallery }

class _AppGalleryItem {
  const _AppGalleryItem({
    required this.id,
    required this.thumbnail,
    required this.original,
  });

  final String id;
  final String thumbnail;
  final String original;

  static _AppGalleryItem? fromValue(Object? value, String fallbackId) {
    if (value is! Map) return null;
    final map = Map<Object?, Object?>.from(value);
    String read(String key) => (map[key] ?? '').toString().trim();
    final id = read('imageId').isNotEmpty ? read('imageId') : (read('id').isNotEmpty ? read('id') : fallbackId);
    final thumbnail = read('thumbnail');
    final original = read('original');
    if (original.isEmpty) return null;
    return _AppGalleryItem(
      id: id,
      thumbnail: thumbnail.isEmpty ? original : thumbnail,
      original: original,
    );
  }
}

class _AppGalleryScreen extends StatefulWidget {
  const _AppGalleryScreen();

  @override
  State<_AppGalleryScreen> createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<_AppGalleryScreen> {
  bool _loading = true;
  String? _error;
  List<_AppGalleryItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('Customize').get();
      final items = <_AppGalleryItem>[];
      for (final child in snapshot.children) {
        final item = _AppGalleryItem.fromValue(child.value, child.key ?? '');
        if (item != null) items.add(item);
      }
      items.sort((a, b) {
        final ai = int.tryParse(a.id);
        final bi = int.tryParse(b.id);
        if (ai != null && bi != null) return ai.compareTo(bi);
        return a.id.compareTo(b.id);
      });
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
      // Warm the first visible thumbnails without waiting for them.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final item in _items.take(12)) {
          precacheImage(CachedNetworkImageProvider(item.thumbnail), context);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('App Gallery Images'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 42),
                        const SizedBox(height: 12),
                        const Text('Unable to load App Gallery.'),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); }, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? const Center(child: Text('No App Gallery images found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Navigator.pop(context, item),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.thumbnail,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                              errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined)),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
