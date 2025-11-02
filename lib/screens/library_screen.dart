import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/manga.dart';
import '../models/gallery.dart';
import '../models/post.dart';
import '../models/translation_group.dart';
import '../services/firestore_service.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<Manga> followedManga = [];
  List<Manga> likedManga = [];
  List<GalleryItem> galleryItems = [];
  List<TranslationGroup> followedGroups = [];
  List<Post> fanartPosts = [];
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId;

  final bool isTranslationGroup = true;
  final bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
    _getCurrentUser();
    _loadLibraryData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLibraryData();
      setState(() {});
    }
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
    }
  }

  void _loadLibraryData() async {
    if (_currentUserId == null) {
      return;
    }

    try {
      // Lấy danh sách ID manga yêu thích từ Firestore
      final likedMangaIds =
          await _firestoreService.getUserLikedManga(_currentUserId!);

      // Lấy thông tin chi tiết của các manga yêu thích
      List<Manga> likedMangaList = [];
      for (String mangaId in likedMangaIds) {
        final manga = await _firestoreService.getMangaById(mangaId);
        if (manga != null) {
          likedMangaList.add(manga);
        }
      }

      if (mounted) {
        setState(() {
          likedManga = likedMangaList;
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách yêu thích: $e');
    }

    try {
      final posts = await _firestoreService.getFanartPosts();
      if (mounted) {
        setState(() {
          fanartPosts = posts; // Lưu trực tiếp danh sách Post
        });
      }
    } catch (e) {
      print('Lỗi khi tải fanart posts: $e');
      if (mounted) {
        setState(() {
          fanartPosts = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thư Viện',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF06b6d4),
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: Color(0xFF06b6d4),
          tabs: [
            Tab(text: 'Yêu thích'),
            Tab(text: 'Gallery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLikedTab(),
          _buildGalleryTab(),
        ],
      ),
    );
  }

  Widget _buildLikedTab() {
    if (likedManga.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_outline,
        title: 'Chưa yêu thích truyện nào',
        subtitle: 'Nhấn nút trái tim để thêm truyện vào danh sách yêu thích',
        actionText: 'Khám phá truyện',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: likedManga.length,
      itemBuilder: (context, index) {
        final manga = likedManga[index];
        return _buildMangaListItem(manga);
      },
    );
  }
  Widget _buildGalleryTab() {
  if (fanartPosts.isEmpty) {
    return const Center(
      child: Text('Chưa có fanart nào 🖌️'),
    );
  }

  return GridView.builder(
    padding: const EdgeInsets.all(8),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.8,
    ),
    itemCount: fanartPosts.length,
    itemBuilder: (context, index) {
      final post = fanartPosts[index];
      if (post.images.isEmpty) return const SizedBox();

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          post.images.first,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    },
  );
}

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor:
                    Colors.white, // ✅ Button text luôn trắng trên nền cyan
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMangaListItem(Manga manga) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: manga,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  manga.coverImage,
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      manga.author,
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha(179),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chương ${manga.chapters.length} • ${manga.status == "ongoing" ? "Đang ra" : "Hoàn thành"}',
                      style: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Color(0xFFfbbf24)),
                        SizedBox(width: 4),
                        Text(
                          manga.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        SizedBox(width: 12),
                        ...manga.genres.take(2).map((genre) {
                          return Container(
                            margin: EdgeInsets.only(right: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFec4899).withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFec4899),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                onPressed: () {
                  _showMangaOptions(context, manga);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(GalleryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _showGalleryDetail(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      item.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(153),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: item.isLiked
                            ? Color(0xFFec4899)
                            : Colors
                                .white, // ✅ Icon trên ảnh luôn trắng vì nền tối
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(item.artistAvatar),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.artistName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(179),  
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: Color(0xFFec4899)),
                      SizedBox(width: 4),
                      Text(
                        '${item.likes}',
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.visibility,
                          size: 12,
                          color: isDark
                              ? Colors.white54
                              : Colors.black54),  
                      SizedBox(width: 4),
                      Text(
                        '${item.views}',
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
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

  Widget _buildGroupItem(TranslationGroup group) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                group.avatar,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    group.description,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(179),  
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Color(0xFF06b6d4)),
                      SizedBox(width: 4),
                      Text(
                        '${group.members} thành viên',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.book, size: 14, color: Color(0xFFec4899)),
                      SizedBox(width: 4),
                      Text(
                        '${group.mangaCount} truyện',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Toggle follow
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã theo dõi nhóm')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor: Colors.white, // ✅ Button text luôn trắng
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Xem', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showGalleryDetail(GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor:
              Theme.of(context).dialogTheme.backgroundColor, // ✅ Đã đúng
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(item.artistAvatar),
                    ),
                    SizedBox(width: 8),
                    Text(
                      item.artistName,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (item.mangaTitle != null)
                  Text(
                    'Từ: ${item.mangaTitle}',
                    style: TextStyle(
                      color: Color(0xFF06b6d4),
                      fontSize: 14,
                    ),
                  ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: item.tags.map((tag) {
                    return Chip(
                      label: Text(tag, style: TextStyle(fontSize: 12)),
                      backgroundColor: Color(0xFF06b6d4).withAlpha(51),
                      labelStyle: TextStyle(color: Color(0xFF06b6d4)),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.favorite, color: Color(0xFFec4899)),
                      label: Text('${item.likes}',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.comment,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      label: Text('Bình luận',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          )),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      label: Text('Chia sẻ',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMangaOptions(BuildContext context, Manga manga) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
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
                leading: Icon(Icons.favorite_border,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                title: Text('Bỏ yêu thích',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  // Gọi toggleMangaLike để xóa yêu thích
                  if (_currentUserId != null) {
                    await _firestoreService.toggleMangaLike(
                        _currentUserId!, manga.id, false);

                    // Cập nhật state để xóa manga khỏi danh sách
                    if (mounted) {
                      setState(() {
                        likedManga.removeWhere((m) => m.id == manga.id);
                      });
                    }

                    // Hiển thị thông báo sử dụng reference đã lưu
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Đã bỏ yêu thích ${manga.title}')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.download,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                title: Text('Tải xuống',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.share,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                title: Text('Chia sẻ',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
