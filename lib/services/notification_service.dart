import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import '../models/user.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Thêm helper method này
  String _generateNotificationMessage({
    required String type,
    required String fromUserName,
    required String? postContent,
    required String? commentContent,
  }) {
    switch (type) {
      case 'like':
        final preview = (postContent ?? '').length > 30
            ? '${postContent!.substring(0, 30)}...'
            : postContent ?? '';
        return '$fromUserName thích bài viết của bạn: "$preview"';

      case 'comment':
        final preview = (commentContent ?? '').length > 40
            ? '${commentContent!.substring(0, 40)}...'
            : commentContent ?? '';
        return '$fromUserName bình luận: "$preview"';

      case 'reply':
        final preview = (commentContent ?? '').length > 40
            ? '${commentContent!.substring(0, 40)}...'
            : commentContent ?? '';
        return '$fromUserName trả lời bình luận của bạn: "$preview"';

      case 'mention':
        final preview = (postContent ?? '').length > 30
            ? '${postContent!.substring(0, 30)}...'
            : postContent ?? '';
        return '$fromUserName @nhắc đến bạn: "$preview"';

      default:
        return '$fromUserName tương tác với bạn';
    }
  }

  // ✅ Tạo notification khi user like post
  Future<void> createLikeNotification({
    required String postId,
    required String postOwnerId,
    required User fromUser,
    String? postContent, // ← ADD parameter
  }) async {
    try {
      if (postOwnerId == fromUser.id) return;

      // ✅ Generate message dynamically
      final message = _generateNotificationMessage(
        type: 'like',
        fromUserName: fromUser.name,
        postContent: postContent,
        commentContent: null,
      );

      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = AppNotification(
        id: notificationId,
        userId: postOwnerId,
        fromUserId: fromUser.id,
        fromUserName: fromUser.name,
        fromUserAvatar: fromUser.avatar,
        type: 'like',
        postId: postId,
        message: message, // ← Use generated message
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error creating like notification: $e');
    }
  }

  // ✅ Tạo notification khi user comment
  Future<void> createCommentNotification({
    required String postId,
    required String postOwnerId,
    required String commentId,
    required User fromUser,
    required String commentContent,
  }) async {
    try {
      if (postOwnerId == fromUser.id) return;

      // ✅ Generate message with preview
      final message = _generateNotificationMessage(
        type: 'comment',
        fromUserName: fromUser.name,
        postContent: null,
        commentContent: commentContent,
      );

      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = AppNotification(
        id: notificationId,
        userId: postOwnerId,
        fromUserId: fromUser.id,
        fromUserName: fromUser.name,
        fromUserAvatar: fromUser.avatar,
        type: 'comment',
        postId: postId,
        commentId: commentId,
        message: message, // ← Use generated message
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error creating comment notification: $e');
    }
  }

  // ✅ Tạo notification khi user reply comment
  Future<void> createReplyNotification({
    required String postId,
    required String commentOwnerId,
    required String commentId,
    required User fromUser,
    required String replyContent,
  }) async {
    try {
      if (commentOwnerId == fromUser.id) return;

      // ✅ Generate message with preview
      final message = _generateNotificationMessage(
        type: 'reply',
        fromUserName: fromUser.name,
        postContent: null,
        commentContent: replyContent,
      );

      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = AppNotification(
        id: notificationId,
        userId: commentOwnerId,
        fromUserId: fromUser.id,
        fromUserName: fromUser.name,
        fromUserAvatar: fromUser.avatar,
        type: 'reply',
        postId: postId,
        commentId: commentId,
        message: message, // ← Use generated message
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error creating reply notification: $e');
    }
  }

  // ✅ Tạo notification khi user tag (@username)
  Future<void> createMentionNotification({
    required String postId,
    required String mentionedUserId,
    required User fromUser,
  }) async {
    try {
      if (mentionedUserId == fromUser.id) return;

      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = AppNotification(
        id: notificationId,
        userId: mentionedUserId,
        fromUserId: fromUser.id,
        fromUserName: fromUser.name,
        fromUserAvatar: fromUser.avatar,
        type: 'mention',
        postId: postId,
        message: '${fromUser.name} đã tag bạn trong một bài viết',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      print('Error creating mention notification: $e');
    }
  }

  // ✅ Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ✅ Stream unread notifications
  Stream<int> unreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ✅ Get notifications
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();
    });
  }

  // ✅ Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // ✅ Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // ✅ Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
