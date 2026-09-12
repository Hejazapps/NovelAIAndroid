import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/realtime_db_manager.dart';
import 'story_detail_screen.dart';
import 'book_chapter_reader_screen.dart';

typedef DiscoverSubscriptionCheck = bool Function();
typedef DiscoverLockedTap = Future<void> Function();
typedef DiscoverBookTap = Future<void> Function(GutendexBook book);
typedef DiscoverPoemTap = Future<void> Function(PoetryDBPoem poem);
typedef DiscoverStoryTap = Future<void> Function(
  Story story,
  StoryCollection collection,
);

enum DiscoverMode {
  stories,
  books,
  poems,
}

class GutendexResponse {
  const GutendexResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<GutendexBook> results;

  factory GutendexResponse.fromJson(Map<String, dynamic> json) {
    return GutendexResponse(
      count: _intValue(json['count']),
      next: _nullableString(json['next']),
      previous: _nullableString(json['previous']),
      results: ((json['results'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => GutendexBook.fromJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList(),
    );
  }
}

class GutendexBook {
  const GutendexBook({
    required this.id,
    required this.title,
    required this.subjects,
    required this.authors,
    required this.summaries,
    required this.bookshelves,
    required this.languages,
    required this.copyright,
    required this.formats,
    required this.downloadCount,
  });

  final int id;
  final String title;
  final List<String> subjects;
  final List<GutendexAuthor> authors;
  final List<String>? summaries;
  final List<String> bookshelves;
  final List<String> languages;
  final bool? copyright;
  final Map<String, String> formats;
  final int? downloadCount;

  factory GutendexBook.fromJson(Map<String, dynamic> json) {
    final rawFormats = json['formats'];

    return GutendexBook(
      id: _intValue(json['id']),
      title: json['title']?.toString() ?? 'Untitled',
      subjects: _stringList(json['subjects']),
      authors: ((json['authors'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => GutendexAuthor.fromJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList(),
      summaries: json['summaries'] == null
          ? null
          : _stringList(json['summaries']),
      bookshelves: _stringList(json['bookshelves']),
      languages: _stringList(json['languages']),
      copyright: json['copyright'] is bool ? json['copyright'] as bool : null,
      formats: rawFormats is Map
          ? rawFormats.map(
              (key, value) => MapEntry(
                key.toString(),
                value?.toString() ?? '',
              ),
            )
          : const {},
      downloadCount: json['download_count'] == null
          ? null
          : _intValue(json['download_count']),
    );
  }

  String get authorName {
    if (authors.isEmpty) return 'Unknown Author';
    return authors.map((author) => author.name).join(', ');
  }

  String? get coverUrl {
    final value = formats['image/jpeg'];
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get readingUrl {
    const preferred = [
      'text/html',
      'text/html; charset=utf-8',
      'text/html; charset=us-ascii',
      'text/plain; charset=utf-8',
      'text/plain; charset=us-ascii',
      'text/plain',
    ];

    for (final key in preferred) {
      final value = formats[key];
      if (value != null && value.isNotEmpty) return value;
    }

    for (final entry in formats.entries) {
      if (entry.key.toLowerCase().contains('text/html') &&
          entry.value.isNotEmpty) {
        return entry.value;
      }
    }

    for (final entry in formats.entries) {
      if (entry.key.toLowerCase().contains('text/plain') &&
          entry.value.isNotEmpty) {
        return entry.value;
      }
    }

    return null;
  }
}

class GutendexAuthor {
  const GutendexAuthor({
    required this.name,
    required this.birthYear,
    required this.deathYear,
  });

  final String name;
  final int? birthYear;
  final int? deathYear;

  factory GutendexAuthor.fromJson(Map<String, dynamic> json) {
    return GutendexAuthor(
      name: json['name']?.toString() ?? 'Unknown Author',
      birthYear:
          json['birth_year'] == null ? null : _intValue(json['birth_year']),
      deathYear:
          json['death_year'] == null ? null : _intValue(json['death_year']),
    );
  }
}

class PoetryDBPoem {
  const PoetryDBPoem({
    required this.title,
    required this.author,
    required this.lines,
    required this.lineCount,
    this.coverUrl,
  });

  final String title;
  final String author;
  final List<String> lines;
  final int lineCount;
  final String? coverUrl;

  factory PoetryDBPoem.fromJson(Map<String, dynamic> json) {
    final rawLines =
        json['lines'] ??
        json['text'] ??
        json['content'] ??
        json['poem'];

    final lines = rawLines is List
        ? rawLines
            .map((item) => item?.toString() ?? '')
            .where((line) => line.trim().isNotEmpty)
            .toList()
        : rawLines is String
            ? rawLines
                .split(RegExp(r'\r?\n'))
                .where((line) => line.trim().isNotEmpty)
                .toList()
            : <String>[];

    final rawLineCount =
        json['linecount'] ??
        json['lineCount'] ??
        json['line_count'];

    return PoetryDBPoem(
      title: (json['title'] ?? 'Untitled').toString(),
      author: (json['author'] ?? 'Unknown Author').toString(),
      lines: lines,
      lineCount: _intValue(
        rawLineCount,
        fallback: lines.length,
      ),
      coverUrl: _nullableString(
        json['coverUrl'] ??
        json['cover_url'] ??
        json['image'] ??
        json['imageUrl'] ??
        json['image_url'],
      ),
    );
  }

  PoetryDBPoem copyWith({
    String? coverUrl,
  }) {
    return PoetryDBPoem(
      title: title,
      author: author,
      lines: lines,
      lineCount: lineCount,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  String get uniqueKey =>
      '${title.trim().toLowerCase()}|${author.trim().toLowerCase()}';

  String get preview {
    return lines
        .where((line) => line.trim().isNotEmpty)
        .take(3)
        .join('\n');
  }

  String get fullText => lines.join('\n');
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    this.isSubscribed,
    this.onLockedTap,
    this.onBookTap,
    this.onPoemTap,
    this.onStoryTap,
  });

  final DiscoverSubscriptionCheck? isSubscribed;
  final DiscoverLockedTap? onLockedTap;
  final DiscoverBookTap? onBookTap;
  final DiscoverPoemTap? onPoemTap;
  final DiscoverStoryTap? onStoryTap;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const String _firstBooksUrl =
      'https://gutendex.com/books?languages=en&copyright=false&sort=popular';

  static const String _poetryCollectionUrl =
      'https://nordapi.ee/api/v1/poetry/collection?count=10';

  static const int _freeBookLimit = 2;
  static const int _freePoemLimit = 2;
  static const int _maxBookRetries = 2;

  final RealtimeDBManager _dbManager = RealtimeDBManager();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DiscoverMode _mode = DiscoverMode.stories;

  List<StoryCollection> _collections = [];
  List<GutendexBook> _books = [];
  List<PoetryDBPoem> _poems = [];

  final Set<int> _loadedBookIds = {};
  final Set<String> _loadedPoemKeys = {};
  final Set<String> _completedBookPageUrls = {};

  String? _nextBooksUrl;
  String _bookSearchText = '';
  String _poemSearchText = '';

  bool _isLoadingStories = false;
  bool _isLoadingBooks = false;
  bool _isLoadingPoems = false;
  bool _hasLoadedAllBooks = false;

  Object? _storiesError;
  Object? _booksError;
  Object? _poemsError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    _loadStories();

    // Preload books so tab switching feels instant.
    unawaited(_loadFirstBookPage());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    unawaited(_dbManager.dispose());
    super.dispose();
  }

  bool get _isSubscribed => widget.isSubscribed?.call() ?? false;

  bool get _isSearchingBooks => _bookSearchText.trim().isNotEmpty;
  bool get _isSearchingPoems => _poemSearchText.trim().isNotEmpty;

  List<_DisplayedBook> get _displayedBooks {
    final query = _bookSearchText.trim().toLowerCase();

    final items = List<_DisplayedBook>.generate(
      _books.length,
      (index) => _DisplayedBook(
        book: _books[index],
        originalIndex: index,
      ),
    );

    if (query.isEmpty) return items;

    return items.where((item) {
      final haystack =
          '${item.book.title} ${item.book.authorName}'.toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  List<_DisplayedPoem> get _displayedPoems {
    final query = _poemSearchText.trim().toLowerCase();

    final items = List<_DisplayedPoem>.generate(
      _poems.length,
      (index) => _DisplayedPoem(
        poem: _poems[index],
        originalIndex: index,
      ),
    );

    if (query.isEmpty) return items;

    return items.where((item) {
      final haystack =
          '${item.poem.title} ${item.poem.author} ${item.poem.fullText}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _loadStories() async {
    if (_isLoadingStories) return;

    setState(() {
      _isLoadingStories = true;
      _storiesError = null;
    });

    try {
      final fetchedCollections = await _dbManager.fetchAllCollections();

      // RealtimeDBManager returns an unmodifiable list.
      // Create a mutable copy before sorting.
      final collections = List<StoryCollection>.from(fetchedCollections);

      collections.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _collections = collections;
        _storiesError = null;
      });
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('❌ DISCOVER STORY ERROR: $error');
      // ignore: avoid_print
      print('❌ DISCOVER STORY STACK: $stackTrace');

      if (!mounted) return;

      setState(() {
        _storiesError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStories = false;
        });
      }
    }

    try {
      await _dbManager.loadTogetherAIModels();
    } catch (error) {
      // ignore: avoid_print
      print('⚠️ TogetherAI model load error: $error');
    }
  }

  Future<void> _loadFirstBookPage({bool force = false}) async {
    if (_isLoadingBooks) return;
    if (!force && _books.isNotEmpty) return;

    if (force) {
      _loadedBookIds.clear();
      _completedBookPageUrls.clear();
      _books.clear();
      _nextBooksUrl = null;
      _hasLoadedAllBooks = false;
    }

    await _fetchBookPage(
      urlString: _firstBooksUrl,
      retryCount: 0,
      isFirstPage: true,
    );
  }

  Future<void> _loadNextBookPage() async {
    if (_mode != DiscoverMode.books ||
        _isSearchingBooks ||
        _isLoadingBooks ||
        _hasLoadedAllBooks) {
      return;
    }

    final next = _nextBooksUrl;
    if (next == null || next.isEmpty) return;

    if (_completedBookPageUrls.contains(next)) {
      if (!mounted) return;
      setState(() {
        _hasLoadedAllBooks = true;
        _nextBooksUrl = null;
      });
      return;
    }

    await _fetchBookPage(
      urlString: next,
      retryCount: 0,
      isFirstPage: false,
    );
  }

  Future<void> _fetchBookPage({
    required String urlString,
    required int retryCount,
    required bool isFirstPage,
  }) async {
    if (_isLoadingBooks) return;
    if (_completedBookPageUrls.contains(urlString)) return;

    if (mounted) {
      setState(() {
        _isLoadingBooks = true;
        _booksError = null;
      });
    }

    try {
      final json = await _getJson(
        urlString,
        timeout: const Duration(seconds: 15),
      );

      if (json is! Map) {
        throw const FormatException('Invalid Gutendex response.');
      }

      final result = GutendexResponse.fromJson(
        json.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );

      final safeBooks = result.results.where(_isAllowedBook).toList();
      final newBooks = <GutendexBook>[];

      for (final book in safeBooks) {
        if (_loadedBookIds.add(book.id)) {
          newBooks.add(book);
        }
      }

      if (!mounted) return;

      setState(() {
        _completedBookPageUrls.add(urlString);
        _books.addAll(newBooks);
        _nextBooksUrl = result.next;
        _hasLoadedAllBooks = result.next == null;
        _isLoadingBooks = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingBooks = false;
        _booksError = error;
      });

      final nextRetry = retryCount + 1;
      if (nextRetry <= _maxBookRetries) {
        await Future<void>.delayed(
          Duration(seconds: 1 << retryCount),
        );

        if (!mounted) return;

        await _fetchBookPage(
          urlString: urlString,
          retryCount: nextRetry,
          isFirstPage: isFirstPage,
        );
      } else {
        if (!mounted) return;
        setState(() {
          _nextBooksUrl = urlString;
          _hasLoadedAllBooks = false;
        });
      }
    }
  }

  Future<void> _fetchRandomPoems({
    int retryCount = 0,
    bool force = false,
  }) async {
    if (_isLoadingPoems) {
      // ignore: avoid_print
      print('⚠️ NORD POETRY: request skipped because another load is active');
      return;
    }

    if (force) {
      _loadedPoemKeys.clear();
      _poems.clear();
    }

    if (mounted) {
      setState(() {
        _isLoadingPoems = true;
        _poemsError = null;
      });
    }

    // ignore: avoid_print
    print('======================================');
    // ignore: avoid_print
    print('📜 NORD POETRY START');
    // ignore: avoid_print
    print('📜 URL: $_poetryCollectionUrl');
    // ignore: avoid_print
    print('======================================');

    try {
      final json = await _getJson(
        _poetryCollectionUrl,
        timeout: const Duration(seconds: 12),
      );

      final rawPoems = _extractNordPoemList(json);

      // ignore: avoid_print
      print('📜 NORD raw poems: ${rawPoems.length}');

      final parsed = <PoetryDBPoem>[];

      for (final item in rawPoems) {
        final poem = PoetryDBPoem.fromJson(item);

        if (poem.title.trim().isEmpty || poem.lines.isEmpty) {
          // ignore: avoid_print
          print(
            '⚠️ NORD skipped invalid poem: '
            'title="${poem.title}", lines=${poem.lines.length}',
          );
          continue;
        }

        if (!_isAllowedPoem(poem)) {
          // ignore: avoid_print
          print('🚫 NORD filtered poem: ${poem.title}');
          continue;
        }

        if (!_loadedPoemKeys.add(poem.uniqueKey)) {
          // ignore: avoid_print
          print('♻️ NORD duplicate skipped: ${poem.title}');
          continue;
        }

        parsed.add(poem);
      }

      if (!mounted) return;

      setState(() {
        _poems.addAll(parsed);
        _isLoadingPoems = false;
        _poemsError = null;
      });

      // ignore: avoid_print
      print('✅ NORD POETRY LOADED: ${parsed.length}');
      // ignore: avoid_print
      print('✅ TOTAL POEMS: ${_poems.length}');

      if (parsed.isNotEmpty) {
        unawaited(_loadPoemCovers(parsed));
      }
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('❌ NORD POETRY ERROR: $error');
      // ignore: avoid_print
      print('❌ NORD POETRY STACK: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoadingPoems = false;
        _poemsError = error;
      });
    } finally {
      // ignore: avoid_print
      print('📜 NORD POETRY END');
    }
  }

  List<Map<String, dynamic>> _extractNordPoemList(dynamic json) {
    dynamic candidate = json;

    if (candidate is Map) {
      candidate =
          candidate['data'] ??
          candidate['poems'] ??
          candidate['results'] ??
          candidate['items'] ??
          candidate['result'];

      if (candidate is Map) {
        candidate =
            candidate['poems'] ??
            candidate['results'] ??
            candidate['items'] ??
            candidate['data'];
      }
    }

    if (candidate is! List) {
      throw FormatException(
        'NordAPI returned ${candidate.runtimeType}; expected a poem list.',
      );
    }

    return candidate
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  Future<void> _loadPoemCovers(
    List<PoetryDBPoem> poems,
  ) async {
    // Open Library is only used for optional cover art.
    // The poem text always comes from NordAPI.
    for (final poem in poems) {
      if (!mounted) return;
      if (poem.coverUrl?.isNotEmpty == true) continue;

      try {
        // ignore: avoid_print
        print('🖼️ COVER search: "${poem.title}" — ${poem.author}');

        final uri = Uri.https(
          'openlibrary.org',
          '/search.json',
          {
            'title': poem.title,
            'author': poem.author,
            'limit': '1',
            'fields': 'cover_i,title,author_name',
          },
        );

        final json = await _getJson(
          uri.toString(),
          timeout: const Duration(seconds: 7),
        );

        if (json is! Map) {
          // ignore: avoid_print
          print('⚠️ COVER invalid response for "${poem.title}"');
          continue;
        }

        final docs = json['docs'];
        if (docs is! List || docs.isEmpty || docs.first is! Map) {
          // ignore: avoid_print
          print('ℹ️ COVER not found: "${poem.title}"');
          continue;
        }

        final first = Map<String, dynamic>.from(
          (docs.first as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );

        final coverId = _intValue(first['cover_i'], fallback: 0);
        if (coverId <= 0) {
          // ignore: avoid_print
          print('ℹ️ COVER id missing: "${poem.title}"');
          continue;
        }

        final coverUrl =
            'https://covers.openlibrary.org/b/id/$coverId-M.jpg';

        final index = _poems.indexWhere(
          (item) => item.uniqueKey == poem.uniqueKey,
        );

        if (index < 0 || !mounted) continue;

        setState(() {
          _poems[index] = _poems[index].copyWith(
            coverUrl: coverUrl,
          );
        });

        // ignore: avoid_print
        print('✅ COVER found: "${poem.title}" → $coverId');
      } catch (error) {
        // Cover failure must never break poem loading.
        // ignore: avoid_print
        print('⚠️ COVER error for "${poem.title}": $error');
      }
    }

    // ignore: avoid_print
    print('🖼️ COVER enrichment finished');
  }

  Future<dynamic> _getJson(
    String urlString, {
    required Duration timeout,
  }) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      throw const FormatException('Invalid URL.');
    }

    final client = HttpClient()
      ..connectionTimeout = timeout
      ..idleTimeout = timeout;

    try {
      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'NovelAI-Flutter/1.0',
      );

      final response = await request.close().timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: uri,
        );
      }

      final body = await utf8.decoder.bind(response).join().timeout(timeout);

      if (body.trim().isEmpty) {
        throw const FormatException('Empty response body.');
      }

      return jsonDecode(body);
    } finally {
      client.close(force: true);
    }
  }

  bool _isAllowedBook(GutendexBook book) {
    final metadata = [
      book.title,
      ...book.subjects,
      ...book.bookshelves,
      ...?book.summaries,
    ].join(' ').toLowerCase();

    const keywords = [
      'erotica',
      'erotic fiction',
      'erotic literature',
      'pornography',
      'pornographic',
      'pornographic literature',
      'obscene literature',
      'sex stories',
      'sex story',
      'sexual fiction',
      'explicit sexual',
      'sexual intercourse',
      'incest',
      'prostitution',
      'prostitute',
      'rape fiction',
    ];

    return !keywords.any(metadata.contains);
  }

  bool _isAllowedPoem(PoetryDBPoem poem) {
    final text =
        '${poem.title} ${poem.author} ${poem.fullText}'.toLowerCase();

    const keywords = [
      'erotica',
      'erotic poem',
      'erotic poetry',
      'pornography',
      'pornographic',
      'explicit sexual',
      'sexual intercourse',
      'sex story',
      'sex stories',
      'sexual acts',
      'oral sex',
      'anal sex',
      'masturbation',
      'incest',
      'prostitution',
      'prostitute',
    ];

    return !keywords.any(text.contains);
  }

  bool _isPremiumBook(int originalIndex) =>
      originalIndex >= _freeBookLimit;

  bool _isPremiumPoem(int originalIndex) =>
      originalIndex >= _freePoemLimit;

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels > 700) return;

    switch (_mode) {
      case DiscoverMode.stories:
        break;
      case DiscoverMode.books:
        unawaited(_loadNextBookPage());
        break;
      case DiscoverMode.poems:
        if (!_isSearchingPoems && !_isLoadingPoems) {
          unawaited(_fetchRandomPoems());
        }
        break;
    }
  }

  void _changeMode(DiscoverMode mode) {
    if (_mode == mode) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _mode = mode;
      _searchController.text = switch (mode) {
        DiscoverMode.stories => '',
        DiscoverMode.books => _bookSearchText,
        DiscoverMode.poems => _poemSearchText,
      };
    });

    if (mode == DiscoverMode.books && _books.isEmpty) {
      unawaited(_loadFirstBookPage());
    } else if (mode == DiscoverMode.poems && _poems.isEmpty) {
      unawaited(_fetchRandomPoems());
    }
  }

