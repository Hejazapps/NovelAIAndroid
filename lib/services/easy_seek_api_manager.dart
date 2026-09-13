import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'realtime_db_manager.dart';

class TogetherAIMessage {
  const TogetherAIMessage({required this.content, required this.role});

  final String content;
  final String role;

  Map<String, dynamic> toJson() => {'content': content, 'role': role};

  factory TogetherAIMessage.user(String content) =>
      TogetherAIMessage(content: content, role: 'user');

  factory TogetherAIMessage.system(String content) =>
      TogetherAIMessage(content: content, role: 'system');

  factory TogetherAIMessage.assistant(String content) =>
      TogetherAIMessage(content: content, role: 'assistant');
}

class TogetherAIModel {
  const TogetherAIModel({required this.key, required this.rawValue});

  final String key;
  final String rawValue;

  Map<String, dynamic> toJson() => {'key': key, 'rawValue': rawValue};

  factory TogetherAIModel.fromJson(Map<String, dynamic> json) {
    return TogetherAIModel(
      key: json['key']?.toString() ?? '',
      rawValue: json['rawValue']?.toString() ?? '',
    );
  }

  static const List<TogetherAIModel> fallbackModels = [
    TogetherAIModel(
      key: 'deepSeek_V4_Pro',
      rawValue: 'deepseek-ai/DeepSeek-V4-Pro-0813',
    ),
    TogetherAIModel(
      key: 'gptOSS120B',
      rawValue: 'openai/gpt-oss-120b',
    ),
    TogetherAIModel(
      key: 'kimiK2_5',
      rawValue: 'moonshotai/Kimi-K2.5',
    ),
    TogetherAIModel(
      key: 'miniMaxM2_5',
      rawValue: 'MiniMaxAI/MiniMax-M2.5',
    ),
    TogetherAIModel(
      key: 'glm5',
      rawValue: 'zai-org/GLM-5',
    ),
  ];
}

class EasySeekApiManager {
  EasySeekApiManager._() {
    _loadCachedModels();
    refreshModelsFromFirebase();
  }

  static final EasySeekApiManager shared = EasySeekApiManager._();

  final RealtimeDBManager _realtimeDBManager = RealtimeDBManager();

  // Android AIProxy configuration.
  // This mirrors the Swift EasySeekApiManager setup:
  // AIProxy.togetherAIService(partialKey: ..., serviceURL: ...)
  static const String _aiProxyPartialKey =
      'v2|6248b0b4|1VCDYVa_n17F1kAY';

  static const String _aiProxyServiceUrl =
      'https://api.aiproxy.com/99f695d2/c146199a';

  final _AIProxyTogetherService _togetherAIService = _AIProxyTogetherService(
    partialKey: _aiProxyPartialKey,
    serviceUrl: _aiProxyServiceUrl,
  );

  static const String _modelsCacheKey = 'cachedTogetherAIModels.v1';

  List<TogetherAIModel> _storedModels =
      List<TogetherAIModel>.from(TogetherAIModel.fallbackModels);

  TogetherAIModel activeModel = TogetherAIModel.fallbackModels.first;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _generation = 0;
  StreamSubscription<String>? _activeStreamSubscription;

  final _AsyncGate _requestGate = _AsyncGate(maxConcurrent: 2);
  final _BookModelHealthTracker _bookModelHealthTracker =
      _BookModelHealthTracker();

  static const Duration _bookRateLimitCooldown = Duration(minutes: 10);
  static const int _maxRateLimitRetries = 4;
  static const Duration _fallbackModelDelay = Duration(milliseconds: 1500);

