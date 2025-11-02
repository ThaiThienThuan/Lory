import 'package:flutter/material.dart';
import '../models/community.dart';
import '../models/post.dart';
import '../data/mock_data.dart';

// Màn hình chi tiết cộng đồng/nhóm
class CommunityDetailScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  bool isJoined = false;
  int selectedTab = 0; // 0: Bài đăng, 1: Thành viên, 2: Giới thiệu

  @override
  void initState() {
    super.initState();
    isJoined = widget.community.isJoined;
  }

  @override
  Widget build(BuildContext context) {
    // Lấy bài đăng của cộng đồng này
    final communityPosts = mockPosts
        .where((post) => post.community?.id == widget.community.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: CustomScrollView(
        slivers: [
          // App bar với cover
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1e293b),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.community.avatar, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.community.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.community.memberCount} thành viên',
                          style: TextStyle(
                              color: Colors.grey.shade300, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Thông tin và nút hành động
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mô tả
                  Text(
                    widget.community.description,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isJoined = !isJoined;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isJoined
                                    ? 'Đã tham gia nhóm'
                                    : 'Đã rời khỏi nhóm'),
                                backgroundColor: Colors.cyan,
                              ),
                            );
                          },
                          icon: Icon(isJoined ? Icons.check : Icons.add),
                          label: Text(isJoined ? 'Đã tham gia' : 'Tham gia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isJoined
                                ? const Color(0xFF1e293b)
                                : Colors.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Mời bạn bè
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e293b),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Icon(Icons.person_add),
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
                        Expanded(child: _buildTabButton('Bài đăng', 0)),
                        Expanded(child: _buildTabButton('Thành viên', 1)),
                        Expanded(child: _buildTabButton('Giới thiệu', 2)),
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
                  final post = communityPosts[index];
                  return _buildPostCard(post);
                },
                childCount: communityPosts.length,
              ),
            )
          else if (selectedTab == 1)
            // Tab thành viên
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = mockUsers[index % mockUsers.length];
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar)),
                    title: Text(user.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(user.bio,
                        style: TextStyle(color: Colors.grey.shade400)),
                    trailing: const Icon(Icons.more_vert, color: Colors.grey),
                  );
                },
                childCount: 10,
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
                    _buildInfoRow(
                        Icons.public,
                        widget.community.isPrivate
                            ? 'Nhóm riêng tư'
                            : 'Nhóm công khai'),
                    _buildInfoRow(Icons.people,
                        '${widget.community.memberCount} thành viên'),
                    _buildInfoRow(
                        Icons.post_add, '${communityPosts.length} bài đăng'),
                  ],
                ),
              ),
            ),
        ],
      ),
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
          Row(
            children: [
              CircleAvatar(
                  backgroundImage: NetworkImage(post.user.avatar), radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.user.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(
                      '${_formatTime(post.createdAt)}',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(color: Colors.white)),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(post.images.first,
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}
