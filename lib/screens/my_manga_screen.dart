import 'package:flutter/material.dart';
import 'package:lory/screens/edit_manga_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/manga.dart';
import 'dart:developer' as developer;

class MyMangaScreen extends StatefulWidget {
  const MyMangaScreen({Key? key}) : super(key: key);

  @override
  State<MyMangaScreen> createState() => _MyMangaScreenState();
}

class _MyMangaScreenState extends State<MyMangaScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<Manga> _myMangaList = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadMyManga();
  }

  Future<void> _loadMyManga() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        developer.log('[v0] User not logged in', name: 'MyMangaScreen');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _userId = userId;

      // Get all manga uploaded by this user
      final allManga = await _firestoreService.getMangaStream().first;
      final myManga = allManga
          .where((manga) => manga.uploaderId == userId)
          .toList()
        ..sort((a, b) => b.views.compareTo(a.views));

      setState(() {
        _myMangaList = myManga;
        _isLoading = false;
      });

      developer.log('[v0] Loaded ${myManga.length} manga',
          name: 'MyMangaScreen');
    } catch (e) {
      developer.log('[v0] Load error: $e', name: 'MyMangaScreen');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

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
  }

  Future<void> _deleteManga(Manga manga) async {
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
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Xóa truyện?',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${manga.title}"?\n\nHành động này không thể hoàn tác!',
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
          duration: Duration(seconds: 10),
          backgroundColor: Color(0xFF06b6d4),
        ),
      );

      final success = await _firestoreService.deleteManga(manga.id);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        setState(() {
          _myMangaList.removeWhere((m) => m.id == manga.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Đã xóa truyện'),
              ],
            ),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xóa truyện'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Truyện của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            tooltip: 'Đăng truyện mới',
            onPressed: () {
              Navigator.pushNamed(context, '/upload-manga');
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
                    'Đang tải truyện...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : _myMangaList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMyManga,
                  color: Color(0xFF06b6d4),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _myMangaList.length,
                    itemBuilder: (context, index) {
                      final manga = _myMangaList[index];
                      return _buildMangaCard(manga, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFF10b981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 80,
              color: Color(0xFF10b981),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Chưa có truyện nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Bắt đầu chia sẻ truyện của bạn',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/upload-manga');
            },
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            label: Text(
              'Đăng truyện mới',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10b981),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMangaCard(Manga manga, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detail',
              arguments: manga,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // Cover Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    manga.coverImage,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 120,
                        color: Color(0xFF06b6d4).withOpacity(0.1),
                        child: Icon(
                          Icons.broken_image,
                          color: Color(0xFF06b6d4),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),

                      // Stats row
                      Row(
                        children: [
                          Icon(Icons.visibility,
                              size: 14, color: Color(0xFF06b6d4)),
                          SizedBox(width: 4),
                          Text(
                            '${manga.views}',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.star, size: 14, color: Color(0xFFfbbf24)),
                          SizedBox(width: 4),
                          Text(
                            '${manga.rating.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.menu_book,
                              size: 14, color: Color(0xFFec4899)),
                          SizedBox(width: 4),
                          Text(
                            '${manga.chapters.length}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: manga.status == 'Đang tiến hành'
                              ? Color(0xFF10b981).withOpacity(0.2)
                              : Color(0xFF06b6d4).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          manga.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: manga.status == 'Đang tiến hành'
                                ? Color(0xFF10b981)
                                : Color(0xFF06b6d4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // ✅ Navigate to edit screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMangaScreen(manga: manga),
                        ),
                      );

                      // ✅ Reload list if edit was successful
                      if (result == true) {
                        _loadMyManga();
                      }
                    } else if (value == 'delete') {
                      _deleteManga(manga);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: Color(0xFF06b6d4)),
                          SizedBox(width: 12),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Xóa'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