  Future<void> _loadCachedModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_modelsCacheKey);

      if (cachedJson == null || cachedJson.isEmpty) {
        print('ℹ️ [EasySeekApiManager] No model cache found; using fallback models');
        return;
      }

      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) return;

      final seenKeys = <String>{};
      final seenModelIDs = <String>{};
      final valid = <TogetherAIModel>[];

      for (final raw in decoded) {
        if (raw is! Map) continue;
        final model = TogetherAIModel.fromJson(Map<String, dynamic>.from(raw));
        final key = model.key.trim();
        final modelID = model.rawValue.trim();
        if (key.isEmpty ||
            modelID.isEmpty ||
            !modelID.contains('/') ||
            !seenKeys.add(key) ||
            !seenModelIDs.add(modelID)) {
          continue;
        }
        valid.add(TogetherAIModel(key: key, rawValue: modelID));
      }

      if (valid.isEmpty) return;
      _storedModels = valid;
      activeModel = valid.first;
      print('📦 [EasySeekApiManager] Loaded ${valid.length} cached model(s)');
    } catch (error) {
      print('⚠️ [EasySeekApiManager] Could not decode model cache: $error');
    }
  }

  Future<void> _saveModelsToCache(List<TogetherAIModel> models) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _modelsCacheKey,
        jsonEncode(models.map((e) => e.toJson()).toList()),
      );
      print('💾 [EasySeekApiManager] Cached ${models.length} Firebase model(s)');
    } catch (error) {
      print('⚠️ [EasySeekApiManager] Could not save model cache: $error');
    }
  }

  List<TogetherAIModel> get _availableModels =>
      List<TogetherAIModel>.unmodifiable(_storedModels);

  Future<void> refreshModelsFromFirebase() async {
    try {
      final firebaseItems = await _realtimeDBManager.fetchTogetherAIModels();
      final seenModelIDs = <String>{};
      final seenKeys = <String>{};
      final validModels = <TogetherAIModel>[];

      for (final item in firebaseItems) {
        final key = item.key.trim();
        final modelID = item.modelID.trim();
        if (key.isEmpty ||
            modelID.isEmpty ||
            !modelID.contains('/') ||
            !seenKeys.add(key) ||
            !seenModelIDs.add(modelID)) {
          continue;
        }
        validModels.add(TogetherAIModel(key: key, rawValue: modelID));
      }

      if (validModels.isEmpty) {
        print('⚠️ [EasySeekApiManager] Firebase returned no valid models; keeping cached or fallback models');
        return;
      }

      _storedModels = validModels;
      activeModel = validModels.first;
      await _saveModelsToCache(validModels);
      print('✅ [EasySeekApiManager] Applied ${validModels.length} Firebase model(s)');
    } catch (error) {
      print('⚠️ [EasySeekApiManager] Firebase unavailable; keeping cached or fallback models');
    }
  }

  Future<void> stopStreaming() async {
    _generation++;
    await _activeStreamSubscription?.cancel();
    _activeStreamSubscription = null;
    _isLoading = false;
  }

  bool _isCancelled(int generation) => generation != _generation;

  String _quickFormat(String content) => content.replaceAll('**', '');

  String _filterReasoningTokens(String content) {
    final patterns = <RegExp>[
      RegExp(r'<think>.*?</think>', caseSensitive: false, dotAll: true),
      RegExp(r'<thinking>.*?</thinking>', caseSensitive: false, dotAll: true),
      RegExp(r'<reason>.*?</reason>', caseSensitive: false, dotAll: true),
      RegExp(r'<reasoning>.*?</reasoning>', caseSensitive: false, dotAll: true),
      RegExp(r'\*thinking\*.*?\*/thinking\*', caseSensitive: false, dotAll: true),
      RegExp(r'\[thinking\].*?\[/thinking\]', caseSensitive: false, dotAll: true),
    ];

    var filtered = content;
    for (final pattern in patterns) {
      filtered = filtered.replaceAll(pattern, '');
    }
    return filtered.trim();
  }

  bool _isRateLimitError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('429') ||
        text.contains('rate_limit') ||
        text.contains('rate limit') ||
        text.contains('too many requests');
  }

  Duration _rateLimitDelay(int retry) =>
      Duration(seconds: pow(2.0, retry + 1).toInt());

  Future<bool> _sleepSafely(Duration duration, int generation) async {
    if (_isCancelled(generation)) return false;
    await Future<void>.delayed(duration);
    return !_isCancelled(generation);
  }

  Future<_StreamAttemptResult> _attemptStreamOnce({
    required String message,
    List<TogetherAIMessage>? messages,
    required TogetherAIModel model,
    required int maxTokens,
    required int generation,
    required void Function(String text) onUpdate,
  }) async {
    if (_isCancelled(generation)) return _StreamAttemptResult.cancelled;

    final requestMessages =
        messages ?? [TogetherAIMessage(content: message, role: 'user')];

    var formattedResponse = '';
    var wordBuffer = '';
    var boldCarry = false;
    var receivedAnyContent = false;
    var lastUpdateTime = DateTime.now();

    void appendStripped(String chunk) {
      var s = chunk;
      if (boldCarry) {
        s = '*$s';
        boldCarry = false;
      }
      if (s.endsWith('*') && !s.endsWith('**')) {
        s = s.substring(0, s.length - 1);
        boldCarry = true;
      }
      formattedResponse += _quickFormat(s);
    }

    try {
      final stream = _togetherAIService.streamingChatCompletionRequest(
        messages: requestMessages,
        model: model.rawValue,
        maxTokens: maxTokens,
        temperature: 0.7,
      );

      final completer = Completer<_StreamAttemptResult>();
      _activeStreamSubscription = stream.listen(
        (content) async {
          if (_isCancelled(generation)) {
            if (!completer.isCompleted) {
              completer.complete(_StreamAttemptResult.cancelled);
            }
            return;
          }

          if (content.isEmpty) return;
          receivedAnyContent = true;
          wordBuffer += content;

          if (wordBuffer.contains(' ') ||
              wordBuffer.contains('.') ||
              wordBuffer.contains(',') ||
              wordBuffer.contains('!') ||
              wordBuffer.contains('?') ||
              wordBuffer.contains('\n') ||
              wordBuffer.length > 10) {
            appendStripped(wordBuffer);
            wordBuffer = '';
            onUpdate(formattedResponse);

            final elapsed = DateTime.now().difference(lastUpdateTime);
            if (elapsed < const Duration(milliseconds: 100)) {
              await Future<void>.delayed(const Duration(milliseconds: 80));
            }
            lastUpdateTime = DateTime.now();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (completer.isCompleted) return;
          if (_isCancelled(generation)) {
            completer.complete(_StreamAttemptResult.cancelled);
          } else if (_isRateLimitError(error) && !receivedAnyContent) {
            completer.complete(_StreamAttemptResult.rateLimited);
          } else {
            completer.complete(_StreamAttemptResult.failed);
          }
        },
        onDone: () {
          if (completer.isCompleted) return;
          if (_isCancelled(generation)) {
            completer.complete(_StreamAttemptResult.cancelled);
            return;
          }
          if (wordBuffer.isNotEmpty) {
            appendStripped(wordBuffer);
            wordBuffer = '';
            onUpdate(formattedResponse);
          }
          print('✅ [EasySeekApiManager] Streaming completed successfully with ${model.rawValue}');
          completer.complete(_StreamAttemptResult.success);
        },
      );

      return await completer.future;
    } catch (error) {
      if (_isCancelled(generation)) return _StreamAttemptResult.cancelled;
      if (_isRateLimitError(error)) return _StreamAttemptResult.rateLimited;
      return _StreamAttemptResult.failed;
    }
  }

  Future<_StreamAttemptResult> _attemptStreamWithRateLimitRetry({
    required String message,
    List<TogetherAIMessage>? messages,
    required TogetherAIModel model,
    required int maxTokens,
    required int generation,
    required void Function(String text) onUpdate,
  }) async {
    await _requestGate.acquire();
    try {
      var retry = 0;
      while (true) {
        if (_isCancelled(generation)) return _StreamAttemptResult.cancelled;

        final result = await _attemptStreamOnce(
          message: message,
          messages: messages,
          model: model,
          maxTokens: maxTokens,
          generation: generation,
          onUpdate: onUpdate,
        );

        if (result != _StreamAttemptResult.rateLimited) return result;
        if (retry >= _maxRateLimitRetries) {
          print('❌ [EasySeekApiManager] 429 retries exhausted for ${model.rawValue}');
          return _StreamAttemptResult.rateLimited;
        }

        final delay = _rateLimitDelay(retry);
        print('⏳ [EasySeekApiManager] 429 ${model.rawValue} — retry ${retry + 1}/$_maxRateLimitRetries in ${delay.inSeconds}s');
        final shouldContinue = await _sleepSafely(delay, generation);
        if (!shouldContinue) return _StreamAttemptResult.cancelled;
        retry++;
      }
    } finally {
      _requestGate.release();
    }
  }

  Future<void> streamResponse({
    required String message,
    List<TogetherAIMessage>? messages,
    int maxTokens = 7000,
    required void Function(String text) onUpdate,
    required void Function(bool success) onCompletion,
  }) async {
    if (_isLoading) {
      print('⚠️ [EasySeekApiManager] A streaming request is already in progress');
      onCompletion(false);
      return;
    }

    _isLoading = true;
    final generation = ++_generation;
    var success = false;
    final models = _availableModels;

    try {
      for (var index = 0; index < models.length; index++) {
        if (_isCancelled(generation)) break;
        final model = models[index];
        activeModel = model;
        print('🌐 [EasySeekApiManager] Starting stream with ${model.rawValue}');

        final result = await _attemptStreamWithRateLimitRetry(
          message: message,
          messages: messages,
          model: model,
          maxTokens: maxTokens,
          generation: generation,
          onUpdate: onUpdate,
        );

        if (result == _StreamAttemptResult.success) {
          success = true;
          break;
        }

        if ((result == _StreamAttemptResult.rateLimited ||
                result == _StreamAttemptResult.failed) &&
            index < models.length - 1) {
          final shouldContinue =
              await _sleepSafely(_fallbackModelDelay, generation);
          if (!shouldContinue) break;
        }
      }

      if (!success && !_isCancelled(generation)) {
        onUpdate('Server unavailable. Please try again later.');
      }
    } finally {
      if (!_isCancelled(generation)) {
        _isLoading = false;
        _activeStreamSubscription = null;
        onCompletion(success);
      }
    }
  }

  Future<_CompletionAttemptResult> _completionForModelWithRateLimitRetry({
    required List<TogetherAIMessage> messages,
    required TogetherAIModel model,
    required int maxTokens,
    required double temperature,
    required Duration timeout,
    required String logName,
    required int generation,
  }) async {
    await _requestGate.acquire();
    try {
      var retry = 0;
      while (true) {
        if (_isCancelled(generation)) {
          return const _CompletionAttemptResult.cancelled();
        }

        try {
          final content = await _togetherAIService.chatCompletionRequest(
            messages: messages,
            model: model.rawValue,
            maxTokens: maxTokens,
            temperature: temperature,
            timeout: timeout,
          );

          final cleanContent = _filterReasoningTokens(content).trim();
          if (cleanContent.isNotEmpty) {
            print('✅ [EasySeekApiManager] $logName completed with ${model.rawValue}');
            return _CompletionAttemptResult.content(cleanContent);
          }
          return const _CompletionAttemptResult.failed();
        } catch (error) {
          if (!_isRateLimitError(error)) {
            return const _CompletionAttemptResult.failed();
          }

          if (retry >= _maxRateLimitRetries) {
            return const _CompletionAttemptResult.rateLimited();
          }

          final delay = _rateLimitDelay(retry);
          print('⏳ [EasySeekApiManager] $logName 429 ${model.rawValue} — retry ${retry + 1}/$_maxRateLimitRetries in ${delay.inSeconds}s');
          final shouldContinue = await _sleepSafely(delay, generation);
          if (!shouldContinue) {
            return const _CompletionAttemptResult.cancelled();
          }
          retry++;
        }
      }
    } finally {
      _requestGate.release();
    }
  }

  Future<String?> completeResponse({
    required List<TogetherAIMessage> messages,
    int maxTokens = 700,
    double temperature = 0.2,
  }) async {
    final generation = _generation;
    final models = _availableModels;

    for (var index = 0; index < models.length; index++) {
      final model = models[index];
      activeModel = model;
      final result = await _completionForModelWithRateLimitRetry(
        messages: messages,
        model: model,
        maxTokens: maxTokens,
        temperature: temperature,
        timeout: const Duration(seconds: 1),
        logName: 'Completion',
        generation: generation,
      );

      if (result.type == _CompletionAttemptType.content) return result.content;
      if (result.type == _CompletionAttemptType.cancelled) return null;

      if (index < models.length - 1) {
        final shouldContinue =
            await _sleepSafely(_fallbackModelDelay, generation);
        if (!shouldContinue) return null;
      }
    }
    return null;
  }

  Future<List<String?>> completeBatch({
    required List<List<TogetherAIMessage>> requests,
    int maxTokens = 700,
    double temperature = 0.2,
  }) async {
    return Future.wait(
      requests.map(
        (messages) => completeResponse(
          messages: messages,
          maxTokens: maxTokens,
          temperature: temperature,
        ),
      ),
    );
  }

  Future<String?> completeBookResponse({
    required List<TogetherAIMessage> messages,
    int maxTokens = 3500,
    double temperature = 0.8,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final generation = _generation;
    final models = await _bookModelHealthTracker.orderedModels(_availableModels);

    for (var index = 0; index < models.length; index++) {
      final model = models[index];
      activeModel = model;
      print('📚 [EasySeekApiManager] Starting book completion with ${model.rawValue}');

      final result = await _completionForModelWithRateLimitRetry(
        messages: messages,
        model: model,
        maxTokens: maxTokens,
        temperature: temperature,
        timeout: timeout,
        logName: 'Book completion',
        generation: generation,
      );

      switch (result.type) {
        case _CompletionAttemptType.content:
          await _bookModelHealthTracker.markSuccessful(model.rawValue);
          print('📌 [EasySeekApiManager] Book preferred model is now ${model.rawValue}');
          return result.content;
        case _CompletionAttemptType.cancelled:
          return null;
        case _CompletionAttemptType.rateLimited:
          await _bookModelHealthTracker.markRateLimited(
            modelID: model.rawValue,
            cooldown: _bookRateLimitCooldown,
          );
          print('🧊 [EasySeekApiManager] ${model.rawValue} put on 10-minute book cooldown after repeated 429');
          if (index < models.length - 1) {
            final shouldContinue = await _sleepSafely(
              const Duration(milliseconds: 500),
              generation,
            );
            if (!shouldContinue) return null;
          }
          break;
        case _CompletionAttemptType.failed:
          if (index < models.length - 1) {
            final shouldContinue =
                await _sleepSafely(_fallbackModelDelay, generation);
            if (!shouldContinue) return null;
          }
      }
    }
    return null;
  }

  Future<void> resetBookModelPreference() async {
    await _bookModelHealthTracker.clear();
    print('♻️ [EasySeekApiManager] Book model preference/cooldowns reset');
  }

  Future<String> generateTitle({required String conversation}) async {
    final truncated = conversation.length > 500
        ? conversation.substring(0, 500)
        : conversation;

    final result = await completeResponse(
      messages: [
        TogetherAIMessage.user(
          'Create a short, descriptive title (maximum 6 words) for this conversation:\n$truncated\nRespond with only the title, no explanation.',
        ),
      ],
      maxTokens: 15,
      temperature: 0.3,
    );

    final clean = (result ?? '').trim().replaceAll('"', '');
    return clean.isEmpty ? 'New Conversation' : clean;
  }
}

class _AIProxyTogetherService {
  _AIProxyTogetherService({
    required this.partialKey,
    required this.serviceUrl,
  });

  final String partialKey;
  final String serviceUrl;

  String get _chatUrl {
    final base = serviceUrl.endsWith('/')
        ? serviceUrl.substring(0, serviceUrl.length - 1)
        : serviceUrl;
    return '$base/v1/chat/completions';
  }

  Future<String> chatCompletionRequest({
    required List<TogetherAIMessage> messages,
    required String model,
    required int maxTokens,
    required double temperature,
    required Duration timeout,
  }) async {
    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(_chatUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $partialKey',
            },
            body: jsonEncode({
              'messages': messages.map((e) => e.toJson()).toList(),
              'model': model,
              'max_tokens': maxTokens,
              'temperature': temperature,
              'stream': false,
            }),
          )
          .timeout(timeout);

      final text = utf8.decode(response.bodyBytes);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _AIProxyRequestException(response.statusCode, text);
      }

      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return '';
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) return '';
      final first = choices.first;
      if (first is! Map) return '';
      final choice = Map<String, dynamic>.from(first);
      final message = choice['message'];
      if (message is Map) {
        return Map<String, dynamic>.from(message)['content']?.toString() ?? '';
      }
      return choice['text']?.toString() ?? '';
    } finally {
      client.close();
    }
  }

  Stream<String> streamingChatCompletionRequest({
    required List<TogetherAIMessage> messages,
    required String model,
    required int maxTokens,
    required double temperature,
  }) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse(_chatUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Authorization': 'Bearer $partialKey',
      });
      request.body = jsonEncode({
        'messages': messages.map((e) => e.toJson()).toList(),
        'model': model,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'stream': true,
      });

      final response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        throw _AIProxyRequestException(response.statusCode, body);
      }

      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty) continue;
        if (payload == '[DONE]') break;

        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) continue;
        final choices = decoded['choices'];
        if (choices is! List || choices.isEmpty) continue;
        final first = choices.first;
        if (first is! Map) continue;
        final delta = Map<String, dynamic>.from(first)['delta'];
        if (delta is Map) {
          final content = Map<String, dynamic>.from(delta)['content']?.toString();
          if (content != null && content.isNotEmpty) yield content;
        }
      }
    } finally {
      client.close();
    }
  }
}

