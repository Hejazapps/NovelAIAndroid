import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookChapter {
  const BookChapter({required this.title, required this.content});

  final String title;
  final String content;

  String get displayTitle {
    var value = title.trim();
    if (value.isEmpty) return '';

    final pattern = RegExp(
      r'^\s*(?:chapter|book|part)\s+(?:\d+|[ivxlcdm]+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|thirty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|forty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|fifty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|sixty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|seventy(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|eighty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?|ninety(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?)\s*[.:—–-]*\s*',
      caseSensitive: false,
    );

    value = value.replaceFirst(pattern, '');
    return value.replaceAll(RegExp(r'^[ .:—–-]+|[ .:—–-]+$'), '').trim();
  }
}

class BookChapterReaderScreen extends StatefulWidget {
  const BookChapterReaderScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    this.bookAuthor = '',
    this.bookUrl,
    this.bookCoverUrl,
    this.bookUrls = const [],
  });

  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookUrl;
  final String? bookCoverUrl;
  final List<String> bookUrls;

  @override
  State<BookChapterReaderScreen> createState() =>
      _BookChapterReaderScreenState();
}

class _BookChapterReaderScreenState extends State<BookChapterReaderScreen> {
  static const Color _lightAccent = Color(0xFFFF6435);
  static const Color _darkAccent = Color(0xFF9146E8);

  final ScrollController _scrollController = ScrollController();

  List<BookChapter> _chapters = const [];
  final Map<int, String> _translatedTextByChapter = {};

