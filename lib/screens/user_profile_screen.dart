import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../utils/time_utils.dart';
import '../screens/messaging_screen.dart'; // Add import for ChatScreen

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  late TabController _tabController;
  bool _isFollowing = false;
  int _followersCount = 0; // ✅ NEW: Variable to track followers count

  // ✅ NEW: ValueNotifier để trigger refresh
  final ValueNotifier<int> _followersRefreshNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkFollowStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _followersRefreshNotifier.dispose();
    super.dispose();
  }

  Future<void> _checkFollowStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid == widget.user.id) {
      return;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .doc(widget.user.id)
          .get();

      setState(() {
        _isFollowing = doc.exists;
      });

      // ✅ NEW: Trigger refresh
      _followersRefreshNotifier.value++;
      print(
          '🔄 Followers refreshed - value: ${_followersRefreshNotifier.value}');
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }


  Future<void> _toggleFollow() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid == widget.user.id) {
      return;
    }

    try {
      final followingRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('following')
          .doc(widget.user.id);

      if (_isFollowing) {
        await followingRef.delete();
        // Hiển thị thông báo hủy theo dõi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã hủy theo dõi'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await followingRef.set({
          'followedUserId': widget.user.id,
          'followedAt': FieldValue.serverTimestamp(),
        });
        // Hiển thị thông báo theo dõi thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã theo dõi'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isFollowing = !_isFollowing;
      });

      // Trigger refresh stream
      _followersRefreshNotifier.value++;
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _auth.currentUser;
    final isOwnProfile = currentUser?.uid == widget.user.id;
    final currentUserId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f172a) : Colors.white,
      body: CustomScrollView(
        slivers: [
          // ✅ App bar với cover + avatar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1e293b) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan.shade700, Colors.pink.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // ✅ Avatar với CachedNetworkImage
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isDark ? const Color(0xFF0f172a) : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.user.avatar,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 40,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          radius: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showProfileOptions(),
              ),
            ],
          ),

          // ✅ User info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bio
                  Text(
                    widget.user.bio,
                    style: TextStyle(
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Stats
                  Row(
                    children: [
                      // Posts count
                      FutureBuilder<QuerySnapshot>(
                        future: _firestore
                            .collection('posts')
                            .where('user.id', isEqualTo: widget.user.id)
                            .get(),
                        builder: (context, snapshot) {
                          final postsCount = snapshot.data?.docs.length ?? 0;
                          return _buildStat(
                              'Bài đăng', postsCount.toString(), isDark);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ✅ Action buttons
                  Row(
                    children: [
                      if (!isOwnProfile) ...[

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing
                                  ? (isDark
                                      ? const Color(0xFF1e293b)
                                      : Colors.grey.shade300)
                                  : const Color(0xFF06b6d4),
                              foregroundColor: _isFollowing
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                                _isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  user: widget.user,
                                  currentUserId: currentUserId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1e293b)
                                : Colors.grey.shade200,
                            foregroundColor:
                                isDark ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Icon(Icons.message),
                        ),
                      ] else
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Edit profile
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Chỉnh sửa hồ sơ'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ✅ Favorite genres
                  if (widget.user.favoriteGenres.isNotEmpty) ...[

                    Text(
                      'Thể loại yêu thích',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.user.favoriteGenres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor:
                              const Color(0xFF06b6d4).withOpacity(0.2),
                          labelStyle: const TextStyle(color: Color(0xFF06b6d4)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ✅ TabBar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF06b6d4),
                    labelColor: const Color(0xFF06b6d4),
                    unselectedLabelColor:
                        isDark ? Colors.white60 : Colors.black54,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_3x3), text: 'Bài viết'),
                      Tab(icon: Icon(Icons.chat_bubble), text: 'Bình luận'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ✅ Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsTab(isDark),
                _buildCommentsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ✅ Posts Tab
  Widget _buildPostsTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('user.id', isEqualTo: widget.user.id)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Không có bài viết nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!.docs
            .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, index) => _buildPostCard(posts[index], isDark),
        );
      },
    );
  }

  // ✅ Comments Tab
  Widget _buildCommentsTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collectionGroup('comments')
          .where('userId', isEqualTo: widget.user.id)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Không có bình luận nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final comments = snapshot.data!.docs
            .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: comments.length,
          itemBuilder: (context, index) =>
              _buildCommentCard(comments[index], isDark),
        );
      },
    );
  }

  // ✅ Post card - Updated to show real-time likes and comments from Firestore
  Widget _buildPostCard(Post post, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: post.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              StreamBuilder<int>(
                stream: _firestore
                    .collection('post_likes')
                    .where('postId', isEqualTo: post.id)
                    .snapshots()
                    .map((snapshot) => snapshot.docs.length),
                builder: (context, snapshot) {
                  final likesCount = snapshot.data ?? 0;
                  return Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        likesCount.toString(),
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 16),
              StreamBuilder<int>(
                stream: _firestore
                    .collection('posts')
                    .doc(post.id)
                    .collection('comments')
                    .snapshots()
                    .map((snapshot) {
                      int totalCount = 0;
                      for (var doc in snapshot.docs) {
                        totalCount++; // Count main comment
                        // Count replies in the replies array
                        final replies = doc['replies'] as List<dynamic>? ?? [];
                        totalCount += replies.length;
                      }
                      return totalCount;
                    }),
                builder: (context, snapshot) {
                  final commentsCount = snapshot.data ?? 0;
                  return Row(
                    children: [
                      Icon(Icons.comment, size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        commentsCount.toString(),
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Comment card
  Widget _buildCommentCard(Comment comment, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.content,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TimeUtils.formatTime(comment.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Chặn người dùng'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Báo cáo'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
