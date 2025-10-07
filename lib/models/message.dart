import 'user.dart';

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
}

// Model cho cuộc hội thoại
class Conversation {
  final String id;
  final User user;
  final Message lastMessage;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.user,
    required this.lastMessage,
    this.unreadCount = 0,
  });
}
