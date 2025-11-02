import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/comment.dart';
//import 'add_chapter_screen.dart';
import '../utils/time_utils.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'dart:developer' as developer;

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  bool isFollowed = false;
  bool isLiked = false;
  double userRating = 0;
  late TabController _tabController;
  bool _isDescriptionExpanded = false; // ✅ THÊM

  final bool isTranslationGroup = true;
  final bool isAdmin = false;
  String? _currentUserId;
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();
  Manga? _updatedManga;

  Map<String, bool> _commentLikes = {};
  Map<String, int> _commentLikeCounts = {};

  /// Count total comments (including nested replies)
  int _getTotalCommentCount(List<Comment> comments) {
    int count = comments.length; // Root comments
    for (var comment in comments) {
      count +=
          _getTotalCommentCount(comment.replies); // Add replies recursively
    }

    return count;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUser();
    await _loadUserInteractions();
  }

  Future<void> _loadCurrentUser() async {
    final authService = AuthService();
    final userId = await authService.getUserId();
    setState(() {
      _currentUserId = userId;
      _isLoading = false;
    });
  }

  Future<void> _loadUserInteractions() async {
    if (_currentUserId == null) return;

    final Manga manga =
        ModalRoute.of(context)?.settings.arguments as Manga? ?? Manga.empty();

    if (manga.id.isEmpty) return;

    final interaction = await _firestoreService.getUserMangaInteraction(
      _currentUserId!,
      manga.id,
    );

    if (interaction != null && mounted) {
      setState(() {
        isLiked = interaction['liked'] ?? false;
        isFollowed = interaction['followed'] ?? false;
        userRating = (interaction['rating'] ?? 0).toDouble();
      });
    }
  }

  Future<void> _trackViewAndNavigateToReader(
      Manga manga, Chapter chapter) async {
    if (_currentUserId != null) {
      try {
        final success = await _firestoreService.trackReadingSession(
          _currentUserId!,
          manga.id,
          chapter.id,
        );
        developer.log(
          '[v0] Track view result: $success for chapter: ${chapter.title}',
          name: 'DetailScreen',
        );
      } catch (e) {
        developer.log('[v0] Lỗi khi track view: $e', name: 'DetailScreen');
      }
    }

    if (!mounted) return;

    await Navigator.pushNamed(
      context,
      '/reader',
      arguments: {
        'manga': manga,
        'chapter': chapter,
      },
    );

    await _reloadMangaData();
  }

  Future<void> _reloadMangaData() async {
    final Manga originalManga =
        ModalRoute.of(context)?.settings.arguments as Manga? ?? Manga.empty();

    if (originalManga.id.isEmpty) return;

    try {
      final updatedManga =
          await _firestoreService.getMangaById(originalManga.id);

      if (updatedManga != null && mounted) {
        setState(() {
          _updatedManga = updatedManga;
        });
        developer.log(
          '[v0] Đã reload manga data - Views: ${updatedManga.views}, Rating: ${updatedManga.rating}',
          name: 'DetailScreen',
        );
      }
    } catch (e) {
      developer.log('[v0] Lỗi khi reload manga data: $e', name: 'DetailScreen');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Manga originalManga =
        ModalRoute.of(context)!.settings.arguments as Manga;
    final Manga manga = _updatedManga ?? originalManga;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (userRating == 0 &&
        !isFollowed &&
        !isLiked &&
        manga.isFollowed == false &&
        manga.isLiked == false) {}

    final bool isUploader = !_isLoading &&
        _currentUserId != null &&
        manga.uploaderId != null &&
        _currentUserId == manga.uploaderId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ✅ HERO IMAGE với gradient overlay
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Theme.of(context).cardTheme.color,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chia sẻ truyện')),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    manga.coverImage,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Title overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manga.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            // Author badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    manga.author,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 12),

                            // Status badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(manga.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                manga.status,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
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

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ STATS BAR với card styling
                Container(
                  margin: EdgeInsets.all(16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        icon: Icons.star_rounded,
                        value: manga.rating.toStringAsFixed(1),
                        label: 'Đánh giá',
                        color: Color(0xFFfbbf24),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      _buildStatChip(
                        icon: Icons.visibility_rounded,
                        value: '${manga.views ~/ 1000}K',
                        label: 'Lượt xem',
                        color: Color(0xFF06b6d4),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      _buildStatChip(
                        icon: Icons.menu_book_rounded,
                        value: '${manga.chapters.length}',
                        label: 'Chương',
                        color: Color(0xFFec4899),
                      ),
                    ],
                  ),
                ),

                // ✅ ACTION BUTTONS - Redesigned
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Row 1: Đọc từ đầu & Đọc tiếp
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (manga.chapters.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Chưa có chương nào')),
                                  );
                                  return;
                                }
                                await _trackViewAndNavigateToReader(
                                    manga, manga.chapters.first);
                              },
                              icon: Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 24),
                              label: Text(
                                'Đọc từ đầu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF06b6d4),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (manga.chapters.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Chưa có chương nào')),
                                  );
                                  return;
                                }
                                final lastReadChapter =
                                    manga.chapters.firstWhere(
                                  (c) => c.isRead,
                                  orElse: () => manga.chapters.first,
                                );
                                await _trackViewAndNavigateToReader(
                                    manga, lastReadChapter);
                              },
                              icon: Icon(Icons.auto_stories_rounded,
                                  color: Colors.white, size: 24),
                              label: Text(
                                'Đọc tiếp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF10b981),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Row 2: Theo dõi & Yêu thích
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                if (_currentUserId != null) {
                                  await _firestoreService.toggleMangaFollow(
                                    _currentUserId!,
                                    manga.id,
                                    !isFollowed,
                                  );
                                }
                                setState(() {
                                  isFollowed = !isFollowed;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        isFollowed ? 'Đã lưu' : 'Đã bỏ lưu'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                isFollowed
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isFollowed
                                    ? Color(0xFF06b6d4)
                                    : Theme.of(context).iconTheme.color,
                                size: 22,
                              ),
                              label: Text(
                                isFollowed ? 'Đã lưu' : 'Lưu',
                                style: TextStyle(
                                  color: isFollowed
                                      ? Color(0xFF06b6d4)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isFollowed
                                      ? Color(0xFF06b6d4)
                                      : (isDark
                                          ? Colors.white24
                                          : Colors.black26),
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                if (_currentUserId != null) {
                                  await _firestoreService.toggleMangaLike(
                                    _currentUserId!,
                                    manga.id,
                                    !isLiked,
                                  );
                                  final updatedManga =
                                      manga.copyWith(isLiked: !isLiked);
                                  if (mounted) {
                                    setState(() {
                                      _updatedManga = updatedManga;
                                    });
                                  }
                                }
                                setState(() {
                                  isLiked = !isLiked;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isLiked ? 'Đã thích' : 'Đã bỏ thích',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Color(0xFFec4899)
                                    : Theme.of(context).iconTheme.color,
                                size: 22,
                              ),
                              label: Text(
                                isLiked ? 'Đã thích' : 'Yêu thích',
                                style: TextStyle(
                                  color: isLiked
                                      ? Color(0xFFec4899)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isLiked
                                      ? Color(0xFFec4899)
                                      : (isDark
                                          ? Colors.white24
                                          : Colors.black26),
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ✅ GENRES với horizontal scroll
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category_rounded,
                              color: Color(0xFF06b6d4), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Thể loại',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: manga.genres.map((genre) {
                            return Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF06b6d4),
                                    Color(0xFF0891b2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF06b6d4).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ✅ DESCRIPTION với expand/collapse
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(20),
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
                      Row(
                        children: [
                          Icon(Icons.description_rounded,
                              color: Color(0xFFec4899), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Mô tả',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        manga.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                        maxLines: _isDescriptionExpanded ? null : 4,
                        overflow: _isDescriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (manga.description.length > 150)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                                style: TextStyle(
                                  color: Color(0xFF06b6d4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                _isDescriptionExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Color(0xFF06b6d4),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ✅ RATING SECTION
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFfbbf24).withOpacity(0.1),
                        Color(0xFFf59e0b).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFfbbf24).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded,
                              color: Color(0xFFfbbf24), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Đánh giá của bạn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () async {
                              final rating = (index + 1).toDouble();
                              if (_currentUserId != null) {
                                await _firestoreService.saveMangaRating(
                                  _currentUserId!,
                                  manga.id,
                                  rating,
                                );
                                await _reloadMangaData();
                              }
                              setState(() {
                                userRating = rating;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã đánh giá ${index + 1} sao'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < userRating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Color(0xFFfbbf24),
                                size: 40,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (userRating > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Bạn đã đánh giá ${userRating.toInt()} sao',
                            style: TextStyle(
                              color: Color(0xFFfbbf24),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ✅ TABS với modern design
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
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
                      TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        padding: EdgeInsets.all(8),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list_alt_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Chương (${manga.chapters.length})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment_rounded, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Bình luận (${_getTotalCommentCount(manga.comments)})',
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 500,
                        padding: EdgeInsets.all(8),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildChapterList(manga),
                            _buildCommentList(manga),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  // ✅ STAT CHIP component
  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterList(Manga manga) {
    if (manga.chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có chương nào',
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: manga.chapters.length,
      itemBuilder: (context, index) {
        final chapter = manga.chapters[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: chapter.isRead
                ? Color(0xFF10b981).withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: chapter.isRead
                  ? Color(0xFF10b981).withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: chapter.isRead
                      ? [Color(0xFF10b981), Color(0xFF059669)]
                      : [Color(0xFF06b6d4), Color(0xFF0891b2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  chapter.number.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              chapter.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5)),
                  SizedBox(width: 4),
                  Text(
                    _formatChapterDate(chapter.releaseDate),
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: chapter.isRead
                    ? Color(0xFF10b981).withOpacity(0.1)
                    : Color(0xFF06b6d4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                chapter.isRead
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_rounded,
                color: chapter.isRead ? Color(0xFF10b981) : Color(0xFF06b6d4),
                size: 24,
              ),
            ),
            onTap: () async {
              await _trackViewAndNavigateToReader(manga, chapter);
            },
          ),
        );
      },
    );
  }

  Widget _buildCommentList(Manga manga) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showAddCommentDialog();
          },
          icon: Icon(Icons.add_comment_rounded, color: Colors.white, size: 20),
          label: Text(
            'Thêm bình luận',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF06b6d4),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: manga.comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 64,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có bình luận nào',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: manga.comments.length,
                  itemBuilder: (context, index) {
                    final comment = manga.comments[index];
                    return _buildCommentItem(comment);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment, {int level = 0}) {
    final isLiked = _commentLikes[comment.id] ?? comment.isLiked;
    final likeCount = _commentLikeCounts[comment.id] ?? comment.likes;
    final bool hasReplies = comment.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment card
        Container(
          margin: EdgeInsets.only(
            bottom: 8,
            left: level * 40.0, // ✅ Thụt vào theo level
          ),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: level == 0
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: level > 0
                ? Border.all(
                    color: Color(0xFF06b6d4).withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: level == 0 ? 20 : 16,
                    backgroundImage: NetworkImage(comment.userAvatar),
                    backgroundColor: Color(0xFF06b6d4),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: level == 0 ? 14 : 13,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          TimeUtils.formatTime(comment.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Comment content
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: level == 0 ? 14 : 13,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8),

              // Action buttons
              Row(
                children: [
                  // Like button
                  TextButton.icon(
                    onPressed: () async {
                      final AuthService authService = AuthService();
                      final userId = await authService.getUserId();

                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Bạn cần đăng nhập'),
                              ],
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _commentLikes[comment.id] = !isLiked;
                        _commentLikeCounts[comment.id] =
                            isLiked ? likeCount - 1 : likeCount + 1;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isLiked ? 'Đã bỏ thích' : 'Đã thích bình luận',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                      size: 14,
                      color: isLiked
                          ? Color(0xFFec4899)
                          : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                    ),
                    label: Text(
                      '$likeCount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // Reply button
                  TextButton.icon(
                    onPressed: () {
                      _showReplyDialog(comment);
                    },
                    icon: Icon(
                      Icons.reply_rounded,
                      size: 14,
                      color:
                          Theme.of(context).iconTheme.color?.withOpacity(0.5),
                    ),
                    label: Text(
                      'Trả lời',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // ✅ Show reply count
                  if (hasReplies)
                    Text(
                      '${comment.replies.length} trả lời',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // ✅ NESTED REPLIES (Recursive rendering)
        if (hasReplies && level < 3) // Max 3 levels
          ...comment.replies.map((reply) {
            return _buildCommentItem(reply, level: level + 1);
          }).toList(),
      ],
    );
  }

  void _showAddCommentDialog({String? initialText}) {
    final commentController = TextEditingController(text: initialText);

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
              Icon(Icons.comment_rounded, color: Color(0xFF06b6d4)),
              SizedBox(width: 12),
              Text(
                'Thêm bình luận',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: commentController,
            maxLines: 4,
            autofocus: true,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Nhập bình luận của bạn...',
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF06b6d4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
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
                final commentText = commentController.text.trim();

                // ✅ Validation
                if (commentText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Vui lòng nhập nội dung bình luận'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (_currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Bạn cần đăng nhập để bình luận'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Close dialog
                Navigator.pop(dialogContext);

                // ✅ Show loading
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
                        Text('Đang thêm bình luận...'),
                      ],
                    ),
                    duration: Duration(seconds: 10),
                    backgroundColor: Color(0xFF06b6d4),
                  ),
                );

                try {
                  // Get manga
                  final Manga originalManga =
                      ModalRoute.of(context)?.settings.arguments as Manga? ??
                          Manga.empty();
                  final Manga manga = _updatedManga ?? originalManga;

                  // Get user info
                  final authService = AuthService();
                  final userName =
                      await authService.getUserName() ?? 'Anonymous';
                  final userPhotoUrl = await authService.getUserPhotoUrl() ??
                      'https://ui-avatars.com/api/?name=${userName}';

                  // ✅ Create comment object
                  final newComment = Comment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: _currentUserId!,
                    userName: userName,
                    userAvatar: userPhotoUrl,
                    content: commentText,
                    createdAt: DateTime.now(),
                    likes: 0,
                    isLiked: false,
                  );

                  // ✅ Add comment to Firestore
                  final success = await _firestoreService.addCommentToManga(
                    manga.id,
                    newComment,
                  );

                  // Hide loading
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  if (success) {
                    // ✅ Reload manga data để cập nhật comments
                    await _reloadMangaData();

                    // Show success
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Đã thêm bình luận thành công!'),
                          ],
                        ),
                        backgroundColor: Color(0xFF10b981),
                      ),
                    );
                  } else {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Không thể thêm bình luận'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  // Hide loading
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  // Show error
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

                  developer.log('[v0] Lỗi khi thêm comment: $e',
                      name: 'DetailScreen');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Gửi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReplyDialog(Comment parentComment) {
    final replyController = TextEditingController();

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
              Icon(Icons.reply_rounded, color: Color(0xFF06b6d4)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Trả lời ${parentComment.userName}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show original comment
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
                    Text(
                      parentComment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF06b6d4),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      parentComment.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Reply input
              TextField(
                controller: replyController,
                maxLines: 4,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'Nhập câu trả lời của bạn...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF06b6d4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
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
                final replyText = replyController.text.trim();

                if (replyText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Vui lòng nhập nội dung'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // ✅ CHECK LOGIN INLINE - Không dùng currentUserId
                final AuthService authService = AuthService();
                final userId = await authService.getUserId();

                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Bạn cần đăng nhập'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                // ✅ Call nested reply method
                await _addNestedReply(parentComment, replyText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Gửi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Add nested reply to a comment
  Future<void> _addNestedReply(
    Comment parentComment,
    String replyText,
  ) async {
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
              Text('Đang thêm trả lời...'),
            ],
          ),
          duration: Duration(seconds: 10),
          backgroundColor: Color(0xFF06b6d4),
        ),
      );

      // Get user info
      final authService = AuthService();
      final userId = await authService.getUserId();
      final userName = await authService.getUserName() ?? 'Anonymous';
      final userPhotoUrl = await authService.getUserPhotoUrl() ??
          'https://ui-avatars.com/api/?name=$userName';

      if (userId == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn cần đăng nhập'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create reply comment
      final newReply = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        userAvatar: userPhotoUrl,
        content: replyText,
        createdAt: DateTime.now(),
        likes: 0,
        isLiked: false,
        parentId: parentComment.id, // ✅ Link to parent
        replies: [],
      );

      // Get current manga
      final Manga originalManga =
          ModalRoute.of(context)?.settings.arguments as Manga? ?? Manga.empty();
      final Manga manga = _updatedManga ?? originalManga;

      // ✅ Add reply to parent comment (recursive search)
      final updatedComments = _addReplyToComments(
        manga.comments,
        parentComment.id,
        newReply,
      );

      // Update manga in Firestore
      await _firestoreService.updateManga(manga.id, {
        'comments': updatedComments.map((c) => c.toJson()).toList(),
      });

      // Reload data
      await _reloadMangaData();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Đã thêm trả lời thành công!'),
            ],
          ),
          backgroundColor: Color(0xFF10b981),
        ),
      );

      developer.log('[v0] Added nested reply', name: 'DetailScreen');
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

      developer.log('[v0] Error adding reply: $e', name: 'DetailScreen');
    }
  }

  /// Helper: Recursively find parent comment and add reply
  List<Comment> _addReplyToComments(
    List<Comment> comments,
    String parentId,
    Comment newReply,
  ) {
    return comments.map((comment) {
      if (comment.id == parentId) {
        // Found parent - add reply
        return comment.copyWith(
          replies: [...comment.replies, newReply],
        );
      } else if (comment.replies.isNotEmpty) {
        // Search in nested replies
        return comment.copyWith(
          replies: _addReplyToComments(comment.replies, parentId, newReply),
        );
      }
      return comment;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang ra':
        return Color(0xFF10b981); // Green
      case 'Hoàn thành':
        return Color(0xFF06b6d4); // Blue
      case 'Tạm dừng':
        return Color(0xFFfbbf24); // Yellow
      default:
        return Color(0xFF6b7280); // Gray
    }
  }

  String _formatChapterDate(String releaseDate) {
    try {
      if (releaseDate.isEmpty) {
        return 'Chưa có ngày phát hành';
      }
      return TimeUtils.formatTime(DateTime.parse(releaseDate));
    } catch (e) {
      return 'Ngày không hợp lệ';
    }
  }
}
