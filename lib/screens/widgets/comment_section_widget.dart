import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../models/comment.dart';
import '../../models/user.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../utils/time_utils.dart';

class CommentSectionWidget extends StatefulWidget {
  final String postId;
  final Function(User) onUserTap;

  const CommentSectionWidget({
    required this.postId,
    required this.onUserTap,
  });

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  final currentUser = auth.FirebaseAuth.instance.currentUser;
  final firestoreService = FirestoreService();
  final authService = AuthService();
  Map<String, int> _commentReplyCounts = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: firestoreService.getPostCommentsStream(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyCommentsState();
              }

              final comments = snapshot.data!;
              
              _commentReplyCounts.clear();
              for (final comment in comments) {
                _countReplies(comment);
              }
              
              return ListView.separated(
                padding: EdgeInsets.all(12),
                itemCount: comments.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildCommentItem(comments[index]);
                },
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Divider(height: 1),
        SizedBox(height: 16),
        if (currentUser != null)
          _buildCommentInputField()
        else
          Center(
            child: Text(
              'Vui lòng đăng nhập để bình luận',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  void _initializeNestedReplyCounts(List<Comment> replies) {
    for (final reply in replies) {
      _commentReplyCounts[reply.id] = reply.replies.length;
      if (reply.replies.isNotEmpty) {
        _initializeNestedReplyCounts(reply.replies);
      }
    }
  }

  void _countReplies(Comment comment) {
    _commentReplyCounts[comment.id] = comment.replies.length;
    for (final reply in comment.replies) {
      _countReplies(reply);
    }
  }

  Widget _buildEmptyCommentsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 12),
          Text(
            'Chưa có bình luận nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy là người đầu tiên bình luận!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, {int level = 0}) {
    final replyCount = _commentReplyCounts[comment.id] ?? comment.replies.length;
    final hasReplies = replyCount > 0;
    final maxLevel = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: level > 0 ? 32 : 0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: level > 0
                ? Border.all(
                    color: Color(0xFF06b6d4).withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => widget.onUserTap(
                      User(
                        id: comment.userId,
                        name: comment.userName,
                        avatar: comment.userAvatar,
                        bio: '',
                        followers: 0,
                        following: 0,
                        favoriteGenres: [],
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: comment.userAvatar,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 18,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) =>
                          CircleAvatar(radius: 18),
                      errorWidget: (context, url, error) =>
                          CircleAvatar(
                            radius: 18,
                            child: Icon(Icons.person, size: 16),
                          ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          TimeUtils.formatTime(comment.createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (currentUser?.uid == comment.userId)
                    _buildDeleteButton(comment),
                ],
              ),
              SizedBox(height: 10),
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  if (level < maxLevel)
                    TextButton.icon(
                      onPressed: () => _showReplyDialog(comment),
                      icon: Icon(Icons.reply_rounded, size: 14),
                      label: Text('Trả lời'),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF06b6d4),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size(0, 32),
                      ),
                    ),
                  if (hasReplies)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        '$replyCount trả lời',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF06b6d4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (hasReplies && level < maxLevel)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              children: comment.replies
                  .map((reply) => _buildCommentItem(reply, level: level + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDeleteButton(Comment comment) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _deleteComment(comment),
        ),
      ],
    );
  }

