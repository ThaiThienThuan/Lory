import 'package:flutter/material.dart';
import '../models/user.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User currentUser = MockData.users[0];
  final bool isAdmin = true;
  int currentExp = 2450;
  int maxExp = 5000;
  String userLevel = 'Bạc';
  
  final AuthService _authService = AuthService();
  String? _userName;
  String? _userPhotoUrl;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await _authService.getUserName();
    final photoUrl = await _authService.getUserPhotoUrl();
    final email = await _authService.getUserEmail();
    
    setState(() {
      _userName = name;
      _userPhotoUrl = photoUrl;
      _userEmail = email;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1e293b),
        title: Text(
          'Hồ Sơ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: Colors.cyan),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminDashboardScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06b6d4).withOpacity(0.2),
                    Color(0xFFec4899).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _userPhotoUrl != null
                            ? NetworkImage(_userPhotoUrl!)
                            : NetworkImage(currentUser.avatar),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF06b6d4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _userName ?? currentUser.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _userEmail ?? currentUser.bio,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: _getLevelColor(userLevel),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hạng $userLevel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$currentExp / $maxExp EXP',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: currentExp / maxExp,
                            minHeight: 10,
                            backgroundColor: Color(0xFF0f172a),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getLevelColor(userLevel),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Đọc truyện để tăng EXP và nâng cấp hạng!',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Người theo dõi', currentUser.followers.toString()),
                      _buildStatItem('Đang theo dõi', currentUser.following.toString()),
                      _buildStatItem('Bài đăng', '24'),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showEditProfileDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF06b6d4),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Chỉnh Sửa Hồ Sơ'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thể Loại Yêu Thích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentUser.favoriteGenres.map((genre) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFec4899).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFec4899)),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: Color(0xFFec4899),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Truy Cập Nhanh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.download,
                        title: 'Tải xuống',
                        subtitle: '12 truyện',
                        color: Color(0xFF06b6d4),
                        onTap: () {},
                      ),
                      _buildQuickActionCard(
                        icon: Icons.history,
                        title: 'Lịch sử đọc',
                        subtitle: '45 chương',
                        color: Color(0xFFec4899),
                        onTap: () {},
                      ),
                      _buildQuickActionCard(
                        icon: Icons.bookmark,
                        title: 'Đánh dấu',
                        subtitle: '8 đã lưu',
                        color: Color(0xFFfbbf24),
                        onTap: () {},
                      ),
                      _buildQuickActionCard(
                        icon: Icons.group,
                        title: 'Cộng đồng',
                        subtitle: '3 đã tham gia',
                        color: Color(0xFF10b981),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt Động Gần Đây',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _buildActivityItem(index);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {'action': 'Bắt đầu đọc', 'manga': 'Di Sản Rồng Thiêng', 'time': '2 giờ trước'},
      {'action': 'Thích bài đăng của', 'manga': 'Sakura Yamamoto', 'time': '1 ngày trước'},
      {'action': 'Thêm vào yêu thích', 'manga': 'Biên Niên Sử Ninja Mạng', 'time': '3 ngày trước'},
    ];

    final activity = activities[index];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xFF06b6d4).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              index == 0 ? Icons.play_arrow : index == 1 ? Icons.favorite : Icons.star,
              color: Color(0xFF06b6d4),
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      TextSpan(text: activity['action']),
                      TextSpan(
                        text: ' ${activity['manga']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  activity['time']!,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: currentUser.name);
    final TextEditingController bioController = TextEditingController(text: currentUser.bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1e293b),
          title: Text('Chỉnh Sửa Hồ Sơ', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tên',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Color(0xFF0f172a),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 3,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tiểu sử',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Color(0xFF0f172a),
                ),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã cập nhật hồ sơ!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor: Colors.white,
              ),
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cài Đặt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.white),
                  title: Text('Thông báo', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.white),
                  title: Text('Quyền riêng tư', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.help, color: Colors.white),
                  title: Text('Trợ giúp & Hỗ trợ', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.white),
                  title: Text('Về ứng dụng', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _authService.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Đồng':
        return Color(0xFFcd7f32);
      case 'Bạc':
        return Color(0xFFC0C0C0);
      case 'Vàng':
        return Color(0xFFFFD700);
      case 'Kim Cương':
        return Color(0xFF00CED1);
      default:
        return Colors.grey;
    }
  }
}
