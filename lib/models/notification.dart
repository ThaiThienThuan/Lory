import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId; // User nhận thông báo
  final String fromUserId; // User gửi thông báo
  final String fromUserName;
  final String fromUserAvatar;
  final String type; // 'like', 'comment', 'reply', 'mention'
  final String postId;
  final String? commentId; // Cho reply
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserAvatar,
    required this.type,
    required this.postId,
    this.commentId,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fromUserId: json['fromUserId'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? '',
      fromUserAvatar: json['fromUserAvatar'] as String? ?? '',
      type: json['type'] as String? ?? 'like',
      postId: json['postId'] as String? ?? '',
      commentId: json['commentId'] as String?,
      message: json['message'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'type': type,
      'postId': postId,
      'commentId': commentId,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else {
      return DateTime.now();
    }
  }
}
