import 'package:flutter/material.dart';
import 'dart:async';
import '../models/manga.dart';
import '../services/firestore_service.dart';
import 'upload_manga_screen.dart' as upload;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController(initialPage: 5000);
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();

  List<Manga> _filteredManga = [];
  List<Manga> _allManga = [];
  List<Manga> _featuredManga = [];
  List<Manga> _hotManga = [];
  List<Manga> _recentManga = [];
  Timer? _bannerTimer;
  int _currentBannerPage = 0;
  int _displayedMangaCount = 6;
  bool _isLoading = true;

  final bool isTranslationGroup = true;
  final bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
    _scrollController.addListener(_onScroll);
    _loadMangaFromFirestore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _scrollController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _loadMangaFromFirestore() {
    _firestoreService.getMangaStream().listen((mangaList) {
      setState(() {
        _allManga = mangaList;
        _filteredManga = mangaList;
        _isLoading = false;
        
        // Featured manga: lấy 6 manga có rating cao nhất
        _featuredManga = List.from(mangaList)
          ..sort((a, b) => b.rating.compareTo(a.rating))
          ..take(6).toList();

        // Recent manga: sắp xếp theo thời gian
        _recentManga = List.from(mangaList)
          ..sort((a, b) {
            if (a.chapters.isEmpty) return 1;
            if (b.chapters.isEmpty) return -1;
            return b.chapters.first.releaseDate.compareTo(a.chapters.first.releaseDate);
          })
          ..take(10).toList();
      });
    });

    // Load hot manga (manga có views cao nhất)
    _firestoreService.getHotMangaStream(limit: 10).listen((hotList) {
      setState(() {
        _hotManga = hotList;
      });
    });
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = _bannerController.page!.toInt() + 1;
        _bannerController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_displayedMangaCount < _filteredManga.length) {
        setState(() {
          _displayedMangaCount =
              (_displayedMangaCount + 6).clamp(0, _filteredManga.length);
        });
      }
    }
  }

  void _filterManga(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredManga = _allManga;
      } else {
        final lowerQuery = query.toLowerCase().trim();
        _filteredManga = _allManga
            .where((manga) =>
                manga.title.toLowerCase().contains(lowerQuery) ||
                manga.author.toLowerCase().contains(lowerQuery) ||
                manga.genres.any((genre) =>
                    genre.toLowerCase().contains(lowerQuery)))
            .toList();
      }
      _displayedMangaCount = 6;
      print('[v0] Search query: "$query", Results: ${_filteredManga.length}');
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu từ Firebase...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
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
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            return value.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.white54),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterManga('');
                                    },
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFF1e293b),
                      ),
                    ),
                  ),
                  if (_featuredManga.isNotEmpty) ...[
                    Container(
                      height: 180,
                      child: PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerPage = index;
                          });
                        },
                        itemCount: _featuredManga.isEmpty ? 0 : 10000,
                        itemBuilder: (context, pageIndex) {
                          final actualItemCount = _featuredManga.length;
                          if (actualItemCount == 0) return SizedBox.shrink();

                          final baseIndex = (pageIndex * 2) % actualItemCount;
                          final manga1 = _featuredManga[baseIndex];
                          final manga2 = _featuredManga[(baseIndex + 1) % actualItemCount];

                          final mangasInPage = [manga1, manga2];

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
                                              manga.coverImage,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Color(0xFF1e293b),
                                                  child: Icon(
                                                    Icons.image_outlined,
                                                    size: 48,
                                                    color: Color(0xFF06b6d4).withOpacity(0.5),
                                                  ),
                                                );
                                              },
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
                                                    Icon(Icons.star,
                                                        color: Color(0xFFfbbf24),
                                                        size: 12),
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
                        (_featuredManga.length / 2).ceil(),
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
                  ],
                  if (_hotManga.isNotEmpty)
                    _buildMangaSection(
                      title: 'Truyện Hot',
                      icon: Icons.local_fire_department,
                      iconColor: Color(0xFFef4444),
                      mangaList: _hotManga.take(6).toList(),
                    ),
                  SizedBox(height: 24),
                  if (_recentManga.isNotEmpty)
                    _buildMangaSection(
                      title: 'Mới Cập Nhật',
                      icon: Icons.update,
                      iconColor: Color(0xFF10b981),
                      mangaList: _recentManga.take(6).toList(),
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
                  _allManga.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.library_books_outlined,
                                  size: 64,
                                  color: Color(0xFF06b6d4).withOpacity(0.5),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Chưa có truyện nào',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hãy thêm truyện mới bằng nút + bên dưới',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
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
                    builder: (context) => upload.UploadMangaScreen(),
                  ),
                );
              },
              backgroundColor: Colors.cyan,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

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
                      manga.coverImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Color(0xFF1e293b),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Color(0xFF1e293b),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Color(0xFF06b6d4).withOpacity(0.5),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Manga Cover',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
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
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
