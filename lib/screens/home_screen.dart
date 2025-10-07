import 'package:flutter/material.dart';
import 'dart:async';
import '../models/manga.dart';
import '../data/mock_data.dart';
import 'upload_manga_screen.dart'; // Import UploadMangaScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  List<Manga> _filteredManga = MockData.mangaList;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;
  int _displayedMangaCount = 6; // Số lượng truyện hiển thị ban đầu

  final bool isTranslationGroup = true; // Hoặc isAdmin = true
  final bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Tự động chuyển banner mỗi 4 giây
    _startBannerAutoScroll();
    // Lắng nghe scroll để lazy load
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _scrollController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  // Bắt đầu tự động cuộn banner
  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerPage + 1) % MockData.featuredManga.length;
        _bannerController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Xử lý lazy loading khi scroll
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load thêm truyện khi gần cuối danh sách
      if (_displayedMangaCount < _filteredManga.length) {
        setState(() {
          _displayedMangaCount = (_displayedMangaCount + 6).clamp(0, _filteredManga.length);
        });
      }
    }
  }

  // Lọc truyện theo từ khóa tìm kiếm
  void _filterManga(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredManga = MockData.mangaList;
      } else {
        _filteredManga = MockData.mangaList
            .where((manga) =>
                manga.title.toLowerCase().contains(query.toLowerCase()) ||
                manga.genres.any((genre) =>
                    genre.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
      _displayedMangaCount = 6; // Reset số lượng hiển thị khi tìm kiếm
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Color(0xFF06b6d4)),
            SizedBox(width: 8),
            Text(
              'Lory',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterManga,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm truyện tranh...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF06b6d4)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            _filterManga('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFF1e293b),
                ),
              ),
            ),

            Container(
              height: 180,
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerPage = index;
                  });
                },
                itemCount: (MockData.featuredManga.length / 2).ceil(),
                itemBuilder: (context, pageIndex) {
                  final startIndex = pageIndex * 2;
                  final endIndex = (startIndex + 2).clamp(0, MockData.featuredManga.length);
                  final mangasInPage = MockData.featuredManga.sublist(startIndex, endIndex);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: mangasInPage.map((manga) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: manga,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: mangasInPage.last == manga ? 0 : 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF06b6d4).withOpacity(0.3),
                                    Color(0xFFec4899).withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      manga.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          manga.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.star, color: Color(0xFFfbbf24), size: 12),
                                            SizedBox(width: 4),
                                            Text(
                                              manga.rating.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
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
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (MockData.featuredManga.length / 2).ceil(),
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentBannerPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentBannerPage == index
                        ? Color(0xFF06b6d4)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            _buildMangaSection(
              title: 'Truyện Hot',
              icon: Icons.local_fire_department,
              iconColor: Color(0xFFef4444),
              mangaList: MockData.hotManga.take(6).toList(),
            ),

            SizedBox(height: 24),

            _buildMangaSection(
              title: 'Mới Cập Nhật',
              icon: Icons.update,
              iconColor: Color(0xFF10b981),
              mangaList: MockData.recentlyUpdatedManga.take(6).toList(),
            ),

            SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.library_books, color: Color(0xFF06b6d4), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Toàn Bộ Truyện',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${_filteredManga.length} truyện',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _displayedMangaCount.clamp(0, _filteredManga.length),
              itemBuilder: (context, index) {
                final manga = _filteredManga[index];
                return _buildMangaCard(manga);
              },
            ),

            if (_displayedMangaCount < _filteredManga.length)
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                  ),
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: (isTranslationGroup || isAdmin)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadMangaScreen(),
                  ),
                );
              },
              backgroundColor: Colors.cyan,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // Widget xây dựng section truyện ngang
  Widget _buildMangaSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Manga> mangaList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: mangaList.length,
            itemBuilder: (context, index) {
              final manga = mangaList[index];
              return Container(
                width: 140,
                margin: EdgeInsets.only(right: 12),
                child: _buildMangaCard(manga),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget card truyện
  Widget _buildMangaCard(Manga manga) {
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
          color: Color(0xFF1e293b),
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      manga.cover,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Badge trạng thái
                  if (manga.chapters.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF06b6d4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          manga.chapters.first.releaseDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                    manga.title,
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
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFfbbf24),
                      ),
                      SizedBox(width: 4),
                      Text(
                        manga.rating.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: Colors.white54,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${manga.views ~/ 1000}K',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: manga.genres.take(2).map((genre) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFec4899).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 9,
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
          ],
        ),
      ),
    );
  }
}