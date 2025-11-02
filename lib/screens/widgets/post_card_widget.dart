import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../models/post.dart';
import '../../models/user.dart';
import '../../services/firestore_service.dart';
import '../../utils/time_utils.dart';

class PostCardWidget extends StatefulWidget {
  final Post post;
  final bool isDark;
  final Function(Post) onLike;
  final Function(Post) onComment;
  final Function(Post) onMoreOptions;
  final Function(User) onUserTap;
  final Function(BuildContext, List<String>, int) onImageTap;

  const PostCardWidget({
    required this.post,
    required this.isDark,
    required this.onLike,
    required this.onComment,
    required this.onMoreOptions,
    required this.onUserTap,
    required this.onImageTap,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  @override
  Widget build(BuildContext context) {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            SizedBox(height: 12),
            _buildContent(),
            if (widget.post.images.isNotEmpty) ...[
              SizedBox(height: 12),
              _buildImages(),
            ],
            if (widget.post.tags.isNotEmpty) ...[
              SizedBox(height: 12),
              _buildTags(),
            ],
            SizedBox(height: 16),
            _buildActions(currentUser, firestoreService),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => widget.onUserTap(widget.post.user),
          child: CachedNetworkImage(
            imageUrl: widget.post.user.avatar,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 20,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                TimeUtils.formatTime(widget.post.createdAt),
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => widget.onMoreOptions(widget.post),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post.content,
      style: TextStyle(
        fontSize: 16,
        height: 1.4,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildImages() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.post.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onImageTap(
              context,
              widget.post.images,
              index,
            ),
            child: Container(
              width: 200,
              margin: EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.post.images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Lỗi tải ảnh',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.post.tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFec4899).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFec4899),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(
    auth.User? currentUser,
    FirestoreService firestoreService,
  ) {
    return StreamBuilder<int>(
      stream: firestoreService.getPostLikesCountStream(widget.post.id),
      builder: (context, likesSnapshot) {
        final likesCount = likesSnapshot.data ?? 0;

        return StreamBuilder<bool>(
          stream: currentUser != null
              ? firestoreService.hasUserLikedPostStream(
                  widget.post.id,
                  currentUser.uid,
                )
              : Stream.value(false),
          builder: (context, likeSnapshot) {
            final isLiked = likeSnapshot.data ?? false;

            return Row(
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: likesCount.toString(),
                  color: isLiked
                      ? Color(0xFFec4899)
                      : (widget.isDark ? Colors.white54 : Colors.black54),
                  onTap: () => widget.onLike(widget.post),
                ),
                SizedBox(width: 24),
                StreamBuilder<int>(
                  stream: firestoreService.getCommentCountStream(
                    widget.post.id,
                  ),
                  builder: (context, commentsSnapshot) {
                    final commentsCount = commentsSnapshot.data ?? 0;
                    return _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: commentsCount.toString(),
                      color:
                          widget.isDark ? Colors.white54 : Colors.black54,
                      onTap: () => widget.onComment(widget.post),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
