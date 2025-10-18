import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/comment.dart';
//import 'add_chapter_screen.dart'; // Changed to relative import to match other imports in the file
import '../services/auth_service.dart';
import 'add_chapter_screen'; // Import AuthService

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key); // Added key parameter to fix constructor warning
  
  @override
  State<DetailScreen> createState() => _DetailScreenState(); // Fixed return type to use proper state class
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  bool isFollowed = false;
  bool isLiked = false;
  double userRating = 0;
  late TabController _tabController;
  
  final bool isTranslationGroup = true;
  final bool isAdmin = false;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authService = AuthService();
    final userId = await authService.getUserId();
    setState(() {
      _currentUserId = userId;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Manga manga = ModalRoute.of(context)!.settings.arguments as Manga;
    
    if (!isFollowed && !isLiked) {
      setState(() {
        isFollowed = manga.isFollowed;
        isLiked = manga.isLiked;
      });
    }

    final bool isUploader = !_isLoading && 
                           _currentUserId != null && 
                           manga.uploaderId != null && 
                           _currentUserId == manga.uploaderId;

    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Color(0xFF1e293b),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    manga.coverImage,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF0f172a),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chia sẻ truyện')),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tác giả: ${manga.author}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: manga.status == 'ongoing' 
                              ? Color(0xFF10b981).withOpacity(0.2)
                              : Color(0xFF06b6d4).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: manga.status == 'ongoing' 
                                ? Color(0xFF10b981)
                                : Color(0xFF06b6d4),
                          ),
                        ),
                        child: Text(
                          manga.status == 'ongoing' ? 'Đang ra' : 'Hoàn thành',
                          style: TextStyle(
                            color: manga.status == 'ongoing' 
                                ? Color(0xFF10b981)
                                : Color(0xFF06b6d4),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      _buildStatItem(Icons.star, '${manga.rating}', '(${manga.totalRatings} đánh giá)'),
                      SizedBox(width: 24),
                      _buildStatItem(Icons.visibility, '${manga.views ~/ 1000}K', 'lượt xem'),
                      SizedBox(width: 24),
                      _buildStatItem(Icons.menu_book, '${manga.chapters.length}', 'chương'),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final lastReadChapter = manga.chapters.firstWhere(
                              (c) => c.isRead,
                              orElse: () => manga.chapters.first,
                            );
                            Navigator.pushNamed(
                              context,
                              '/reader',
                              arguments: {
                                'manga': manga,
                                'chapter': lastReadChapter,
                              },
                            );
                          },
                          icon: Icon(Icons.play_arrow, color: Colors.white),
                          label: Text(
                            manga.chapters.any((c) => c.isRead) ? 'Đọc tiếp' : 'Đọc từ đầu',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF06b6d4),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              isFollowed = !isFollowed;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFollowed ? 'Đã theo dõi' : 'Đã bỏ theo dõi'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: Icon(
                            isFollowed ? Icons.check : Icons.add,
                            color: isFollowed ? Color(0xFF10b981) : Colors.white,
                          ),
                          label: Text(
                            isFollowed ? 'Đã theo dõi' : 'Theo dõi',
                            style: TextStyle(
                              color: isFollowed ? Color(0xFF10b981) : Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isFollowed ? Color(0xFF10b981) : Colors.white38,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Color(0xFFec4899) : Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xFF1e293b),
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Thể loại',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manga.genres.map((genre) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF06b6d4).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFF06b6d4)),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: Color(0xFF06b6d4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    manga.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),

                  SizedBox(height: 24),

                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đánh giá của bạn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  userRating = index + 1.0;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã đánh giá ${index + 1} sao'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                index < userRating ? Icons.star : Icons.star_border,
                                color: Color(0xFFfbbf24),
                                size: 32,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Color(0xFF06b6d4),
                      labelColor: Color(0xFF06b6d4),
                      unselectedLabelColor: Colors.white54,
                      tabs: [
                        Tab(text: 'Chương (${manga.chapters.length})'),
                        Tab(text: 'Bình luận (${manga.comments.length})'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 400,
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
          ),
        ],
      ),
      floatingActionButton: isUploader
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddChapterScreen(
                      mangaId: manga.id,
                      mangaTitle: manga.title,
                    ),
                  ),
                );
              },
              backgroundColor: Color(0xFF06b6d4),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Thêm chương',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFfbbf24), size: 20),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChapterList(Manga manga) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: manga.chapters.length,
      itemBuilder: (context, index) {
        final chapter = manga.chapters[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Color(0xFF1e293b),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: chapter.isRead 
                    ? Color(0xFF10b981).withOpacity(0.2)
                    : Color(0xFF06b6d4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  chapter.number.toString(),
                  style: TextStyle(
                    color: chapter.isRead ? Color(0xFF10b981) : Color(0xFF06b6d4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              chapter.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              chapter.releaseDate,
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
            trailing: chapter.isRead
                ? Icon(Icons.check_circle, color: Color(0xFF10b981))
                : Icon(Icons.play_circle_outline, color: Color(0xFF06b6d4)),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/reader',
                arguments: {
                  'manga': manga,
                  'chapter': chapter,
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCommentList(Manga manga) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddCommentDialog();
            },
            icon: Icon(Icons.add_comment, color: Colors.white),
            label: Text('Thêm bình luận', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF06b6d4),
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: manga.comments.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có bình luận nào',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
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

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(comment.userAvatar),
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: comment.isLiked ? Color(0xFFec4899) : Colors.white54,
                ),
                label: Text(
                  '${comment.likes}',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.reply, size: 16, color: Colors.white54),
                label: Text('Trả lời', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCommentDialog() {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1e293b),
          title: Text('Thêm bình luận', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: commentController,
            maxLines: 4,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nhập bình luận của bạn...',
              hintStyle: TextStyle(color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Color(0xFF0f172a),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã thêm bình luận')),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
              ),
              child: Text('Gửi', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
