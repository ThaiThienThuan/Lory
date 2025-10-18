import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/gallery.dart';
import '../data/mock_data.dart';
import 'upload_gallery_screen.dart'; // Import UploadGalleryScreen
import '../models/translation_group.dart';
class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Manga> followedManga = [];
  List<GalleryItem> galleryItems = [];
  List<TranslationGroup> followedGroups = [];

  final bool isTranslationGroup = true; // Hoặc isAdmin = true
  final bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLibraryData();
  }

  void _loadLibraryData() {
    followedManga = MockData.mangaList.where((manga) => manga.isFollowed).toList();
    galleryItems = MockData.galleryItems;
    followedGroups = MockData.translationGroups.where((g) => g.isFollowing).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1e293b),
        title: Text(
          'Thư Viện',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF06b6d4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: Color(0xFF06b6d4),
          tabs: [
            Tab(text: 'Theo dõi'),
            Tab(text: 'Gallery'),
            Tab(text: 'Nhóm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingTab(),
          _buildGalleryTab(),
          _buildGroupsTab(),
        ],
      ),
      floatingActionButton: (isTranslationGroup || isAdmin) && _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadGalleryScreen(),
                  ),
                );
              },
              backgroundColor: Colors.pink,
              child: Icon(Icons.add_photo_alternate, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFollowingTab() {
    if (followedManga.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline,
        title: 'Chưa theo dõi truyện nào',
        subtitle: 'Bắt đầu theo dõi truyện để xem ở đây',
        actionText: 'Khám phá truyện',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: followedManga.length,
      itemBuilder: (context, index) {
        final manga = followedManga[index];
        return _buildMangaListItem(manga);
      },
    );
  }

  Widget _buildGalleryTab() {
    if (galleryItems.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_library_outlined,
        title: 'Chưa có fanart nào',
        subtitle: 'Fanart từ cộng đồng sẽ xuất hiện ở đây',
        actionText: 'Khám phá',
        onAction: () {},
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: galleryItems.length,
      itemBuilder: (context, index) {
        final item = galleryItems[index];
        return _buildGalleryItem(item);
      },
    );
  }

  Widget _buildGroupsTab() {
    if (followedGroups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        title: 'Chưa theo dõi nhóm nào',
        subtitle: 'Theo dõi nhóm dịch để nhận cập nhật mới nhất',
        actionText: 'Tìm nhóm',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: followedGroups.length,
      itemBuilder: (context, index) {
        final group = followedGroups[index];
        return _buildGroupItem(group);
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor: Colors.white,
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
        color: Color(0xFF1e293b),
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
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      manga.author,
                      style: TextStyle(
                        color: Colors.white54,
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
                          manga.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(width: 12),
                        ...manga.genres.take(2).map((genre) {
                          return Container(
                            margin: EdgeInsets.only(right: 4),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFec4899).withOpacity(0.2),
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
                icon: Icon(Icons.more_vert, color: Colors.white),
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
    return GestureDetector(
      onTap: () {
        _showGalleryDetail(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: item.isLiked ? Color(0xFFec4899) : Colors.white,
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
                      color: Colors.white,
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
                            color: Colors.white54,
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
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.visibility, size: 12, color: Colors.white54),
                      SizedBox(width: 4),
                      Text(
                        '${item.views}',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
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
        color: Color(0xFF1e293b),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    group.description,
                    style: TextStyle(
                      color: Colors.white54,
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
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.book, size: 14, color: Color(0xFFec4899)),
                      SizedBox(width: 4),
                      Text(
                        '${group.mangaCount} truyện',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
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
                foregroundColor: Colors.white,
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
          backgroundColor: Color(0xFF1e293b),
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
                    color: Colors.white,
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
                      style: TextStyle(color: Colors.white70),
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
                      backgroundColor: Color(0xFF06b6d4).withOpacity(0.2),
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
                      label: Text('${item.likes}', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.comment, color: Colors.white),
                      label: Text('Bình luận', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: Colors.white),
                      label: Text('Chia sẻ', style: TextStyle(color: Colors.white)),
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
                leading: Icon(Icons.bookmark_remove, color: Colors.white),
                title: Text('Bỏ theo dõi', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.download, color: Colors.white),
                title: Text('Tải xuống', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Chia sẻ', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
