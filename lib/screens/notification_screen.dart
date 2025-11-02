import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../utils/time_utils.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({required this.userId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Mark all as read khi mở
    _notificationService.markAllAsRead(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.getNotifications(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có thông báo nào',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationItem(notif, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notif, bool isDark) {
    final IconData icon = _getNotificationIcon(notif.type);
    final Color iconColor = _getNotificationColor(notif.type);

    return Material(
      color: notif.isRead
          ? Colors.transparent
          : Color(0xFF06b6d4).withOpacity(0.1),
      child: InkWell(
        onTap: () {
          // Mark as read
          _notificationService.markAsRead(notif.id);
          // Navigate to post
          // Navigator.push(...) → Post detail screen
          print('Navigate to post: ${notif.postId}');
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // ✅ User Avatar
              CachedNetworkImage(
                imageUrl: notif.fromUserAvatar,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 24,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircleAvatar(
                  radius: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person),
                ),
              ),
              SizedBox(width: 12),

              // ✅ Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight:
                            notif.isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      TimeUtils.formatTime(notif.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Notification Icon
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  if (!notif.isRead)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF06b6d4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              // ✅ Delete Button
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Xóa'),
                    onTap: () {
                      _notificationService.deleteNotification(notif.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'reply':
        return Icons.reply;
      case 'mention':
        return Icons.tag;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return Color(0xFFec4899);
      case 'comment':
        return Color(0xFF06b6d4);
      case 'reply':
        return Color(0xFFf97316);
      case 'mention':
        return Color(0xFF10b981);
      default:
        return Colors.grey;
    }
  }
}
