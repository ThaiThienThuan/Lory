import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lory/screens/help_support_screen.dart';
import 'package:lory/screens/language_settings_screen.dart';
import 'package:lory/screens/my_manga_screen.dart';
import 'package:lory/screens/reading_history_screen.dart';
import 'package:lory/screens/saved_manga_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import 'admin_dashboard_screen.dart';
import 'privacy_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ProfileScreen({super.key, required this.onToggleTheme});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ✅ KHÔNG DÙNG MOCK DATA NỮA
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // ✅ User info từ Firebase
  String? _userName;
  String? _userPhotoUrl;
  String? _userEmail;
  String? _userId;
  bool _isLoading = true;

  // ✅ Stats - BẮT ĐẦU TỪ 0
  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;
  int _readChaptersCount = 0;
  int _savedMangaCount = 0;
  int _uploadedMangaCount = 0;

  // ✅ Experience & Level
  int _currentExp = 0;
  int _maxExp = 1000;
  String _userLevel = 'Đồng';

  // ✅ User preferences
  List<String> _favoriteGenres = [];

  final bool isAdmin = false; // ✅ Có thể check từ Firestore

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ THÊM: Reload khi quay lại screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if returning from another screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSavedMangaCount(); // Refresh saved count
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      // ✅ Load user info
      final firebaseUser = _authService.getCurrentUser();
      final userId = await _authService.getUserId();

      if (firebaseUser != null && userId != null) {
        final userName = firebaseUser.displayName ??
            await _authService.getUserName() ??
            firebaseUser.email?.split('@')[0] ??
            'User';

        final userPhotoUrl = firebaseUser.photoURL ??
            await _authService.getUserPhotoUrl() ??
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=06b6d4&color=fff';

        final userEmail =
            firebaseUser.email ?? await _authService.getUserEmail() ?? '';

        // ✅ Load stats từ Firestore
        final followedManga =
            await _firestoreService.getUserFollowedManga(userId);
        final likedManga = await _firestoreService.getUserLikedManga(userId);
        final readingSessions =
            await _firestoreService.getUserReadingHistory(userId);

        await _loadUploadedMangaCount(userId);

        // ✅ Calculate exp based on activity
        final exp = readingSessions.length * 10; // 10 exp per chapter read

        if (mounted) {
          setState(() {
            _userId = userId;
            _userName = userName;
            _userPhotoUrl = userPhotoUrl;
            _userEmail = userEmail;
            _followingCount = followedManga.length;
            _savedMangaCount = likedManga.length;
            _readChaptersCount = readingSessions.length;
            _currentExp = exp;
            _userLevel = _calculateLevel(exp);
            _maxExp = _calculateMaxExp(_userLevel);
            _isLoading = false;
          });
        }

        developer.log(
            '[v0] Loaded user data - Name: $userName, Following: ${followedManga.length}, Read: ${readingSessions.length}, Uploaded: $_uploadedMangaCount',
            name: 'ProfileScreen');
      }
    } catch (e) {
      developer.log('[v0] Lỗi khi load user data: $e', name: 'ProfileScreen');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUploadedMangaCount(String userId) async {
    try {
      // Lấy tất cả manga từ Firestore
      final allManga = await _firestoreService.getMangaStream().first;

      // Lọc manga có uploaderId trùng với userId hiện tại
      final uploadedManga =
          allManga.where((manga) => manga.uploaderId == userId).toList();

      if (mounted) {
        setState(() {
          _uploadedMangaCount = uploadedManga.length;
        });
      }

      developer.log(
        '[v0] Loaded uploaded manga count: $_uploadedMangaCount',
        name: 'ProfileScreen',
      );
    } catch (e) {
      developer.log('[v0] Lỗi load uploaded manga: $e', name: 'ProfileScreen');
    }
  }

  Future<void> _changeAvatar() async {
    // Show bottom sheet with options
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  'Chọn ảnh đại diện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 20),

                // Camera option
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.camera_alt, color: Color(0xFF06b6d4)),
                  ),
                  title: Text(
                    'Chụp ảnh',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickAndUploadAvatar(ImageSource.camera);
                  },
                ),

                // Gallery option
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFec4899).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.photo_library, color: Color(0xFFec4899)),
                  ),
                  title: Text(
                    'Chọn từ thư viện',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),

                if (_userPhotoUrl != null &&
                    !_userPhotoUrl!.contains('ui-avatars.com'))
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                    title: Text(
                      'Xóa ảnh đại diện',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      await _removeAvatar();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Đang chọn ảnh...'),
            ],
          ),
          duration: Duration(seconds: 10),
          backgroundColor: Color(0xFF06b6d4),
        ),
      );

      // ✅ Pick image - Dùng method có sẵn
      File? imageFile;
      if (source == ImageSource.camera) {
        imageFile = await _cloudinaryService.pickImageFromCamera();
        // Hoặc dùng pickAvatarFromCamera() nếu đã thêm
      } else {
        imageFile = await _cloudinaryService.pickImageFromGallery();
        // Hoặc dùng pickAvatarFromGallery() nếu đã thêm
      }

      if (imageFile == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }

      // Show uploading
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Đang tải lên Cloudinary...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: Color(0xFF06b6d4),
        ),
      );

      // ✅ Upload - Dùng method có sẵn
      final imageUrl = await _cloudinaryService.uploadAvatar(
        imageFile,
        _userId!, // userId
      );

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Không thể tải ảnh lên'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update Firebase Auth
      final result = await _authService.updatePhotoURL(imageUrl);

      if (!result['success']) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text(result['message'])),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update Firestore (optional)
      if (_userId != null) {
        try {
          await _firestoreService.updateUser(_userId!, {
            'photoUrl': imageUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          developer.log('[v0] Firestore update optional: $e',
              name: 'ProfileScreen');
        }
      }

      // Update UI
      setState(() {
        _userPhotoUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Đã cập nhật ảnh đại diện!'),
            ],
          ),
          backgroundColor: Color(0xFF10b981),
        ),
      );

      developer.log('[v0] Avatar updated: $imageUrl', name: 'ProfileScreen');
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Lỗi: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );

      developer.log('[v0] Lỗi upload avatar: $e', name: 'ProfileScreen');
    }
  }

  Future<void> _removeAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'Xóa ảnh đại diện?',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          content: Text(
            'Đặt lại về avatar mặc định?',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Đang xóa...'),
            ],
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Color(0xFF06b6d4),
        ),
      );

      // Generate default avatar
      final defaultAvatarUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_userName ?? 'User')}&background=06b6d4&color=fff&size=400';

      // Update Firebase Auth
      final user = _authService.getCurrentUser();
      if (user != null) {
        await user.updatePhotoURL(defaultAvatarUrl);
        await user.reload();
      }

      // Update UI
      setState(() {
        _userPhotoUrl = defaultAvatarUrl;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Đã đặt lại avatar mặc định'),
            ],
          ),
          backgroundColor: Color(0xFF10b981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Lỗi: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadSavedMangaCount() async {
    if (_userId == null) return;

    try {
      // ✅ Get danh sách manga đã follow
      final followedMangaIds =
          await _firestoreService.getUserFollowedManga(_userId!);

      if (mounted) {
        setState(() {
          _savedMangaCount = followedMangaIds.length;
        });
      }

      developer.log(
        '[v0] Loaded saved manga count: $_savedMangaCount',
        name: 'ProfileScreen',
      );
    } catch (e) {
      developer.log('[v0] Lỗi load saved manga: $e', name: 'ProfileScreen');
    }
  }

  // ✅ Calculate level dựa trên exp
  String _calculateLevel(int exp) {
    if (exp < 500) return 'Đồng';
    if (exp < 1500) return 'Bạc';
    if (exp < 3000) return 'Vàng';
    return 'Kim Cương';
  }

  // ✅ Calculate max exp for next level
  int _calculateMaxExp(String level) {
    switch (level) {
      case 'Đồng':
        return 500;
      case 'Bạc':
        return 1500;
      case 'Vàng':
        return 3000;
      case 'Kim Cương':
        return 5000;
      default:
        return 1000;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ Sơ Người Dùng'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: Color(0xFF06b6d4)),
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
            icon: Icon(Icons.settings,
                color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF06b6d4)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: Color(0xFF06b6d4),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ✅ HEADER với gradient
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
                          // Avatar
                          // Avatar with edit button
                          GestureDetector(
                            onTap: _changeAvatar, // ✅ THÊM onTap
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF06b6d4).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _userPhotoUrl != null
                                        ? NetworkImage(_userPhotoUrl!)
                                        : null,
                                    // ignore: sort_child_properties_last
                                    child: _userPhotoUrl == null
                                        ? Icon(Icons.person,
                                            size: 50, color: Colors.white)
                                        : null,
                                    backgroundColor: Color(0xFF06b6d4),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF06b6d4),
                                          Color(0xFF0891b2)
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF06b6d4)
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Name
                          Text(
                            _userName ?? 'User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Email
                          Text(
                            _userEmail ?? 'email@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),

                          SizedBox(height: 20),

                          // ✅ LEVEL & EXP CARD
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _getLevelColor(_userLevel)
                                                .withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.workspace_premium_rounded,
                                            color: _getLevelColor(_userLevel),
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hạng $_userLevel',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Level ${_calculateLevelNumber(_userLevel)}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withOpacity(0.6),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '$_currentExp / $_maxExp',
                                      style: TextStyle(
                                        color: Color(0xFF06b6d4),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _currentExp / _maxExp,
                                    minHeight: 10,
                                    backgroundColor: isDark
                                        ? Color(0xFF0f172a)
                                        : Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getLevelColor(_userLevel),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Đọc truyện để tăng EXP và nâng cấp hạng!',
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

                          SizedBox(height: 20),

                          // ✅ STATS ROW
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  icon: Icons.people_outline_rounded,
                                  value: _followersCount,
                                  label: 'Người theo dõi',
                                  color: Color(0xFF06b6d4),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color:
                                      isDark ? Colors.white12 : Colors.black12,
                                ),
                                _buildStatItem(
                                  icon: Icons.bookmark_outline_rounded,
                                  value: _followingCount,
                                  label: 'Đã lưu',
                                  color: Color(0xFFec4899),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color:
                                      isDark ? Colors.white12 : Colors.black12,
                                ),
                                _buildStatItem(
                                  icon: Icons.menu_book_rounded,
                                  value: _readChaptersCount,
                                  label: 'Chương đã đọc',
                                  color: Color(0xFFfbbf24),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Edit Profile Button
                          ElevatedButton.icon(
                            onPressed: () {
                              _showEditProfileDialog(context);
                            },
                            icon: Icon(Icons.edit_rounded, size: 18),
                            label: Text('Chỉnh sửa hồ sơ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF06b6d4),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // ✅ QUICK ACTIONS GRID
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dashboard_customize_rounded,
                                  color: Color(0xFF06b6d4), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Truy cập nhanh',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildQuickActionCard(
                                icon: Icons.history_rounded,
                                title: 'Lịch sử đọc',
                                subtitle: '$_readChaptersCount chương',
                                color: Color(0xFFec4899),
                                onTap: () {
                                  // ✅ Navigate to reading history screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReadingHistoryScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickActionCard(
                                icon: Icons.bookmark_rounded,
                                title: 'Đã lưu',
                                subtitle: '$_savedMangaCount truyện',
                                color: Color(0xFFfbbf24),
                                onTap: () async {
                                  // ✅ Navigate to saved manga screen
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SavedMangaScreen(),
                                    ),
                                  );
                                  // ✅ Reload count after returning
                                  _loadSavedMangaCount();
                                },
                              ),
                              _buildQuickActionCard(
                                icon: Icons.upload_rounded,
                                title: 'Đăng truyện',
                                subtitle: 'Tạo mới',
                                color: Color(0xFF06b6d4),
                                onTap: () {
                                  Navigator.pushNamed(context, '/upload-manga');
                                },
                              ),
                              _buildQuickActionCard(
                                icon: Icons.auto_stories_rounded,
                                title: 'Truyện của tôi',
                                subtitle: '$_uploadedMangaCount truyện',
                                color: Color(0xFF10b981),
                                onTap: () {
                                  // ✅ Navigate to my manga screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyMangaScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  int _calculateLevelNumber(String level) {
    switch (level) {
      case 'Đồng':
        return 1;
      case 'Bạc':
        return 2;
      case 'Vàng':
        return 3;
      case 'Kim Cương':
        return 4;
      default:
        return 1;
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Đồng':
        return Color(0xFFcd7f32); // Bronze
      case 'Bạc':
        return Color(0xFFC0C0C0); // Silver
      case 'Vàng':
        return Color(0xFFfbbf24); // Gold
      case 'Kim Cương':
        return Color(0xFF06b6d4); // Diamond
      default:
        return Color(0xFF06b6d4);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userName);

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
              Icon(Icons.edit_rounded, color: Color(0xFF06b6d4)),
              SizedBox(width: 12),
              Text(
                'Chỉnh sửa hồ sơ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'Tên hiển thị',
                  labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  prefixIcon: Icon(Icons.person, color: Color(0xFF06b6d4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF06b6d4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF06b6d4).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF06b6d4), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tên này sẽ hiển thị trong bình luận và profile',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
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
                final newName = nameController.text.trim();

                // Validation
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Tên không được để trống'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (newName.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Tên phải có ít nhất 2 ký tự'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang cập nhật...'),
                      ],
                    ),
                    duration: Duration(seconds: 10),
                    backgroundColor: Color(0xFF06b6d4),
                  ),
                );

                try {
                  // ✅ Update bằng AuthService method mới
                  final result = await _authService.updateDisplayName(newName);

                  if (!result['success']) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(child: Text(result['message'])),
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // ✅ Optional: Update Firestore (nếu có users collection)
                  if (_userId != null) {
                    try {
                      await _firestoreService.updateUser(_userId!, {
                        'displayName': newName,
                        'updatedAt': DateTime.now().toIso8601String(),
                      });
                    } catch (e) {
                      developer.log(
                        '[v0] Firestore update optional, skipped: $e',
                        name: 'ProfileScreen',
                      );
                    }
                  }

                  // Update UI
                  setState(() {
                    _userName = newName;
                  });

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Đã cập nhật hồ sơ thành công!'),
                        ],
                      ),
                      backgroundColor: Color(0xFF10b981),
                    ),
                  );

                  developer.log(
                    '[v0] Profile updated successfully',
                    name: 'ProfileScreen',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(child: Text('Lỗi: ${e.toString()}')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );

                  developer.log('[v0] Lỗi update profile: $e',
                      name: 'ProfileScreen');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  'Cài Đặt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 16),

                // Theme Toggle
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                  title: Text(
                    'Giao diện',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF06b6d4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF06b6d4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: Color(0xFF06b6d4),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          isDark ? 'Tối' : 'Sáng',
                          style: TextStyle(
                            color: Color(0xFF06b6d4),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    widget.onToggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,
                            ),
                            SizedBox(width: 12),
                            Text(
                                'Đã chuyển sang chế độ ${isDark ? "Sáng" : "Tối"}'),
                          ],
                        ),
                        backgroundColor: Color(0xFF06b6d4),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),

                // Language Settings
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFec4899).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.language, color: Color(0xFFec4899)),
                  ),
                  title: Text(
                    'Ngôn ngữ / Language',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    context.locale.languageCode == 'vi' ? '🇻🇳 VI' : '🇺🇸 EN',
                    style: TextStyle(
                      color: Color(0xFFec4899),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),

                // Change Password
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFfbbf24).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.lock_reset, color: Color(0xFFfbbf24)),
                  ),
                  title: Text(
                    'Đổi mật khẩu',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showChangePasswordDialog(context);
                  },
                ),

                // Notifications
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF10b981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.notifications, color: Color(0xFF10b981)),
                  ),
                  title: Text(
                    'Thông báo',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                  },
                ),

                // Privacy
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF8b5cf6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.privacy_tip, color: Color(0xFF8b5cf6)),
                  ),
                  title: Text(
                    'Quyền riêng tư',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacySettingsScreen(),
                      ),
                    );
                  },
                ),

                // Help & Support
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.help, color: Color(0xFF06b6d4)),
                  ),
                  title: Text(
                    'Trợ giúp & Hỗ trợ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HelpSupportScreen(),
                      ),
                    );
                  },
                ),

                // About
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.info, color: Colors.grey),
                  ),
                  title: Text(
                    'Về ứng dụng',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showAboutDialog(context);
                  },
                ),

                Divider(height: 1, thickness: 1),

                // Logout
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.logout, color: Colors.red),
                  ),
                  title: Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final scaffoldContext = context;
                    Navigator.pop(bottomSheetContext);
                    _showLogoutDialog(scaffoldContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.lock_reset, color: Color(0xFF06b6d4), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Đổi mật khẩu',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // ✅ THÊM: Constraints để tránh overflow
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.6, // 60% screen height
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current Password
                      TextField(
                        controller: currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                          hintText: 'Nhập mật khẩu hiện tại',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Color(0xFF06b6d4), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.5),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF06b6d4),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),

                      // New Password
                      TextField(
                        controller: newPasswordController,
                        obscureText: _obscureNewPassword,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                          hintText: 'Nhập mật khẩu mới',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color: Color(0xFF06b6d4), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.5),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF06b6d4),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Confirm Password
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                          hintText: 'Nhập lại mật khẩu mới',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Color(0xFF06b6d4), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.5),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF06b6d4),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Password Requirements (Compact version)
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
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Color(0xFF06b6d4), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Yêu cầu: Ít nhất 6 ký tự',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validation
                    if (currentPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text('Vui lòng điền đầy đủ thông tin'),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Mật khẩu phải có ít nhất 6 ký tự'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text('Mật khẩu xác nhận không khớp'),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    // Show loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Đang đổi mật khẩu...'),
                          ],
                        ),
                        duration: Duration(seconds: 10),
                        backgroundColor: Color(0xFF06b6d4),
                      ),
                    );

                    try {
                      final result = await _authService.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      if (result['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 12),
                                Text('Đổi mật khẩu thành công!'),
                              ],
                            ),
                            backgroundColor: Color(0xFF10b981),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 12),
                                Expanded(child: Text(result['message'])),
                              ],
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Expanded(child: Text('Lỗi: ${e.toString()}')),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF06b6d4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF06b6d4), Color(0xFFec4899)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.apps_rounded, color: Colors.white, size: 40),
              ),
              SizedBox(height: 16),
              Text(
                'Lory Manga',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phiên bản 1.0.0',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Ứng dụng đọc truyện tranh và manga trực tuyến',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '© 2025 Lory Manga. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(
                  color: Color(0xFF06b6d4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
