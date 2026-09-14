import 'dart:convert';

enum ChatMessageType {
  user,
  bot,
  system,
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String text;
  final ChatMessageType type;
  final DateTime createdAt;

  bool get isUser => type == ChatMessageType.user;
  bool get isBot => type == ChatMessageType.bot;

  ChatMessageModel copyWith({
    String? id,
    String? text,
    ChatMessageType? type,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final typeName = (json['type'] ?? 'user').toString();

    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      type: ChatMessageType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => ChatMessageType.user,
      ),
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}

class ChatConversationModel {
  ChatConversationModel({
    required this.id,
    this.title,
    List<ChatMessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? <ChatMessageModel>[],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String? title;
  final List<ChatMessageModel> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  String get displayTitle {
    final value = title?.trim() ?? '';
    return value.isEmpty ? 'New Chat' : value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final decodedMessages = <ChatMessageModel>[];

    if (rawMessages is List) {
      for (final item in rawMessages) {
        if (item is Map) {
          decodedMessages.add(
            ChatMessageModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return ChatConversationModel(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString(),
      messages: decodedMessages,
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            (json['updatedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  static String encodeList(List<ChatConversationModel> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }

  static List<ChatConversationModel> decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return <ChatConversationModel>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <ChatConversationModel>[];

      return decoded
          .whereType<Map>()
          .map(
            (item) => ChatConversationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.id.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return <ChatConversationModel>[];
    }
  }
}
