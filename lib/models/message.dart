import 'dart:convert';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageBase64;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageBase64,
    this.status = MessageStatus.sent,
  });

  // Serialization for local storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'imageBase64': imageBase64,
    'status': status.name,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    imageBase64: json['imageBase64'],
    status: MessageStatus.values.firstWhere(
          (e) => e.name == json['status'],
      orElse: () => MessageStatus.sent,
    ),
  );

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? imageBase64,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageBase64: imageBase64 ?? this.imageBase64,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus { sending, sent, error }
