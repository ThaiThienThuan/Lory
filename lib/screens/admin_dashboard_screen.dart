import 'package:flutter/material.dart';
import '../data/mock_data.dart';

// Màn hình dashboard cho admin
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedTab = 0; // 0: Tổng quan, 1: Tài khoản, 2: Bài đăng, 3: Gallery, 4: Kho truyện

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyan),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar điều hướng
          Container(
            width: 250,
            color: const Color(0xFF1e293b),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _buildNavItem(Icons.dashboard, 'Tổng Quan', 0),
                _buildNavItem(Icons.people, 'Quản Lý Tài Khoản', 1),
                _buildNavItem(Icons.post_add, 'Quản Lý Bài Đăng', 2),
                _buildNavItem(Icons.photo_library, 'Quản Lý Gallery', 3),
                _buildNavItem(Icons.book, 'Quản Lý Kho Truyện', 4),
                const Divider(color: Colors.white24, height: 40),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white70),
                  title: const Text('Cài Đặt', style: TextStyle(color: Colors.white70)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('Thoát Admin', style: TextStyle(color: Colors.red)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Nội dung chính
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final isSelected = selectedTab == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.cyan : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.cyan : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.cyan.withOpacity(0.1),
      onTap: () => setState(() => selectedTab = index),
    );
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildAccountManagement();
      case 2:
        return _buildPostManagement();
      case 3:
        return _buildGalleryManagement();
      case 4:
        return _buildMangaManagement();
      default:
        return _buildOverview();
    }
  }

  // Tab Tổng quan
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng Quan Hệ Thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Thống kê tổng quan
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Người Dùng', mockUsers.length.toString(), Icons.people, Colors.cyan),
              _buildStatCard('Truyện', mockMangaList.length.toString(), Icons.book, Colors.pink),
              _buildStatCard('Bài Đăng', mockPosts.length.toString(), Icons.post_add, Colors.orange),
              _buildStatCard('Gallery', mockGalleryItems.length.toString(), Icons.photo, Colors.green),
            ],
          ),

          const SizedBox(height: 32),

          // Hoạt động gần đây
          const Text(
            'Hoạt Động Gần Đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1e293b),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.cyan.withOpacity(0.2),
                    child: const Icon(Icons.info, color: Colors.cyan, size: 20),
                  ),
                  title: Text(
                    'Người dùng mới đăng ký: User ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${index + 1} giờ trước',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Tab Quản lý tài khoản
  Widget _buildAccountManagement() {
    return Column(
      children: [
        // Header với tìm kiếm
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFF1e293b),
          child: Row(
            children: [
              const Text(
                'Quản Lý Tài Khoản',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm người dùng...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                    filled: true,
                    fillColor: const Color(0xFF0f172a),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Danh sách người dùng
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: mockUsers.length,
            itemBuilder: (context, index) {
              final user = mockUsers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user.avatar),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.bio,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.followers} người theo dõi',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF0f172a),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditUserDialog(context, user);
                        } else if (value == 'ban') {
                          _showBanUserDialog(context, user);
                        } else if (value == 'delete') {
                          _showDeleteUserDialog(context, user);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.cyan),
                              SizedBox(width: 12),
                              Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'ban',
                          child: Row(
                            children: [
                              Icon(Icons.block, color: Colors.orange),
                              SizedBox(width: 12),
                              Text('Cấm tài khoản', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Xóa tài khoản', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab Quản lý bài đăng
  Widget _buildPostManagement() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFF1e293b),
          child: const Row(
            children: [
              Text(
                'Quản Lý Bài Đăng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: mockPosts.length,
            itemBuilder: (context, index) {
              final post = mockPosts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                          radius: 20,
                          backgroundImage: NetworkImage(post.user.avatar),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatTime(post.createdAt),
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeletePostDialog(context, post),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post.content,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
            },
          ),
        ),
      ],
    );
  }

  // Tab Quản lý Gallery
  Widget _buildGalleryManagement() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFF1e293b),
          child: const Row(
            children: [
              Text(
                'Quản Lý Gallery',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: mockGalleryItems.length,
            itemBuilder: (context, index) {
              final item = mockGalleryItems[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.artistName,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.favorite, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text('${item.likes}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showDeleteGalleryDialog(context, item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab Quản lý kho truyện
  Widget _buildMangaManagement() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFF1e293b),
          child: Row(
            children: [
              const Text(
                'Quản Lý Kho Truyện',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // Thêm truyện mới
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm Truyện'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: mockMangaList.length,
            itemBuilder: (context, index) {
              final manga = mockMangaList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        manga.cover,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manga.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            manga.author,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${manga.rating}',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.visibility, size: 16, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                '${manga.views}',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF0f172a),
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Chỉnh sửa truyện
                        } else if (value == 'delete') {
                          _showDeleteMangaDialog(context, manga);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.cyan),
                              SizedBox(width: 12),
                              Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Xóa truyện', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Các dialog xác nhận
  void _showEditUserDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Chỉnh Sửa Người Dùng', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tính năng chỉnh sửa người dùng sẽ được triển khai.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }

  void _showBanUserDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Cấm Tài Khoản', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn cấm tài khoản "${user.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã cấm tài khoản "${user.name}"'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cấm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Xóa Tài Khoản', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản "${user.name}"? Hành động này không thể hoàn tác.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa tài khoản "${user.name}"'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeletePostDialog(BuildContext context, post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Xóa Bài Đăng', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc chắn muốn xóa bài đăng này?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa bài đăng'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGalleryDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Xóa Gallery', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${item.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa gallery'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMangaDialog(BuildContext context, manga) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text('Xóa Truyện', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${manga.title}"? Hành động này không thể hoàn tác.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa truyện "${manga.title}"'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
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
