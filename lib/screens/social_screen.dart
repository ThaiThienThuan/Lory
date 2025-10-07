import 'package:flutter/material.dart';
import '../models/post.dart';
import '../data/mock_data.dart';
import 'user_profile_screen.dart';
import 'messaging_screen.dart';
import 'community_detail_screen.dart';

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  List<Post> posts = MockData.posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1e293b),
        title: Text(
          'Cộng Đồng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.cyan),
            tooltip: 'Tường cá nhân',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: MockData.users[0]),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.message_outlined, color: Colors.cyan),
            tooltip: 'Tin nhắn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagingScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Color(0xFF1e293b),
            onSelected: (value) {
              if (value == 'settings') {
                // Điều hướng đến cài đặt
              } else if (value == 'create_group') {
                _showCreateGroupDialog(context);
              } else if (value == 'my_groups') {
                // Hiển thị danh sách nhóm của tôi
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'create_group',
                child: Row(
                  children: [
                    Icon(Icons.group_add, color: Colors.cyan),
                    SizedBox(width: 12),
                    Text('Tạo nhóm/cộng đồng', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'my_groups',
                child: Row(
                  children: [
                    Icon(Icons.groups, color: Colors.cyan),
                    SizedBox(width: 12),
                    Text('Nhóm của tôi', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.cyan),
                    SizedBox(width: 12),
                    Text('Cài đặt', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            posts = MockData.posts;
          });
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostCard(post);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: Color(0xFF06b6d4),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(user: post.user),
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post.user.avatar),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        if (post.community != null)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommunityDetailScreen(
                                    community: post.community!,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'từ: ',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  post.community!.name,
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            _formatTimeAgo(post.createdAt),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      _showPostOptions(context, post);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            Text(
              post.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.white,
              ),
            ),

            if (post.mangaReference != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF06b6d4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF06b6d4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: Color(0xFF06b6d4),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tham chiếu: ${_getMangaTitle(post.mangaReference!)}',
                      style: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (post.images.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                height: 200,
                child: post.images.length == 1
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.images[0],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 200,
                            margin: EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post.images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],

            SizedBox(height: 16),

            Row(
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: post.likes.toString(),
                  color: post.isLiked ? Color(0xFFec4899) : Colors.white54,
                  onTap: () {
                    setState(() {
                      final index = posts.indexOf(post);
                      posts[index] = Post(
                        id: post.id,
                        user: post.user,
                        content: post.content,
                        images: post.images,
                        createdAt: post.createdAt,
                        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
                        comments: post.comments,
                        shares: post.shares,
                        isLiked: !post.isLiked,
                        mangaReference: post.mangaReference,
                        community: post.community,
                      );
                    });
                  },
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.comments.toString(),
                  color: Colors.white54,
                  onTap: () {
                    _showCommentsBottomSheet(context, post);
                  },
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: post.shares.toString(),
                  color: Colors.white54,
                  onTap: () {
                    _showShareOptions(context, post);
                  },
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.bookmark_border),
                  onPressed: () {},
                  color: Colors.white54,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String _getMangaTitle(String mangaId) {
    final manga = MockData.mangaList.firstWhere(
      (m) => m.id == mangaId,
      orElse: () => MockData.mangaList[0],
    );
    return manga.title;
  }

  void _showCreateGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF1e293b),
              title: Text('Tạo Nhóm/Cộng Đồng', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Tên nhóm',
                        labelStyle: TextStyle(color: Colors.cyan),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Color(0xFF0f172a),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        labelStyle: TextStyle(color: Colors.cyan),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Color(0xFF0f172a),
                      ),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Nhóm riêng tư', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Yêu cầu phê duyệt để tham gia',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: isPrivate,
                      activeColor: Colors.cyan,
                      onChanged: (value) {
                        setState(() {
                          isPrivate = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã tạo nhóm "${nameController.text}"!'),
                          backgroundColor: Colors.cyan,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF06b6d4),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1e293b),
          title: Text('Tạo Bài Đăng', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                maxLines: 4,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Bạn đang nghĩ gì về truyện tranh?',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Color(0xFF0f172a),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: Color(0xFF06b6d4)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.book, color: Color(0xFFec4899)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã tạo bài đăng!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor: Colors.white,
              ),
              child: Text('Đăng'),
            ),
          ],
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.bookmark_outline, color: Colors.white),
                title: Text('Lưu bài đăng', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.report_outlined, color: Colors.white),
                title: Text('Báo cáo bài đăng', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.white),
                title: Text('Ẩn từ ${post.user.name}', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentsBottomSheet(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bình luận (${post.comments})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF0f172a),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  '/placeholder.svg?height=32&width=32',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Người dùng ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Đây là bình luận mẫu về bài đăng.',
                                      style: TextStyle(color: Colors.white70),
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
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Viết bình luận...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFF0f172a),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: Color(0xFF06b6d4)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showShareOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chia Sẻ Bài Đăng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(Icons.copy, 'Sao chép'),
                  _buildShareOption(Icons.message, 'Tin nhắn'),
                  _buildShareOption(Icons.share, 'Khác'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF06b6d4).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF06b6d4)),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
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
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}