class _AIProxyRequestException implements Exception {
  const _AIProxyRequestException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'HTTP $statusCode: $body';
}

class _AsyncGate {
  _AsyncGate({required this.maxConcurrent});

  final int maxConcurrent;
  int _activeCount = 0;
  final List<Completer<void>> _waiters = [];

  Future<void> acquire() async {
    if (_activeCount < maxConcurrent) {
      _activeCount++;
      return;
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  void release() {
    if (_waiters.isEmpty) {
      _activeCount = max(0, _activeCount - 1);
      return;
    }
    _waiters.removeAt(0).complete();
  }
}

class _BookModelHealthTracker {
  final Map<String, DateTime> _blockedUntil = {};
  String? _preferredModelID;

  Future<List<TogetherAIModel>> orderedModels(
      List<TogetherAIModel> models) async {
    final now = DateTime.now();
    _blockedUntil.removeWhere((_, until) => !until.isAfter(now));

    var usable = models.where((model) {
      final until = _blockedUntil[model.rawValue];
      return until == null || !until.isAfter(now);
    }).toList();

    if (usable.isEmpty) usable = List<TogetherAIModel>.from(models);

    final preferred = _preferredModelID;
    if (preferred != null) {
      final index = usable.indexWhere((m) => m.rawValue == preferred);
      if (index >= 0) {
        final model = usable.removeAt(index);
        usable.insert(0, model);
      }
    }
    return usable;
  }

  Future<void> markRateLimited({
    required String modelID,
    required Duration cooldown,
  }) async {
    _blockedUntil[modelID] = DateTime.now().add(cooldown);
    if (_preferredModelID == modelID) _preferredModelID = null;
  }

  Future<void> markSuccessful(String modelID) async {
    _preferredModelID = modelID;
    _blockedUntil.remove(modelID);
  }

  Future<void> clear() async {
    _blockedUntil.clear();
    _preferredModelID = null;
  }
}

enum _StreamAttemptResult { success, rateLimited, failed, cancelled }

enum _CompletionAttemptType { content, rateLimited, failed, cancelled }

class _CompletionAttemptResult {
  const _CompletionAttemptResult._({required this.type, this.content});
  const _CompletionAttemptResult.content(String content)
      : this._(type: _CompletionAttemptType.content, content: content);
  const _CompletionAttemptResult.rateLimited()
      : this._(type: _CompletionAttemptType.rateLimited);
  const _CompletionAttemptResult.failed()
      : this._(type: _CompletionAttemptType.failed);
  const _CompletionAttemptResult.cancelled()
      : this._(type: _CompletionAttemptType.cancelled);

  final _CompletionAttemptType type;
  final String? content;
}