  int _currentChapterIndex = 0;
  double _fontSize = 18;
  bool _loading = true;
  bool _showCover = true;
  bool _isTranslating = false;
  String? _selectedTranslationLanguage;
  String? _error;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
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
      _isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.08);

  String get _chapterSaveKey =>
      'BookChapterReader.chapter.${widget.bookId}';
  String get _openedSaveKey =>
      'BookChapterReader.opened.${widget.bookId}';
  String get _fontSaveKey => 'BookChapterReader.fontSize';

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

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_fontSaveKey) ?? 18;
    final hasOpened = prefs.getBool(_openedSaveKey) ?? false;
    _showCover = !hasOpened;

    await _loadBook();

    if (!mounted || _chapters.isEmpty) return;

    final saved = prefs.getInt(_chapterSaveKey) ?? 0;
    _currentChapterIndex = saved.clamp(0, _chapters.length - 1);
    setState(() {});
  }

  List<String> _candidateBookUrls() {
    final output = <String>[];

    void add(String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty && !output.contains(v)) output.add(v);
    }

    if (widget.bookId > 0) {
      add('https://www.gutenberg.org/cache/epub/${widget.bookId}/pg${widget.bookId}.txt');
      add('https://www.gutenberg.org/cache/epub/${widget.bookId}/pg${widget.bookId}.txt.utf-8');
      add('https://www.gutenberg.org/files/${widget.bookId}/${widget.bookId}.txt');
    }

    add(widget.bookUrl);
    for (final url in widget.bookUrls) {
      add(url);
    }

    if (widget.bookId > 0) {
      add('https://www.gutenberg.org/files/${widget.bookId}/${widget.bookId}-h/${widget.bookId}-h.htm');
      add('https://www.gutenberg.org/ebooks/${widget.bookId}.txt.utf-8');
    }

    return output;
  }

  Future<void> _loadBook() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final urls = _candidateBookUrls();
    if (urls.isEmpty) {
      _setLoadError('This book does not have a readable text URL.');
      return;
    }

    for (final value in urls) {
      HttpClient? client;
      try {
        client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
        final request = await client.getUrl(Uri.parse(value));
        request.headers.set(
          HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (Android; Mobile) AppleWebKit/537.36',
        );
        request.headers.set(
          HttpHeaders.acceptHeader,
          'text/html,text/plain;q=0.9,*/*;q=0.8',
        );

        final response = await request.close().timeout(
              const Duration(seconds: 45),
            );

        if (response.statusCode < 200 || response.statusCode > 299) continue;

        final bytes = await consolidateHttpClientResponseBytes(response);
        if (bytes.isEmpty) continue;

        final mime = response.headers.contentType?.mimeType ?? '';
        final cleanText = _makeReadableText(bytes, mime);
        if (cleanText == null) continue;

        final parsed = _makeChapters(cleanText);
        if (parsed.isEmpty) continue;

        if (!mounted) return;
        setState(() {
          _chapters = parsed;
          _loading = false;
          _error = null;
        });
        return;
      } catch (e) {
        debugPrint('[book reader] failed $value: $e');
      } finally {
        client?.close(force: true);
      }
    }

    _setLoadError('Unable to load this book. Please try another book.');
  }

  void _setLoadError(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = message;
    });
  }

  String? _makeReadableText(List<int> bytes, String mimeType) {
    String text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      text = latin1.decode(bytes, allowInvalid: true);
    }

    if (mimeType.toLowerCase().contains('html') || _looksLikeHtml(text)) {
      text = _htmlToText(text);
    }

    text = _normalizeText(text);
    text = _removeGutenbergBoilerplate(text);
    text = _removeIllustrationMarkers(text);

    return text.length >= 200 ? text : null;
  }

  bool _looksLikeHtml(String text) {
    final prefix = text.substring(0, text.length.clamp(0, 5000)).toLowerCase();
    return prefix.contains('<html') ||
        prefix.contains('<body') ||
        prefix.contains('<p') ||
        prefix.contains('<div');
  }

  String _htmlToText(String html) {
    var result = html
        .replaceAll(RegExp(r'<script\b[^>]*>.*?</script>',
            caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<style\b[^>]*>.*?</style>',
            caseSensitive: false, dotAll: true), '');

    result = result.replaceAll(
      RegExp(r'</?(?:h1|h2|h3|h4|h5|h6|p|div|li|br|blockquote)\b[^>]*>',
          caseSensitive: false),
      '\n',
    );
    result = result.replaceAll(RegExp(r'<[^>]+>', dotAll: true), ' ');

    const entities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
      '&mdash;': '—',
      '&ndash;': '–',
    };
    entities.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    result = result.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) => String.fromCharCode(int.tryParse(m.group(1)!) ?? 32),
    );
    return result;
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _removeGutenbergBoilerplate(String text) {
    var result = text;
    final start = RegExp(
      r'\*{3}\s*START OF (?:THE|THIS) PROJECT GUTENBERG EBOOK[^\n]*',
      caseSensitive: false,
    );
    final startMatch = start.firstMatch(result);
    if (startMatch != null) {
      result = result.substring(startMatch.end);
    }

    final end = RegExp(
      r'\*{3}\s*END OF (?:THE|THIS) PROJECT GUTENBERG EBOOK',
      caseSensitive: false,
    );
    final endMatch = end.firstMatch(result);
    if (endMatch != null) {
      result = result.substring(0, endMatch.start);
    }
    return _normalizeText(result);
  }

  String _removeIllustrationMarkers(String text) {
    return _normalizeText(
      text.replaceAll(
        RegExp(
          r'^\s*\[\[?\s*(?:illustration|illustrations|frontispiece)(?:\s*:[^\]\n]*)?\s*\]\]?\s*$',
          caseSensitive: false,
          multiLine: true,
        ),
        '',
      ),
    );
  }

  List<BookChapter> _makeChapters(String text) {
    final patterns = [
      RegExp(
        r'^[ \t]*(chapter[ \t]+(?:\d+|[ivxlcdm]+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty(?:[- ](?:one|two|three|four|five|six|seven|eight|nine))?)(?:[ \t]*[.:—-]?[ \t]*[^\n]{0,120})?)[ \t]*$',
        caseSensitive: false,
        multiLine: true,
      ),
      RegExp(
        r'^[ \t]*(book[ \t]+(?:\d+|[ivxlcdm]+)(?:[ \t]*[.:—-]?[ \t]*[^\n]{0,120})?)[ \t]*$',
        caseSensitive: false,
        multiLine: true,
      ),
      RegExp(
        r'^[ \t]*(part[ \t]+(?:\d+|[ivxlcdm]+)(?:[ \t]*[.:—-]?[ \t]*[^\n]{0,120})?)[ \t]*$',
        caseSensitive: false,
        multiLine: true,
      ),
    ];

    for (final pattern in patterns) {
      final parsed = _splitText(text, pattern);
      if (parsed.length >= 2) return parsed;
    }

    final first = RegExp(
      r'^[ \t]*(?:chapter|book|part)[ \t]+(?:\d+|[ivxlcdm]+|one|two|three|four|five|six|seven|eight|nine|ten)\b[^\n]*$',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(text);

    final fallback = first == null ? text : text.substring(first.start);
    return [
      BookChapter(
        title: widget.bookTitle,
        content: _removeIllustrationMarkers(fallback),
      ),
    ];
  }

  List<BookChapter> _splitText(String text, RegExp pattern) {
    final matches = pattern.allMatches(text).toList();
    if (matches.isEmpty) return const [];

    // Like the Swift reader: TOC duplicates are removed by keeping the
    // last occurrence of an identical normalized heading.
    final lastByHeading = <String, RegExpMatch>{};
    for (final match in matches) {
      final heading = (match.group(1) ?? match.group(0) ?? '').trim();
      final key = heading.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      lastByHeading[key] = match;
    }

    final unique = lastByHeading.values.toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final output = <BookChapter>[];
    for (var i = 0; i < unique.length; i++) {
      final current = unique[i];
      final end = i + 1 < unique.length ? unique[i + 1].start : text.length;
      if (end <= current.start) continue;

      final heading = (current.group(1) ?? current.group(0) ?? '').trim();
      var body = text.substring(current.start, end);

      if (body.toLowerCase().startsWith(heading.toLowerCase())) {
        body = body.substring(heading.length);
      }

      body = _removeIllustrationMarkers(_normalizeText(body));
      if (body.length < 50) continue;

      output.add(BookChapter(title: heading, content: body));
    }
    return output;
  }

  String? get _coverUrl {
    final supplied = widget.bookCoverUrl?.trim();
    if (supplied != null && supplied.isNotEmpty) return supplied;
    if (widget.bookId <= 0) return null;
    return 'https://www.gutenberg.org/cache/epub/${widget.bookId}/pg${widget.bookId}.cover.medium.jpg';
  }

  BookChapter? get _chapter =>
      _chapters.isEmpty ? null : _chapters[_currentChapterIndex];

  String get _chapterText {
    final chapter = _chapter;
    if (chapter == null) return '';
    return _translatedTextByChapter[_currentChapterIndex] ?? chapter.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: _text),
        ),
        title: Text(
          widget.bookTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: _text, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _smallerFont,
            child: Text('A−', style: TextStyle(color: _accent, fontSize: 16)),
          ),
          TextButton(
            onPressed: _largerFont,
            child: Text('A+', style: TextStyle(color: _accent, fontSize: 16)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : _showCover
                    ? _buildCover()
                    : _buildReader(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _accent),
          const SizedBox(height: 14),
          Text('Preparing book...', style: TextStyle(color: _muted)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: _accent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Unable to Load Book',
              style: TextStyle(
                color: _text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _accent),
              onPressed: _loadBook,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookCover({double? width, double? height}) {
    final url = _coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        color: _surface,
        child: url == null
            ? Icon(Icons.book_rounded, color: _muted, size: 55)
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.book_rounded, color: _muted, size: 55),
              ),
      ),
    );
  }

  Widget _buildCover() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * .52,
              child: AspectRatio(
                aspectRatio: 1 / 1.48,
                child: _bookCover(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.bookTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (widget.bookAuthor.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.bookAuthor,
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 15),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            width: 190,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _startReading,
              child: const Text(
                'Start Reading',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReader() {
    final chapter = _chapter!;
    final realTitle = chapter.displayTitle;
    final chapterNumber = 'Chapter ${_currentChapterIndex + 1}';

    return Column(
      children: [
        const SizedBox(height: 10),
        _bookCover(width: 72, height: 100),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              realTitle.isEmpty ? chapterNumber : '$chapterNumber\n$realTitle',
              style: TextStyle(
                color: _text,
                fontSize: 20,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isTranslating
                  ? 'Translating...'
                  : '$chapterNumber of ${_chapters.length}',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ),
        ),
        if (_isTranslating) ...[
          const SizedBox(height: 5),
          LinearProgressIndicator(
            minHeight: 2,
            color: _accent,
            backgroundColor: _surface,
          ),
        ],
        const SizedBox(height: 8),
        Expanded(
          child: SelectionArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Text(
                _chapterText,
                style: TextStyle(
                  color: _text,
                  fontSize: _fontSize,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: _divider),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 58,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: _previous,
              child: Text('‹ Previous', style: TextStyle(color: _accent)),
            ),
            TextButton(
              onPressed: _showChapters,
              child: Text('Chapters', style: TextStyle(color: _accent)),
            ),
            IconButton(
              tooltip: 'Translate chapter',
              onPressed: _isTranslating ? null : _showLanguageOptions,
              icon: _isTranslating
                  ? SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _accent,
                      ),
                    )
                  : Icon(
                      Icons.language_rounded,
                      color: _translatedTextByChapter
                              .containsKey(_currentChapterIndex)
                          ? Colors.green
                          : _accent,
                    ),
            ),
            TextButton(
              onPressed:
                  _currentChapterIndex < _chapters.length - 1 ? _next : null,
              child: Text(
                'Next ›',
                style: TextStyle(
                  color: _currentChapterIndex < _chapters.length - 1
                      ? _accent
                      : _muted.withOpacity(.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startReading() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_openedSaveKey, true);
    if (!mounted) return;
    setState(() {
      _currentChapterIndex = 0;
      _showCover = false;
    });
    _scrollTop();
  }

  Future<void> _saveChapter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chapterSaveKey, _currentChapterIndex);
  }

  void _previous() {
    if (_isTranslating) {
      _message('Please wait for current translation to complete');
      return;
    }
    if (_currentChapterIndex == 0) {
      setState(() => _showCover = true);
      return;
    }
    setState(() => _currentChapterIndex--);
    unawaited(_saveChapter());
    _scrollTop();
  }

  void _next() {
    if (_isTranslating) {
      _message('Please wait for current translation to complete');
      return;
    }
    if (_currentChapterIndex >= _chapters.length - 1) return;
    setState(() => _currentChapterIndex++);
    unawaited(_saveChapter());
    _scrollTop();
  }

  void _scrollTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _showChapters() {
    if (_isTranslating) {
      _message('Please wait for current translation to complete');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            height: MediaQuery.sizeOf(context).height * .72,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF2A2236) : Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chapters',
                          style: TextStyle(
                            color: _text,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(Icons.close, color: _muted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _chapters.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: _divider),
                    itemBuilder: (_, index) {
                      final title = _chapters[index].displayTitle;
                      return ListTile(
                        title: Text(
                          'Chapter ${index + 1}',
                          style: TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: title.isEmpty
                            ? null
                            : Text(title, style: TextStyle(color: _muted)),
                        trailing: index == _currentChapterIndex
                            ? Icon(Icons.check_rounded, color: _accent)
                            : null,
                        onTap: () {
                          setState(() {
                            _currentChapterIndex = index;
                            _showCover = false;
                          });
                          unawaited(_saveChapter());
                          Navigator.pop(sheetContext);
                          _scrollTop();
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
  }

  Future<void> _smallerFont() async {
    setState(() => _fontSize = (_fontSize - 1).clamp(14, 30));
    await _saveFont();
  }

  Future<void> _largerFont() async {
    setState(() => _fontSize = (_fontSize + 1).clamp(14, 30));
    await _saveFont();
  }

  Future<void> _saveFont() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSaveKey, _fontSize);
  }

  void _showLanguageOptions() {
    String query = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final names = _languages.keys
                .where((e) => e.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return SafeArea(
              child: Container(
                height: MediaQuery.sizeOf(context).height * .75,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF2A2236) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Text(
                      'Select Language',
                      style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (value) {
                        setSheetState(() => query = value);
                      },
                      style: TextStyle(color: _text),
                      decoration: InputDecoration(
                        hintText: 'Search language',
                        hintStyle: TextStyle(color: _muted),
                        prefixIcon: Icon(Icons.search, color: _muted),
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
                      child: ListView.builder(
                        itemCount: names.length,
                        itemBuilder: (_, index) {
                          final name = names[index];
                          return ListTile(
                            leading: Icon(Icons.translate, color: _accent),
                            title: Text(name, style: TextStyle(color: _text)),
                            trailing: _selectedTranslationLanguage == name
                                ? Icon(Icons.check_circle, color: _accent)
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

  String _translationCacheKey(int chapterIndex, String language) =>
      'BookChapterReader.translation.${widget.bookId}.$chapterIndex.$language';

  Future<void> _selectLanguage(String languageName) async {
    if (_isTranslating || _chapter == null) return;

    if (languageName == 'English') {
      setState(() {
        _translatedTextByChapter.remove(_currentChapterIndex);
        _selectedTranslationLanguage = 'English';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(
      _translationCacheKey(_currentChapterIndex, languageName),
    );

    if (cached != null && cached.trim().isNotEmpty) {
      setState(() {
        _translatedTextByChapter[_currentChapterIndex] = cached;
        _selectedTranslationLanguage = languageName;
      });
      return;
    }

    await _translateCurrentChapter(languageName);
  }

  Future<void> _translateCurrentChapter(String languageName) async {
    final target = _languages[languageName];
    final chapter = _chapter;
    if (target == null || chapter == null) return;

    final chapterIndex = _currentChapterIndex;
    final manager = OnDeviceTranslatorModelManager();
    OnDeviceTranslator? translator;

    setState(() {
      _isTranslating = true;
      _selectedTranslationLanguage = languageName;
    });

    try {
      await manager.downloadModel(target.bcpCode, isWifiRequired: false);

      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: target,
      );

      final chunks = _translationChunks(chapter.content, 1200);
      final translatedParts = <String>[];

      for (var i = 0; i < chunks.length; i++) {
        final translated = await translator.translateText(chunks[i]);
        translatedParts.add(translated);

        if (!mounted) return;
        if (_currentChapterIndex == chapterIndex) {
          setState(() {
            _translatedTextByChapter[chapterIndex] =
                translatedParts.join('\n\n');
          });
        }
      }

      final finalText = translatedParts.join('\n\n').trim();
      if (finalText.isEmpty) throw Exception('Translation returned empty text.');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _translationCacheKey(chapterIndex, languageName),
        finalText,
      );

      if (!mounted) return;
      setState(() {
        _translatedTextByChapter[chapterIndex] = finalText;
      });
    } catch (e) {
      if (mounted) _message('Translation failed: $e');
    } finally {
      await translator?.close();
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  List<String> _translationChunks(String text, int maxCharacters) {
    final normalized =
        text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (normalized.isEmpty) return const [];

    final output = <String>[];
    var current = '';

    void flush() {
      final value = current.trim();
      if (value.isNotEmpty) output.add(value);
      current = '';
    }

    for (final raw in normalized.split(RegExp(r'\n\s*\n'))) {
      final paragraph = raw.trim();
      if (paragraph.isEmpty) continue;

      if (paragraph.length > maxCharacters) {
        flush();
        var remaining = paragraph;
        while (remaining.length > maxCharacters) {
          var splitAt = maxCharacters;
          final prefix = remaining.substring(0, maxCharacters);
          final matches = RegExp(r'[\n.!?;:, ]').allMatches(prefix).toList();
          if (matches.isNotEmpty && matches.last.end > maxCharacters ~/ 2) {
            splitAt = matches.last.end;
          }
          output.add(remaining.substring(0, splitAt).trim());
          remaining = remaining.substring(splitAt).trim();
        }
        if (remaining.isNotEmpty) output.add(remaining);
        continue;
      }

      final candidate =
          current.isEmpty ? paragraph : '$current\n\n$paragraph';
      if (candidate.length <= maxCharacters) {
        current = candidate;
      } else {
        flush();
        current = paragraph;
      }
    }

    flush();
    return output;
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(value),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// Equivalent to Flutter's network image byte consolidation without requiring
// an additional HTTP package.
Future<List<int>> consolidateHttpClientResponseBytes(
  HttpClientResponse response,
) async {
  final bytes = <int>[];
  await for (final chunk in response) {
    bytes.addAll(chunk);
  }
  return bytes;
}
