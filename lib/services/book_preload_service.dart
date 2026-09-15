import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// App-level preload cache for the first Gutendex Books page.
///
/// It starts at app launch and keeps the first response in memory for the
/// lifetime of the process. DiscoverScreen can consume it immediately instead
/// of starting the same request again.
class BookPreloadService {
  BookPreloadService._();

  static final BookPreloadService instance = BookPreloadService._();

  static const String firstBooksUrl =
      'https://gutendex.com/books?languages=en&copyright=false&sort=popular';

  Future<dynamic>? _firstPageFuture;
  dynamic _firstPageJson;

  dynamic get cachedFirstPageJson => _firstPageJson;

  Future<dynamic> preload() {
    final cached = _firstPageJson;
    if (cached != null) return Future<dynamic>.value(cached);

    final existing = _firstPageFuture;
    if (existing != null) return existing;

    final future = _fetchJson(firstBooksUrl);
    _firstPageFuture = future;

    future.then((value) {
      _firstPageJson = value;
    }).catchError((_) {
      // A failed preload must not prevent DiscoverScreen from retrying later.
      _firstPageFuture = null;
    });

    return future;
  }

  Future<dynamic> getFirstPage({bool force = false}) async {
    if (force) {
      _firstPageJson = null;
      _firstPageFuture = null;
    }

    final cached = _firstPageJson;
    if (cached != null) return cached;

    return preload();
  }

  Future<dynamic> _fetchJson(String urlString) async {
    const timeout = Duration(seconds: 15);
    final uri = Uri.parse(urlString);

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
        throw HttpException('HTTP ${response.statusCode}', uri: uri);
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
}
