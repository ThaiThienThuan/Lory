import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late String _currentUserId;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userId = await _authService.getUserId();
    if (userId != null) {
      setState(() {
        _currentUserId = userId;
        _isLoaded = true;
        developer.log(
          '[v0] User initialized: $_currentUserId',
          name: 'MessagingScreen',
        );
      });
    } else {
      setState(() {
        _isLoaded = true;
        developer.log(
          '[v0] Failed to get user ID',
          name: 'MessagingScreen',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Tin nhắn', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.cyan),
            onPressed: () {
              // Tạo tin nhắn mới
            },
          ),
        ],
      ),
      body: !_isLoaded
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            )
          : _currentUserId.isEmpty
              ? Center(
                  child: Text(
                    'Vui lòng đăng nhập',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                )
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _firestoreService
                      .getUserConversationsStream(_currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.cyan),
                      );
                    }

                    if (snapshot.hasError) {
                      developer.log(
                        '[v0] Error: ${snapshot.error}',
                        name: 'MessagingScreen',
                      );
                      return Center(
                        child: Text(
                          'Có lỗi xảy ra: ${snapshot.error}',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      );
                    }

                    final conversations = snapshot.data ?? [];

                    if (conversations.isEmpty) {
                      return Center(
                        child: Text(
                          'Chưa có cuộc hội thoại',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final userData = conversation['otherUser']
                            as Map<String, dynamic>?;

                        final user = User(
                          id: userData?['id'] ?? '',
                          name: userData?['name'] ?? 'Unknown',
                          avatar: userData?['avatar'] ??
                              'https://via.placeholder.com/150?text=No+Avatar',
                          bio: userData?['bio'] ?? '',
                          followers: (userData?['followers'] as num?)?.toInt() ?? 0,
                          following: (userData?['following'] as num?)?.toInt() ?? 0,
                          favoriteGenres: (userData?['favoriteGenres']
                                  as List<dynamic>?)
                              ?.map((e) => e as String)
                              .toList() ??
                              [],
                        );

                        developer.log(
                          '[v0] Conversation user: ${user.name} (${user.id})',
                          name: 'MessagingScreen',
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.avatar),
                            radius: 28,
                            onBackgroundImageError: (exception, stackTrace) {
                              developer.log(
                                '[v0] Avatar load error: $exception',
                                name: 'MessagingScreen',
                              );
                            },
                            child: user.avatar
                                    .startsWith('https://via.placeholder')
                                ? Icon(Icons.person,
                                    color: Colors.grey.shade600)
                                : null,
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            conversation['lastMessage'] ??
                                'Bắt đầu cuộc hội thoại',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          trailing: Text(
                            _formatTime(conversation['lastMessageTime']),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  user: user,
                                  currentUserId: _currentUserId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Vừa xong';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Vừa xong';
    }

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Vừa xong';
    }
  }
}

class ChatScreen extends StatefulWidget {
  final User user;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.user,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  late Future<String> _conversationIdFuture;

  @override
  void initState() {
    super.initState();
    _conversationIdFuture = _firestoreService.getOrCreateConversation(
      widget.currentUserId,
      widget.user.id,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.user.avatar),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Đang hoạt động',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.cyan),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.cyan),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _conversationIdFuture,
        builder: (context, conversationSnapshot) {
          if (conversationSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            );
          }

          if (conversationSnapshot.hasError) {
            developer.log(
              '[v0] Lỗi tạo conversation: ${conversationSnapshot.error}',
              name: 'ChatScreen',
            );
            return Center(
              child: Text(
                'Có lỗi xảy ra',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }

          final conversationId = conversationSnapshot.data ?? '';

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _firestoreService.getMessagesStream(
                    conversationId,
                    currentUserId: widget.currentUserId,
                  ),
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.cyan),
                      );
                    }

                    if (messageSnapshot.hasError) {
                      developer.log(
                        '[v0] Error loading messages: ${messageSnapshot.error}',
                        name: 'ChatScreen',
                      );
                      return Center(
                        child: Text(
                          'Lỗi tải tin nhắn: ${messageSnapshot.error}',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      );
                    }

                    final messages = messageSnapshot.data ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Bắt đầu cuộc hội thoại',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      developer.log(
                        '[v0] Loaded ${messages.length} messages',
                        name: 'ChatScreen',
                      );
                    });

                    return ListView.builder(
                      reverse: false,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1e293b),
                  border: Border(
                    top: BorderSide(color: Color(0xFF334155)),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.cyan),
                        onPressed: () {
                          // Thêm file, ảnh, sticker
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.cyan),
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            final messageContent = _messageController.text;

                            _messageController.clear();

                            final success = await _firestoreService
                                .sendMessage(
                              conversationId,
                              widget.currentUserId,
                              messageContent,
                            )
                            .catchError((e) {
                              developer.log(
                                '[v0] Lỗi gửi tin nhắn: $e',
                                name: 'ChatScreen',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi gửi tin nhắn: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return false;
                            });

                            if (success) {
                              developer.log(
                                '[v0] Tin nhắn đã được lưu',
                                name: 'ChatScreen',
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.cyan : const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                color: message.isMe
                    ? Colors.black54
                    : Colors.grey.shade400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
