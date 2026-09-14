import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/easy_seek_api_manager.dart';
import 'chat_models.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    EasySeekApiManager? apiManager,
  }) : _apiManager = apiManager ?? EasySeekApiManager.shared;

  static const String _storageKey = 'chatConversationsV1';
  static const int _maxContextMessages = 12;

  final EasySeekApiManager _apiManager;

  final List<ChatConversationModel> _conversations =
      <ChatConversationModel>[];

  ChatConversationModel? _activeConversation;

  bool _isLoading = true;
  bool _isStreaming = false;
  bool _streamCancelled = false;

  List<ChatConversationModel> get conversations =>
      List.unmodifiable(_conversations);

  ChatConversationModel? get activeConversation => _activeConversation;

  List<ChatMessageModel> get messages =>
      List.unmodifiable(_activeConversation?.messages ?? const []);

  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = ChatConversationModel.decodeList(
      prefs.getString(_storageKey),
    );

    stored.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    _conversations
      ..clear()
      ..addAll(stored);

    if (_conversations.isNotEmpty) {
      _activeConversation = _conversations.first;
    } else {
      _activeConversation = _makeConversation();
      _conversations.add(_activeConversation!);
    }

    _isLoading = false;
    notifyListeners();
  }

  ChatConversationModel _makeConversation() {
    final now = DateTime.now();
    return ChatConversationModel(
      id: '${now.microsecondsSinceEpoch}-${Random().nextInt(999999)}',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> newConversation() async {
    if (_isStreaming) {
      await stopStreaming();
    }

    final conversation = _makeConversation();
    _conversations.insert(0, conversation);
    _activeConversation = conversation;

    await _save();
    notifyListeners();
  }

  Future<void> selectConversation(String id) async {
    if (_isStreaming) {
      await stopStreaming();
    }

    final index = _conversations.indexWhere(
      (item) => item.id == id,
    );
    if (index < 0) return;

    _activeConversation = _conversations[index];
    _touchActive();
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    if (_activeConversation?.id == id && _isStreaming) {
      await stopStreaming();
    }

    _conversations.removeWhere((item) => item.id == id);

    if (_conversations.isEmpty) {
      final conversation = _makeConversation();
      _conversations.add(conversation);
      _activeConversation = conversation;
    } else if (_activeConversation?.id == id) {
      _activeConversation = _conversations.first;
    }

    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    if (_isStreaming) {
      await stopStreaming();
    }

    _conversations.clear();
    final conversation = _makeConversation();
    _conversations.add(conversation);
    _activeConversation = conversation;

    await _save();
    notifyListeners();
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    final conversation = _activeConversation;

    if (text.isEmpty ||
        conversation == null ||
        _isStreaming) {
      return;
    }

    final now = DateTime.now();

    final userMessage = ChatMessageModel(
      id: '${now.microsecondsSinceEpoch}-user',
      text: text,
      type: ChatMessageType.user,
      createdAt: now,
    );

    final botMessage = ChatMessageModel(
      id: '${now.microsecondsSinceEpoch}-bot',
      text: '',
      type: ChatMessageType.bot,
      createdAt: now,
    );

    conversation.messages
      ..add(userMessage)
      ..add(botMessage);

    _touchActive();
    _isStreaming = true;
    _streamCancelled = false;

    await _save();
    notifyListeners();

    final context = _buildContext(
      conversation.messages,
      excludeLastBotPlaceholder: true,
    );

    var latestText = '';
    var completionSuccess = false;

    try {
      await _apiManager.streamResponse(
        message: text,
        messages: context,
        maxTokens: 1200,
        onUpdate: (streamedText) {
          if (_streamCancelled) return;

          latestText = streamedText;
          final active = _activeConversation;
          if (active == null || active.id != conversation.id) {
            return;
          }

          final index = active.messages.indexWhere(
            (item) => item.id == botMessage.id,
          );
          if (index < 0) return;

          active.messages[index] = active.messages[index].copyWith(
            text: streamedText,
          );
          active.updatedAt = DateTime.now();
          notifyListeners();
        },
        onCompletion: (success) {
          completionSuccess = success;
        },
      );
    } catch (error) {
      debugPrint('[ChatViewModel] sendMessage failed: $error');
    } finally {
      if (!_streamCancelled) {
        final active = _activeConversation;
        if (active != null && active.id == conversation.id) {
          final index = active.messages.indexWhere(
            (item) => item.id == botMessage.id,
          );

          if (index >= 0) {
            final currentText = active.messages[index].text.trim();

            if (currentText.isEmpty) {
              active.messages[index] =
                  active.messages[index].copyWith(
                text: completionSuccess
                    ? 'I could not generate a response.'
                    : 'Server unavailable. Please try again later.',
              );
            }
          }

          _touchActive();
        }
      }

      _isStreaming = false;
      await _save();

      if (!_streamCancelled &&
          latestText.trim().isNotEmpty &&
          conversation.title?.trim().isEmpty != false) {
        await _generateConversationTitle(conversation);
      }

      notifyListeners();
    }
  }

  List<TogetherAIMessage> _buildContext(
    List<ChatMessageModel> allMessages, {
    required bool excludeLastBotPlaceholder,
  }) {
    final usable = List<ChatMessageModel>.from(allMessages);

    if (excludeLastBotPlaceholder &&
        usable.isNotEmpty &&
        usable.last.type == ChatMessageType.bot &&
        usable.last.text.trim().isEmpty) {
      usable.removeLast();
    }

    final start = usable.length > _maxContextMessages
        ? usable.length - _maxContextMessages
        : 0;

    final recent = usable.sublist(start);

    return <TogetherAIMessage>[
      TogetherAIMessage.system(
        'You are the AI writing assistant inside Novel AI. '
        'Be helpful, clear, creative, and concise unless the user asks '
        'for a detailed answer. Continue the conversation naturally.',
      ),
      ...recent.map((message) {
        switch (message.type) {
          case ChatMessageType.user:
            return TogetherAIMessage.user(message.text);
          case ChatMessageType.bot:
            return TogetherAIMessage.assistant(message.text);
          case ChatMessageType.system:
            return TogetherAIMessage.system(message.text);
        }
      }),
    ];
  }

  Future<void> _generateConversationTitle(
    ChatConversationModel conversation,
  ) async {
    if (conversation.messages.isEmpty) return;

    final combined = conversation.messages
        .where(
          (message) =>
              message.type != ChatMessageType.system &&
              message.text.trim().isNotEmpty,
        )
        .take(4)
        .map((message) => message.text.trim())
        .join('\n');

    if (combined.isEmpty) return;

    try {
      final title = await _apiManager.generateTitle(
        conversation: combined,
      );

      final clean = title
          .replaceAll('"', '')
          .replaceAll('\n', ' ')
          .trim();

      if (clean.isNotEmpty) {
        conversation.title = clean;
        conversation.updatedAt = DateTime.now();
        _sortConversations();
        await _save();
      }
    } catch (error) {
      debugPrint('[ChatViewModel] title generation failed: $error');
    }
  }

  Future<void> stopStreaming() async {
    if (!_isStreaming) return;

    _streamCancelled = true;

    try {
      await _apiManager.stopStreaming();
    } catch (_) {}

    final conversation = _activeConversation;
    if (conversation != null &&
        conversation.messages.isNotEmpty &&
        conversation.messages.last.type == ChatMessageType.bot &&
        conversation.messages.last.text.trim().isEmpty) {
      conversation.messages.removeLast();
    }

    _isStreaming = false;
    _touchActive();
    await _save();
    notifyListeners();
  }

  Future<void> retryLastResponse() async {
    if (_isStreaming) return;

    final conversation = _activeConversation;
    if (conversation == null || conversation.messages.isEmpty) {
      return;
    }

    var lastUserIndex = -1;

    for (var index = conversation.messages.length - 1;
        index >= 0;
        index--) {
      if (conversation.messages[index].type ==
          ChatMessageType.user) {
        lastUserIndex = index;
        break;
      }
    }

    if (lastUserIndex < 0) return;

    final message = conversation.messages[lastUserIndex].text;

    if (lastUserIndex < conversation.messages.length - 1) {
      conversation.messages.removeRange(
        lastUserIndex,
        conversation.messages.length,
      );
    } else {
      conversation.messages.removeAt(lastUserIndex);
    }

    await _save();
    notifyListeners();

    await sendMessage(message);
  }

  void _touchActive() {
    final active = _activeConversation;
    if (active == null) return;

    active.updatedAt = DateTime.now();
    _sortConversations();
  }

  void _sortConversations() {
    _conversations.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );
  }

  Future<void> _save() async {
    _sortConversations();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      ChatConversationModel.encodeList(_conversations),
    );
  }
}
