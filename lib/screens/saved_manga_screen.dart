import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/manga.dart';
import 'dart:developer' as developer;

class SavedMangaScreen extends StatefulWidget {
  const SavedMangaScreen({Key? key}) : super(key: key);

  @override
  State<SavedMangaScreen> createState() => _SavedMangaScreenState();
}

class _SavedMangaScreenState extends State<SavedMangaScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<Manga> _savedMangaList = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadSavedManga();
  }

  Future<void> _loadSavedManga() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        developer.log('[v0] User not logged in', name: 'SavedMangaScreen');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _userId = userId;

      // Get IDs of followed manga
      final followedMangaIds =
          await _firestoreService.getUserFollowedManga(userId);

      if (followedMangaIds.isEmpty) {
        setState(() {
          _savedMangaList = [];
          _isLoading = false;
        });
        return;
      }

      // Get manga details
      final List<Manga> mangaList = [];
      for (var mangaId in followedMangaIds) {
        final manga = await _firestoreService.getMangaById(mangaId);
        if (manga != null) {
          mangaList.add(manga);
        }
      }

      setState(() {
        _savedMangaList = mangaList;
        _isLoading = false;
      });

      developer.log('[v0] Loaded ${mangaList.length} saved manga',
          name: 'SavedMangaScreen');
    } catch (e) {
      developer.log('[v0] Load error: $e', name: 'SavedMangaScreen');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unfollowManga(Manga manga) async {
    try {
      if (_userId != null) {
        await _firestoreService.toggleMangaFollow(_userId!, manga.id, false);

        setState(() {
          _savedMangaList.removeWhere((m) => m.id == manga.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Đã bỏ lưu'),
              ],
            ),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
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
          'Đã lưu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF06b6d4)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : _savedMangaList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedManga,
                  color: Color(0xFF06b6d4),
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _savedMangaList.length,
                    itemBuilder: (context, index) {
                      final manga = _savedMangaList[index];
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
              color: Color(0xFFfbbf24).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border,
              size: 80,
              color: Color(0xFFfbbf24),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Chưa có truyện đã lưu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Lưu truyện yêu thích để đọc sau',
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
              Navigator.pop(context);
            },
            icon: Icon(Icons.explore, color: Colors.white),
            label: Text(
              'Khám phá truyện',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfbbf24),
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
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/detail',
          arguments: manga,
        );

        // Reload nếu quay lại
        if (result == true || result == null) {
          _loadSavedManga();
        }
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    manga.coverImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Color(0xFF06b6d4).withOpacity(0.1),
                        child: Icon(
                          Icons.broken_image,
                          color: Color(0xFF06b6d4),
                          size: 48,
                        ),
                      );
                    },
                  ),
                  // Bookmark button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _unfollowManga(manga),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: Color(0xFFfbbf24),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Color(0xFFfbbf24)),
                      SizedBox(width: 4),
                      Text(
                        manga.rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 12),
                      ),
                      Spacer(),
                      Icon(Icons.menu_book, size: 14, color: Color(0xFF06b6d4)),
                      SizedBox(width: 4),
                      Text(
                        '${manga.chapters.length}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
