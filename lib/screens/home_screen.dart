import 'package:flutter/material.dart';
import 'dart:async';
import '../models/manga.dart';
import '../services/firestore_service.dart';
import 'upload_manga_with_chapters_screen.dart';
import 'search_results_screen.dart';
import '../utils/time_utils.dart';

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

  List<String> _selectedGenres = [];
  bool _showGenreFilter = false;
  List<String> _availableGenres = [
    'Action', 'Romance', 'Comedy', 'Fantasy', 'Slice of Life',
    'Horror', 'Sci-Fi', 'Mystery', 'Drama', 'Adventure',
    'Manga', 'Manhwa', 'Manhua', 'Martial Arts', 'Magic',
    'Thriller', 'Friendship'
  ];
  StreamSubscription? _mangaStreamSubscription;
  StreamSubscription? _hotMangaStreamSubscription;

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
    _mangaStreamSubscription?.cancel();
    _hotMangaStreamSubscription?.cancel();
    super.dispose();
  }

  void _loadMangaFromFirestore() {
    _mangaStreamSubscription =
        _firestoreService.getMangaStream().listen((mangaList) {
      if (!mounted) return;
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
            return b.chapters.first.releaseDate
                .compareTo(a.chapters.first.releaseDate);
          })
          ..take(10).toList();
      });
    });

    _hotMangaStreamSubscription =
        _firestoreService.getHotMangaStream(limit: 10).listen((hotList) {
      if (!mounted) return;
      setState(() {
        _hotManga = hotList;
      });
    });
  }
  
  List<Manga> _applyGenreFilter(List<Manga> mangaList) {
    if (_selectedGenres.isEmpty) {
      return mangaList;
    }
    return mangaList.where((manga) {
      // Kiểm tra xem manga có chứa ít nhất một genre được chọn không
      return manga.genres.any((genre) => _selectedGenres.contains(genre));
    }).toList();
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
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            searchQuery: query,
            allManga: _allManga,
          ),
        ),
      );
      _searchController.clear();
    }
  }
  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
      // áp dụng filter lại
      _filteredManga = _applyGenreFilter(_allManga);
      _featuredManga = List.from(_filteredManga)
        ..sort((a, b) => b.rating.compareTo(a.rating))
        ..take(6).toList();
      _recentManga = List.from(_filteredManga)
        ..sort((a, b) {
          if (a.chapters.isEmpty) return 1;
          if (b.chapters.isEmpty) return -1;
          return b.chapters.first.releaseDate
              .compareTo(a.chapters.first.releaseDate);
        })
        ..take(10).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Color(0xFF06b6d4)),
            SizedBox(width: 8),
            Text(
              'Lory',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: Theme.of(context).appBarTheme.foregroundColor),
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu từ Firebase...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar (Fake - tap to open full search)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultsScreen(
                              searchQuery: '',
                              allManga:
                                  _allManga, // Pass all manga to search screen
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.grey)
                                  .withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Color(0xFF06b6d4),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tìm kiếm truyện tranh...',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.4),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: _selectedGenres.map((genre) {
                              return Chip(
                                label: Text(genre),
                                onDeleted: () => _toggleGenre(genre),
                                backgroundColor: Color(0xFF06b6d4),
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                deleteIconColor: Colors.white,
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(width: 8),
                        FilterButton(
                          isActive: _showGenreFilter,
                          onPressed: () {
                            setState(() {
                              _showGenreFilter = !_showGenreFilter;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_showGenreFilter)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn Thể Loại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableGenres.map((genre) {
                                final isSelected =
                                    _selectedGenres.contains(genre);
                                return FilterChip(
                                  label: Text(genre),
                                  selected: isSelected,
                                  onSelected: (_) => _toggleGenre(genre),
                                  backgroundColor: Colors.transparent,
                                  selectedColor:
                                      Color(0xFF06b6d4).withAlpha(77),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Color(0xFF06b6d4)
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Color(0xFF06b6d4)
                                        : Colors.transparent,
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedGenres.clear();
                                      _filteredManga =
                                          _applyGenreFilter(_allManga);
                                      _showGenreFilter = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Xóa Bộ Lọc'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showGenreFilter = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF06b6d4),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Áp Dụng'),
                                ),
                              ],
                            ),
                          ],
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
                          final manga2 =
                              _featuredManga[(baseIndex + 1) % actualItemCount];

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
                                      margin: EdgeInsets.only(
                                          right: mangasInPage.last == manga
                                              ? 0
                                              : 8),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              manga.coverImage,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Theme.of(context)
                                                      .cardTheme
                                                      .color,
                                                  child: Icon(
                                                    Icons.image_outlined,
                                                    size: 48,
                                                    color: Color(0xFF06b6d4)
                                                        .withOpacity(0.5),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  manga.title,
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // ✅ Banner text luôn trắng vì nền tối
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star,
                                                        color:
                                                            Color(0xFFfbbf24),
                                                        size: 12),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      manga.rating
                                                          .toStringAsFixed(1),
                                                      style: TextStyle(
                                                        color: Colors
                                                            .white, // ✅ Banner text luôn trắng
                                                        fontSize: 12,
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
                                : (isDark
                                    ? Colors.white24
                                    : Colors.black26), // ✅ Sửa
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
                        Icon(Icons.library_books,
                            color: Color(0xFF06b6d4), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Toàn Bộ Truyện',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${_allManga.length} truyện',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
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
                                  color: isDark
                                      ? Color(0xFF06b6d4).withOpacity(0.5)
                                      : Color(0xFF06b6d4)
                                          .withOpacity(0.3), // ✅ Sửa
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _selectedGenres.isEmpty
                                      ? 'Chưa có truyện nào'
                                      : 'Không có truyện nào với thể loại đã chọn',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hãy thêm truyện mới bằng nút + bên dưới',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _allManga.length,
                          itemBuilder: (context, index) {
                            final manga = _allManga[index];
                            return _buildMangaCard(manga);
                          },
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
                    builder: (context) => UploadMangaWithChaptersScreen(),
                  ),
                );
              },
              backgroundColor: Color(0xFF06b6d4),
              child:
                  Icon(Icons.add, color: Colors.white), // ✅ FAB icon luôn trắng
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: Theme.of(context).cardTheme.color,
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
                          color: Theme.of(context).cardTheme.color,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF06b6d4)),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).cardTheme.color,
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF06b6d4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          TimeUtils.formatFromString(
                              manga.chapters.first.releaseDate),
                          style: TextStyle(
                            color: Colors
                                .white, // ✅ Badge text luôn trắng trên nền cyan
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
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                        manga.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color:
                            isDark ? Colors.white54 : Colors.black54, // ✅ Sửa
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${manga.views ~/ 1000}K',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: manga.genres.take(2).map((genre) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
class FilterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFF06b6d4).withAlpha(51) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Color(0xFF06b6d4) : Colors.grey.shade600,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.tune,
          color: isActive ? Color(0xFF06b6d4) : Colors.grey.shade600,
          size: 24,
        ),
      ),
    );
  }
}
