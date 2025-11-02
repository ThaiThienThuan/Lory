import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsScreen extends StatefulWidget {
  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Privacy settings states
  bool _publicProfile = true;
  bool _showReadingHistory = true;
  bool _showFavorites = false;
  bool _allowMessages = true;
  bool _showOnlineStatus = true;
  bool _shareReadingActivity = false;
  bool _personalizedAds = true;
  bool _dataCollection = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _publicProfile = prefs.getBool('publicProfile') ?? true;
      _showReadingHistory = prefs.getBool('showReadingHistory') ?? true;
      _showFavorites = prefs.getBool('showFavorites') ?? false;
      _allowMessages = prefs.getBool('allowMessages') ?? true;
      _showOnlineStatus = prefs.getBool('showOnlineStatus') ?? true;
      _shareReadingActivity = prefs.getBool('shareReadingActivity') ?? false;
      _personalizedAds = prefs.getBool('personalizedAds') ?? true;
      _dataCollection = prefs.getBool('dataCollection') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Quyền riêng tư',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
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
                  Icon(
                    Icons.privacy_tip,
                    size: 64,
                    color: Color(0xFF06b6d4),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kiểm soát quyền riêng tư của bạn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Quản lý ai có thể xem thông tin của bạn',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Profile Privacy Section
            _buildSectionHeader(context, 'Quyền riêng tư hồ sơ'),

            _buildSwitchTile(
              context: context,
              title: 'Hồ sơ công khai',
              subtitle: 'Cho phép người khác xem hồ sơ của bạn',
              value: _publicProfile,
              onChanged: (value) {
                setState(() => _publicProfile = value);
                _saveSetting('publicProfile', value);
              },
            ),

            _buildSwitchTile(
              context: context,
              title: 'Hiển thị lịch sử đọc',
              subtitle: 'Người khác có thể xem truyện bạn đã đọc',
              value: _showReadingHistory,
              onChanged: (value) {
                setState(() => _showReadingHistory = value);
                _saveSetting('showReadingHistory', value);
              },
            ),

            _buildSwitchTile(
              context: context,
              title: 'Hiển thị truyện yêu thích',
              subtitle: 'Người khác có thể xem danh sách yêu thích',
              value: _showFavorites,
              onChanged: (value) {
                setState(() => _showFavorites = value);
                _saveSetting('showFavorites', value);
              },
            ),

            SizedBox(height: 24),

            // Communication Privacy Section
            _buildSectionHeader(context, 'Quyền riêng tư giao tiếp'),

            _buildSwitchTile(
              context: context,
              title: 'Cho phép tin nhắn',
              subtitle: 'Người dùng khác có thể gửi tin nhắn cho bạn',
              value: _allowMessages,
              onChanged: (value) {
                setState(() => _allowMessages = value);
                _saveSetting('allowMessages', value);
              },
            ),

            _buildSwitchTile(
              context: context,
              title: 'Hiển thị trạng thái online',
              subtitle: 'Người khác biết khi bạn đang trực tuyến',
              value: _showOnlineStatus,
              onChanged: (value) {
                setState(() => _showOnlineStatus = value);
                _saveSetting('showOnlineStatus', value);
              },
            ),

            _buildSwitchTile(
              context: context,
              title: 'Chia sẻ hoạt động đọc',
              subtitle: 'Bạn bè có thể xem bạn đang đọc truyện gì',
              value: _shareReadingActivity,
              onChanged: (value) {
                setState(() => _shareReadingActivity = value);
                _saveSetting('shareReadingActivity', value);
              },
            ),

            SizedBox(height: 24),

            // Data & Ads Privacy Section
            _buildSectionHeader(context, 'Dữ liệu & Quảng cáo'),

            _buildSwitchTile(
              context: context,
              title: 'Quảng cáo cá nhân hóa',
              subtitle: 'Hiển thị quảng cáo phù hợp với sở thích',
              value: _personalizedAds,
              onChanged: (value) {
                setState(() => _personalizedAds = value);
                _saveSetting('personalizedAds', value);
              },
            ),

            _buildSwitchTile(
              context: context,
              title: 'Thu thập dữ liệu sử dụng',
              subtitle: 'Giúp cải thiện trải nghiệm người dùng',
              value: _dataCollection,
              onChanged: (value) {
                setState(() => _dataCollection = value);
                _saveSetting('dataCollection', value);
              },
            ),

            SizedBox(height: 32),

            // Account Management Section
            _buildSectionHeader(context, 'Quản lý tài khoản'),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.lock_reset,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Thay đổi mật khẩu tài khoản',
                    color: Color(0xFF06b6d4),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context: context,
                    icon: Icons.block,
                    title: 'Danh sách chặn',
                    subtitle: 'Người dùng bạn đã chặn',
                    color: Color(0xFFf59e0b),
                    onTap: () => _showBlockedUsersDialog(context),
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context: context,
                    icon: Icons.download,
                    title: 'Tải dữ liệu của bạn',
                    subtitle: 'Tải xuống toàn bộ dữ liệu cá nhân',
                    color: Color(0xFF10b981),
                    onTap: () => _showDownloadDataDialog(context),
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    context: context,
                    icon: Icons.delete_forever,
                    title: 'Xóa tài khoản',
                    subtitle: 'Xóa vĩnh viễn tài khoản của bạn',
                    color: Colors.red,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Privacy Policy Link
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF06b6d4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF06b6d4).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF06b6d4)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chính sách bảo mật',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tìm hiểu cách chúng tôi bảo vệ dữ liệu của bạn',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF06b6d4),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        value: value,
        activeColor: Color(0xFF06b6d4),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ===== DIALOG FUNCTIONS =====

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Đổi mật khẩu',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Đã thay đổi mật khẩu thành công!'),
                    backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF06b6d4),
              foregroundColor: Colors.white,
            ),
            child: Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Danh sách chặn',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Text(
          'Bạn chưa chặn ai. Người dùng bị chặn sẽ không thể nhắn tin hoặc xem hồ sơ của bạn.',
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: Color(0xFF06b6d4))),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Tải dữ liệu',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Text(
          'Chúng tôi sẽ tạo file chứa toàn bộ dữ liệu của bạn và gửi link tải về email. Quá trình này có thể mất 24-48 giờ.',
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Yêu cầu đã được gửi! Kiểm tra email sau 24-48h.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10b981),
              foregroundColor: Colors.white,
            ),
            child: Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Xóa tài khoản',
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color)),
          ],
        ),
        content: Text(
          'Hành động này KHÔNG THỂ HOÀN TÁC. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn bao gồm:\n\n• Hồ sơ cá nhân\n• Lịch sử đọc\n• Danh sách yêu thích\n• Bài đăng và bình luận',
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Color(0xFF06b6d4))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmDialog(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Xác nhận cuối cùng',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập "XÓA TÀI KHOẢN" để xác nhận:',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            SizedBox(height: 12),
            TextField(
              controller: confirmController,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'XÓA TÀI KHOẢN',
                hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.5)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == 'XÓA TÀI KHOẢN') {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Tài khoản sẽ bị xóa trong 30 ngày. Liên hệ hỗ trợ để hủy.'),
                      backgroundColor: Colors.red),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Vui lòng nhập chính xác "XÓA TÀI KHOẢN"')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }
}
