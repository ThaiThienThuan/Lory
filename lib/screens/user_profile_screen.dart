import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../data/mock_data.dart';

// Màn hình tường cá nhân của người dùng khác
class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isFollowing = false;
  int selectedTab = 0; // 0: Bài đăng, 1: Truyện, 2: Giới thiệu

  @override
  Widget build(BuildContext context) {
    // Lấy bài đăng của user này
    final userPosts = mockPosts.where((post) => post.user.id == widget.user.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: CustomScrollView(
        slivers: [
          // App bar với avatar và cover
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1e293b),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan.shade700, Colors.pink.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Avatar
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0f172a), width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(widget.user.avatar),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Hiển thị menu tùy chọn
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1e293b),
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.block, color: Colors.red),
                            title: const Text('Chặn người dùng', style: TextStyle(color: Colors.white)),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.report, color: Colors.orange),
                            title: const Text('Báo cáo', style: TextStyle(color: Colors.white)),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Thông tin người dùng
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và bio
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user.bio,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Thống kê
                  Row(
                    children: [
                      _buildStat('Bài đăng', userPosts.length.toString()),
                      const SizedBox(width: 24),
                      _buildStat('Người theo dõi', widget.user.followers.toString()),
                      const SizedBox(width: 24),
                      _buildStat('Đang theo dõi', widget.user.following.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isFollowing = !isFollowing;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? const Color(0xFF1e293b) : Colors.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat', arguments: widget.user);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e293b),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Icon(Icons.message),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabButton('Bài đăng', 0),
                        ),
                        Expanded(
                          child: _buildTabButton('Truyện', 1),
                        ),
                        Expanded(
                          child: _buildTabButton('Giới thiệu', 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nội dung theo tab
          if (selectedTab == 0)
            // Tab bài đăng
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = userPosts[index];
                  return _buildPostCard(post);
                },
                childCount: userPosts.length,
              ),
            )
          else if (selectedTab == 1)
            // Tab truyện yêu thích
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final manga = mockMangaList[index % mockMangaList.length];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(manga.cover, fit: BoxFit.cover),
                    );
                  },
                  childCount: 6,
                ),
              ),
            )
          else
            // Tab giới thiệu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thể loại yêu thích',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
                          backgroundColor: Colors.cyan.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.cyan),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('${post.likes}', style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 16),
              Icon(Icons.comment, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('${post.comments}', style: TextStyle(color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}