  void _searchChanged(String value) {
    setState(() {
      switch (_mode) {
        case DiscoverMode.stories:
          break;
        case DiscoverMode.books:
          _bookSearchText = value;
          break;
        case DiscoverMode.poems:
          _poemSearchText = value;
          break;
      }
    });
  }

  Future<void> _handleBookTap(_DisplayedBook item) async {
    final locked = _isPremiumBook(item.originalIndex) && !_isSubscribed;

    if (locked) {
      await _showLockedContent();
      return;
    }

    if (widget.onBookTap != null) {
      await widget.onBookTap!(item.book);
      return;
    }

    final url = item.book.readingUrl;

    if (!mounted) return;

    if (url == null || url.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unable to Open'),
          content: const Text(
            'This book does not have a readable online format.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookChapterReaderScreen(
          bookId: item.book.id,
          bookTitle: item.book.title,
          bookAuthor: item.book.authorName,
          bookUrl: url,
          bookCoverUrl: item.book.coverUrl,
          bookUrls: item.book.formats.values
              .where((value) => value.trim().isNotEmpty)
              .toList(),
        ),
      ),
    );
  }

  Future<void> _handlePoemTap(_DisplayedPoem item) async {
    final locked = _isPremiumPoem(item.originalIndex) && !_isSubscribed;

    if (locked) {
      await _showLockedContent();
      return;
    }

    if (widget.onPoemTap != null) {
      await widget.onPoemTap!(item.poem);
      return;
    }

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PoemDetailScreen(
          poem: item.poem,
        ),
      ),
    );
  }

  Future<void> _showLockedContent() async {
    if (widget.onLockedTap != null) {
      await widget.onLockedTap!();
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  'Unlock PRO',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect onLockedTap to your Flutter subscription screen.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleStoryTap(
    Story story,
    StoryCollection collection,
  ) async {
    if (widget.onStoryTap != null) {
      await widget.onStoryTap!(story, collection);
      return;
    }

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryDetailScreen(
          story: story,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_mode) {
      DiscoverMode.stories => 'Discover Stories',
      DiscoverMode.books => 'Books',
      DiscoverMode.poems => 'Poems',
    };

    return Scaffold(
      backgroundColor: _discoverBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const SizedBox(width: 42),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _discoverText(context),
                          ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: _buildModeSegment(),
            ),
            if (_mode != DiscoverMode.stories)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchChanged,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: _mode == DiscoverMode.books
                        ? 'Search books or authors'
                        : 'Search poems or authors',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _searchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: _discoverCard(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: switch (_mode) {
                DiscoverMode.stories => _buildStories(),
                DiscoverMode.books => _buildBooks(),
                DiscoverMode.poems => _buildPoems(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSegment() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _discoverSegmentBackground(context),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DiscoverSegmentItem(
              label: 'Stories',
              selected: _mode == DiscoverMode.stories,
              onTap: () => _changeMode(DiscoverMode.stories),
            ),
          ),
          Expanded(
            child: _DiscoverSegmentItem(
              label: 'Books',
              selected: _mode == DiscoverMode.books,
              onTap: () => _changeMode(DiscoverMode.books),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    if (_isLoadingStories && _collections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_storiesError != null && _collections.isEmpty) {
      return _ErrorState(
        title: 'Unable to load stories',
        onRetry: _loadStories,
      );
    }

    if (_collections.isEmpty) {
      return const _EmptyState(
        icon: Icons.auto_stories_outlined,
        text: 'No stories found.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStories,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        itemCount: _collections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 22),
        itemBuilder: (context, index) {
          final collection = _collections[index];

          final stories = [...collection.stories]
            ..sort(
              (a, b) => (a.theme ?? '0').compareTo(b.theme ?? '0'),
            );

          return _StoryCollectionSection(
            collection: collection,
            stories: stories,
            onStoryTap: (story) => _handleStoryTap(
              story,
              collection,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooks() {
    final items = _displayedBooks;

    if (_isLoadingBooks && _books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_booksError != null && _books.isEmpty) {
      return _ErrorState(
        title: 'Unable to load books',
        onRetry: () => _loadFirstBookPage(force: true),
      );
    }

    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.menu_book_rounded,
        text: 'No books found.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_isSearchingBooks) return;
        await _loadFirstBookPage(force: true);
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
        itemCount: items.length + (_isLoadingBooks ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = items[index];
          final premium =
              _isPremiumBook(item.originalIndex) && !_isSubscribed;

          return _BookTile(
            book: item.book,
            premium: premium,
            onTap: () => _handleBookTap(item),
          );
        },
      ),
    );
  }

  Widget _buildPoems() {
    final items = _displayedPoems;

    if (_isLoadingPoems && _poems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_poemsError != null && _poems.isEmpty) {
      return _ErrorState(
        title: 'Unable to load poems',
        onRetry: () => _fetchRandomPoems(force: true),
      );
    }

    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.history_edu_rounded,
        text: 'No poems found.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_isSearchingPoems) return;
        await _fetchRandomPoems(force: true);
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
        itemCount: items.length + (_isLoadingPoems ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = items[index];
          final premium =
              _isPremiumPoem(item.originalIndex) && !_isSubscribed;

          return _PoemTile(
            poem: item.poem,
            premium: premium,
            onTap: () => _handlePoemTap(item),
          );
        },
      ),
    );
  }
}

bool _discoverIsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _discoverBackground(BuildContext context) =>
    _discoverIsDark(context)
        ? const Color(0xFF19102A)
        : const Color(0xFFF8F8F8);

Color _discoverSegmentBackground(BuildContext context) =>
    _discoverIsDark(context)
        ? const Color(0xFF30283E)
        : const Color(0xFFEFEDEF);

Color _discoverSegmentSelected(BuildContext context) =>
    _discoverIsDark(context)
        ? const Color(0xFF777181)
        : Colors.white;

Color _discoverCard(BuildContext context) =>
    _discoverIsDark(context)
        ? const Color(0xFF30283E)
        : Colors.white;

Color _discoverText(BuildContext context) =>
    _discoverIsDark(context)
        ? Colors.white
        : const Color(0xFF1D1A20);

Color _discoverMutedText(BuildContext context) =>
    _discoverIsDark(context)
        ? const Color(0xFFD2CDD8)
        : const Color(0xFF6F6876);

Color _discoverImagePlaceholder(BuildContext context) =>
    _discoverIsDark(context)
        ? const Color(0xFF241A34)
        : const Color(0xFFF0E4DF);

class _DiscoverSegmentItem extends StatelessWidget {
  const _DiscoverSegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _discoverSegmentSelected(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? _discoverText(context)
                  : _discoverMutedText(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryCollectionSection extends StatelessWidget {
  const _StoryCollectionSection({
    required this.collection,
    required this.stories,
    required this.onStoryTap,
  });

  final StoryCollection collection;
  final List<Story> stories;
  final ValueChanged<Story> onStoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          collection.name.isEmpty ? 'Unknown' : collection.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: _discoverText(context),
              ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final story = stories[index];

              return SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () => onStoryTap(story),
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    color: _discoverCard(context),
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: _NetworkImageOrPlaceholder(
                              url: story.thumbUrl,
                              icon: Icons.auto_stories_rounded,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            story.title?.isNotEmpty == true
                                ? story.title!
                                : 'Story',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _discoverText(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({
    required this.book,
    required this.premium,
    required this.onTap,
  });

  final GutendexBook book;
  final bool premium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      leading: SizedBox(
        width: 55,
        height: 78,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: _NetworkImageOrPlaceholder(
            url: book.coverUrl,
            icon: Icons.book_rounded,
          ),
        ),
      ),
      title: Text(
        book.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          book.authorName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: premium
          ? const _ProBadge()
          : const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _PoemTile extends StatelessWidget {
  const _PoemTile({
    required this.poem,
    required this.premium,
    required this.onTap,
  });

  final PoetryDBPoem poem;
  final bool premium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = StringBuffer(poem.author);

    if (poem.preview.isNotEmpty) {
      details.write('\n${poem.preview}');
    }

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 56,
          height: 72,
          child: _NetworkImageOrPlaceholder(
            url: poem.coverUrl,
            icon: Icons.history_edu_rounded,
          ),
        ),
      ),
      title: Text(
        poem.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          details.toString(),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: premium
          ? const _ProBadge()
          : const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 13,
            color: Colors.orange,
          ),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImageOrPlaceholder extends StatelessWidget {
  const _NetworkImageOrPlaceholder({
    required this.url,
    required this.icon,
  });

  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final value = _resolveImageUrl(url);

    if (value == null) {
      return _ImagePlaceholder(icon: icon);
    }

    return Image.network(
      value,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, error, __) {
        // ignore: avoid_print
        print('❌ IMAGE LOAD FAILED: $value');
        // ignore: avoid_print
        print('❌ IMAGE ERROR: $error');
        return _ImagePlaceholder(icon: icon);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: _discoverImagePlaceholder(context),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}

String? _resolveImageUrl(String? rawValue) {
  final value = rawValue?.trim();

  if (value == null || value.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(value);

  // Already a normal network URL (Gutendex covers, etc.).
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    // Convert Google Drive share URLs to a direct image URL when possible.
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

  // Firebase stores Google Drive file IDs for story artwork.
  // This matches the URL format used by the iOS app.
  return 'https://drive.google.com/uc?export=download&id=$value';
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _discoverImagePlaceholder(context),
      child: Center(
        child: Icon(
          icon,
          size: 28,
        ),
      ),
    );
  }
}

class _PoemDetailScreen extends StatelessWidget {
  const _PoemDetailScreen({
    required this.poem,
  });

  final PoetryDBPoem poem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(poem.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Text(
            poem.author,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          if (poem.fullText.isNotEmpty)
            SelectableText(
              poem.fullText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                  ),
            )
          else
            Text(
              'Poem text is unavailable.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                  ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.title,
    required this.onRetry,
  });

  final String title;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => unawaited(onRetry()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class _DisplayedBook {
  const _DisplayedBook({
    required this.book,
    required this.originalIndex,
  });

  final GutendexBook book;
  final int originalIndex;
}

class _DisplayedPoem {
  const _DisplayedPoem({
    required this.poem,
    required this.originalIndex,
  });

  final PoetryDBPoem poem;
  final int originalIndex;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item?.toString() ?? '').toList();
}

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}
