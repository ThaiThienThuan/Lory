import 'package:flutter/material.dart';
import 'package:lory/utils/time_utils.dart';
import '../models/manga.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final List<Manga> allManga;

  const SearchResultsScreen({
    required this.searchQuery,
    required this.allManga,
  });

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  late List<Manga> _filteredManga;
  final ScrollController _scrollController = ScrollController();
  int _displayedMangaCount = 12;

   //: Filter states
  String _searchType = 'title'; // 'title', 'author', 'all'
  Set<String> _selectedGenres = {}; // Thay từ String? sang Set<String> để hỗ trợ multi-select
  String _sortBy = 'relevance'; // 'relevance', 'rating', 'views', 'latest'

   //: Genre list (không dùng mock_data)
  final List<String> _availableGenres = [
    'Action',
    'Romance',
    'Comedy',
    'Fantasy',
    'Slice of Life',
    'Horror',
    'Sci-Fi',
    'Mystery',
    'Drama',
    'Adventure',
    'Manga',
    'Manhwa',
    'Manhua',
    'Martial Arts',
    'Magic',
    'Thriller',
    'Friendship',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _filteredManga = _filterManga(widget.searchQuery);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ UPDATED: Advanced filter logic
  List<Manga> _filterManga(String query) {
    List<Manga> results = widget.allManga;

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase().trim();

      results = results.where((manga) {
        switch (_searchType) {
          case 'title':
            return manga.title.toLowerCase().contains(lowerQuery);
          case 'author':
            return manga.author.toLowerCase().contains(lowerQuery);
          case 'all':
          default:
            return manga.title.toLowerCase().contains(lowerQuery) ||
                manga.author.toLowerCase().contains(lowerQuery);
        }
      }).toList();
    }

    if (_selectedGenres.isNotEmpty) {
      results = results.where((manga) {
        // Manga phải chứa ít nhất một thể loại được chọn
        return manga.genres.any((genre) => _selectedGenres.contains(genre));
      }).toList();
    }

    // Sort results
    switch (_sortBy) {
      case 'rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'views':
        results.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'latest':
        // Sort by newest manga (if you have createdAt field)
        // results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'relevance':
      default:
        // Keep original order
        break;
    }

    return results;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredManga = _filterManga(query);
      _displayedMangaCount = 12;
    });
  }

  void _onFilterChanged() {
    setState(() {
      _filteredManga = _filterManga(_searchController.text);
      _displayedMangaCount = 12;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_displayedMangaCount < _filteredManga.length) {
        setState(() {
          _displayedMangaCount =
              (_displayedMangaCount + 12).clamp(0, _filteredManga.length);
        });
      }
    }
  }

  void _showGenreSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chọn thể loại',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Clear all button
                    if (_selectedGenres.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedGenres.clear();
                          });
                        },
                        child: Text(
                          'Xóa tất cả',
                          style: TextStyle(color: Color(0xFF06b6d4)),
                        ),
                      ),

                    // Genre list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _availableGenres.length,
                        itemBuilder: (context, index) {
                          final genre = _availableGenres[index];
                          final isSelected = _selectedGenres.contains(genre);

                          return CheckboxListTile(
                            title: Text(
                              genre,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                            value: isSelected,
                            activeColor: Color(0xFF06b6d4),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedGenres.add(genre);
                                } else {
                                  _selectedGenres.remove(genre);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 12),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Hủy'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF06b6d4),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _onFilterChanged();
                          },
                          child: Text('Áp dụng'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tìm Kiếm Nâng Cao',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ Search input
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: _searchType == 'title'
                    ? 'Tìm theo tên truyện...'
                    : _searchType == 'author'
                        ? 'Tìm theo tác giả...'
                        : 'Tìm kiếm...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha(102),
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF06b6d4)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withAlpha(128),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
            ),
          ),

          // ✅ Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Search type filter
                _buildFilterChip(
                  label: 'Tiêu đề',
                  selected: _searchType == 'title',
                  onTap: () {
                    setState(() {
                      _searchType = 'title';
                      _onFilterChanged();
                    });
                  },
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Tác giả',
                  selected: _searchType == 'author',
                  onTap: () {
                    setState(() {
                      _searchType = 'author';
                      _onFilterChanged();
                    });
                  },
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Tất cả',
                  selected: _searchType == 'all',
                  onTap: () {
                    setState(() {
                      _searchType = 'all';
                      _onFilterChanged();
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedGenres.isNotEmpty
                          ? Color(0xFF06b6d4)
                          : Theme.of(context).cardTheme.color,
                      foregroundColor: _selectedGenres.isNotEmpty
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _selectedGenres.isNotEmpty
                              ? Color(0xFF06b6d4)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    onPressed: _showGenreSelector,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 18),
                        SizedBox(width: 8),
                        Text(
                          _selectedGenres.isEmpty
                              ? 'Thể loại'
                              : '${_selectedGenres.length} thể loại',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Sort button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.sort, color: Color(0xFF06b6d4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      setState(() {
                        _sortBy = value;
                        _onFilterChanged();
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'relevance',
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 18,
                              color: _sortBy == 'relevance'
                                  ? Color(0xFF06b6d4)
                                  : Theme.of(context).iconTheme.color,
                            ),
                            SizedBox(width: 12),
                            Text('Liên quan'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rating',
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rate,
                              size: 18,
                              color: _sortBy == 'rating'
                                  ? Color(0xFF06b6d4)
                                  : Theme.of(context).iconTheme.color,
                            ),
                            SizedBox(width: 12),
                            Text('Đánh giá cao'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'views',
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 18,
                              color: _sortBy == 'views'
                                  ? Color(0xFF06b6d4)
                                  : Theme.of(context).iconTheme.color,
                            ),
                            SizedBox(width: 12),
                            Text('Xem nhiều'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tìm thấy ${_filteredManga.length} kết quả',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha(179),
                    fontSize: 14,
                  ),
                ),
                if (_selectedGenres.isNotEmpty) ...[
                  Text(' • ', style: TextStyle(color: Colors.grey)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _selectedGenres.map((genre) {
                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF06b6d4).withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF06b6d4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ✅ Grid results
          Expanded(
            child: _filteredManga.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Color(0xFF06b6d4).withAlpha(128),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy truyện nào',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(179),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hãy thử tìm kiếm với từ khóa khác',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(128),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount:
                        _displayedMangaCount.clamp(0, _filteredManga.length),
                    itemBuilder: (context, index) {
                      final manga = _filteredManga[index];
                      return _buildMangaCard(manga);
                    },
                  ),
          ),
          if (_displayedMangaCount < _filteredManga.length)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? Color(0xFF06b6d4) : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Color(0xFF06b6d4) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
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
              color: (isDark ? Colors.black : Colors.grey)
                  .withAlpha(77),
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
                                color: Color(0xFF06b6d4).withAlpha(128),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Manga Cover',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withAlpha(128),
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
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color,
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha(179),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: Theme.of(context)
                            .iconTheme
                            .color
                            ?.withAlpha(128),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${manga.views ~/ 1000}K',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha(179),
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
                          color: Color(0xFFec4899).withAlpha(51),
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
