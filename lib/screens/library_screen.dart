import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../data/mock_data.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Manga> followedManga = [];
  List<Manga> readingHistory = [];
  List<Manga> favorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLibraryData();
  }

  void _loadLibraryData() {
    // Mock data for library
    followedManga = MockData.mangaList.where((manga) => manga.isFollowed).toList();
    readingHistory = MockData.mangaList.take(3).toList();
    favorites = MockData.mangaList.where((manga) => manga.isLiked).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF06b6d4),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Color(0xFF06b6d4),
          tabs: [
            Tab(text: 'Following'),
            Tab(text: 'History'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingTab(),
          _buildHistoryTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (followedManga.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline,
        title: 'No Following Manga',
        subtitle: 'Start following manga to see them here',
        actionText: 'Browse Manga',
        onAction: () {
          // Navigate to home tab
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: followedManga.length,
      itemBuilder: (context, index) {
        final manga = followedManga[index];
        return _buildMangaListItem(manga, showProgress: true);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (readingHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Reading History',
        subtitle: 'Your reading history will appear here',
        actionText: 'Start Reading',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: readingHistory.length,
      itemBuilder: (context, index) {
        final manga = readingHistory[index];
        return _buildMangaListItem(manga, showLastRead: true);
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (favorites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_outline,
        title: 'No Favorites',
        subtitle: 'Like manga to add them to your favorites',
        actionText: 'Discover Manga',
        onAction: () {},
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final manga = favorites[index];
        return _buildMangaGridItem(manga);
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
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMangaListItem(Manga manga, {bool showProgress = false, bool showLastRead = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
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
                  manga.cover,
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      manga.author,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (showProgress) ...[
                      Text(
                        'Chapter ${manga.chapters.length} • ${manga.status}',
                        style: TextStyle(
                          color: Color(0xFF06b6d4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.6, // Mock progress
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                      ),
                    ],
                    if (showLastRead) ...[
                      Text(
                        'Last read: Chapter 1 • 2 days ago',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Color(0xFFfbbf24)),
                        SizedBox(width: 4),
                        Text(
                          manga.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        ...manga.genres.take(2).map((genre) {
                          return Container(
                            margin: EdgeInsets.only(right: 4),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFec4899).withOpacity(0.1),
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
                icon: Icon(Icons.more_vert),
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

  Widget _buildMangaGridItem(Manga manga) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: manga,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                      manga.cover,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFec4899),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Color(0xFFfbbf24)),
                      SizedBox(width: 2),
                      Text(
                        manga.rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
                'Sort by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Recently Added'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Rating'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text('Title A-Z'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.update),
                title: Text('Last Updated'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMangaOptions(BuildContext context, Manga manga) {
    showModalBottomSheet(
      context: context,
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
                leading: Icon(Icons.bookmark_remove),
                title: Text('Remove from Library'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.download),
                title: Text('Download'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
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