  void _showReplyDialog(Comment parentComment) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.reply_rounded, color: Color(0xFF06b6d4)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Trả lời ${parentComment.userName}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show original comment
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF06b6d4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF06b6d4).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parentComment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF06b6d4),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      parentComment.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Reply input
              TextField(
                controller: replyController,
                maxLines: 4,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập câu trả lời của bạn...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF06b6d4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final replyText = replyController.text.trim();

                if (replyText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Vui lòng nhập nội dung'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Check login
                final userId = await authService.getUserId();
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Bạn cần đăng nhập'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  // Create reply comment
                  final newReply = Comment(
                    id: '',
                    userId: currentUser!.uid,
                    userName: currentUser!.displayName ?? 'Anonymous',
                    userAvatar: currentUser!.photoURL ?? '',
                    content: replyText,
                    createdAt: DateTime.now(),
                    replies: [],
                  );

                  // Add reply using parentId
                  await _addReplyToParent(parentComment.id, newReply);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trả lời đã được đăng!'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Color(0xFF06b6d4),
                    ),
                  );
                } catch (e) {
                  print('Error posting reply: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                }
              },
              child: Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addReplyToParent(
    String parentCommentId,
    Comment newReply,
  ) async {
    try {
      final currentComments =
          await firestoreService.getPostCommentsStream(widget.postId).first;

      final replyWithId = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: newReply.userId,
        userName: newReply.userName,
        userAvatar: newReply.userAvatar,
        content: newReply.content,
        createdAt: newReply.createdAt,
        replies: [],
      );

      final updatedComments = _updateCommentsWithReply(
        currentComments,
        parentCommentId,
        replyWithId,
      );

      setState(() {
        _commentReplyCounts[parentCommentId] = 
            (_commentReplyCounts[parentCommentId] ?? 0) + 1;
      });

      // Update each modified comment in Firestore
      for (final comment in updatedComments) {
        await firestoreService.updateComment(widget.postId, comment);
      }
    } catch (e) {
      print('Error adding reply: $e');
      rethrow;
    }
  }

  List<Comment> _updateCommentsWithReply(
    List<Comment> comments,
    String parentId,
    Comment newReply,
  ) {
    return comments.map((comment) {
      if (comment.id == parentId) {
        return Comment(
          id: comment.id,
          userId: comment.userId,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: comment.content,
          createdAt: comment.createdAt,
          replies: [...comment.replies, newReply],
        );
      }

      // Recursively search in nested replies
      if (comment.replies.isNotEmpty) {
        return Comment(
          id: comment.id,
          userId: comment.userId,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: comment.content,
          createdAt: comment.createdAt,
          replies:
              _updateCommentsWithReply(comment.replies, parentId, newReply),
        );
      }

      return comment;
    }).toList();
  }

  Future<void> _deleteComment(Comment comment) async {
    if (comment.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Lỗi: ID bình luận không hợp lệ'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final isReply = await _isCommentAReply(comment.id);
      
      if (isReply) {
        await _deleteReplyFromParent(comment.id);
      } else {
        final success = await firestoreService.deleteCommentFromPost(
          widget.postId,
          comment.id,
        );

        if (!success) {
          throw Exception('Lỗi khi xóa bình luận');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa bình luận'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('[v0] Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _isCommentAReply(String commentId) async {
    try {
      final comments = await firestoreService.getPostCommentsStream(widget.postId).first;
      
      bool isReply = false;
      void checkReplies(List<Comment> comments) {
        for (final comment in comments) {
          for (final reply in comment.replies) {
            if (reply.id == commentId) {
              isReply = true;
              return;
            }
            checkReplies([reply]);
          }
        }
      }
      
      checkReplies(comments);
      return isReply;
    } catch (e) {
      print('[v0] Error checking if reply: $e');
      return false;
    }
  }

  Future<void> _deleteReplyFromParent(String replyId) async {
    try {
      final currentComments =
          await firestoreService.getPostCommentsStream(widget.postId).first;

      void findAndDecrementCount(List<Comment> comments) {
        for (final comment in comments) {
          for (final reply in comment.replies) {
            if (reply.id == replyId) {
              setState(() {
                _commentReplyCounts[comment.id] = 
                    (_commentReplyCounts[comment.id] ?? 1) - 1;
              });
              return;
            }
            findAndDecrementCount([reply]);
          }
        }
      }

      findAndDecrementCount(currentComments);

      final updatedComments = _removeReplyFromComments(
        currentComments,
        replyId,
      );

      // Update each modified comment in Firestore
      for (final comment in updatedComments) {
        await firestoreService.updateComment(widget.postId, comment);
      }
    } catch (e) {
      print('[v0] Error deleting reply: $e');
      rethrow;
    }
  }

  List<Comment> _removeReplyFromComments(
    List<Comment> comments,
    String replyId,
  ) {
    return comments.map((comment) {
      // Filter out the reply with matching ID
      final filteredReplies = comment.replies
          .where((reply) => reply.id != replyId)
          .toList();

      // If replies changed, reconstruct the comment
      if (filteredReplies.length != comment.replies.length) {
        return Comment(
          id: comment.id,
          userId: comment.userId,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: comment.content,
          createdAt: comment.createdAt,
          replies: filteredReplies.isNotEmpty
              ? _removeReplyFromComments(filteredReplies, replyId)
              : [],
        );
      }

      // Recursively search in nested replies
      if (comment.replies.isNotEmpty) {
        return Comment(
          id: comment.id,
          userId: comment.userId,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: comment.content,
          createdAt: comment.createdAt,
          replies: _removeReplyFromComments(comment.replies, replyId),
        );
      }

      return comment;
    }).toList();
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              currentUser?.photoURL ?? 'https://via.placeholder.com/150',
            ),
            backgroundColor: Colors.grey.shade300,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Viết bình luận...',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Color(0xFF06b6d4).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Color(0xFF06b6d4),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              minLines: 1,
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF06b6d4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _submitComment,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();
    
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Vui lòng nhập nội dung'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final newComment = Comment(
        id: '',
        userId: currentUser!.uid,
        userName: currentUser!.displayName ?? 'Anonymous',
        userAvatar: currentUser!.photoURL ?? '',
        content: commentText,
        createdAt: DateTime.now(),
        replies: [],
      );

      final commentId = await firestoreService.addCommentToPost(widget.postId, newComment);
      
      _commentController.clear();
      
      if (commentId != null && commentId.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bình luận đã được đăng!'),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF06b6d4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Lỗi khi đăng bình luận'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[v0] Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
