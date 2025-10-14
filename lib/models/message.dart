// Model cho tin nhắn
class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final bool isRead;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isMe: json['isMe'] as bool,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isMe,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
    );
  }
}
