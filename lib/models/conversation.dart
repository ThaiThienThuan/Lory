import 'user.dart';
import 'message.dart';

class Conversation {
  final String id;
  final User user;
  final Message lastMessage;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      lastMessage: Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'lastMessage': lastMessage.toJson(),
      'unreadCount': unreadCount,
    };
  }

  Conversation copyWith({
    String? id,
    User? user,
    Message? lastMessage,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
