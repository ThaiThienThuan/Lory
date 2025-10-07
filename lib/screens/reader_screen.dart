import 'package:flutter/material.dart';
import '../models/manga.dart';

class ReaderScreen extends StatefulWidget {
  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool showControls = true;
  bool showFloatingButtons = false;
  bool isLiked = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Lắng nghe scroll để hiển thị/ẩn nút nổi
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Xử lý sự kiện scroll
  void _onScroll() {
    final position = _scrollController.position;
    final isMiddle = position.pixels > 200 && 
                     position.pixels < position.maxScrollExtent - 200;
    
    if (isMiddle != showFloatingButtons) {
      setState(() {
        showFloatingButtons = isMiddle;
      });
    }

    // Tính trang hiện tại dựa trên vị trí scroll
    final pageHeight = MediaQuery.of(context).size.height;
    final newPage = (position.pixels / pageHeight).floor();
    if (newPage != currentPage) {
      setState(() {
        currentPage = newPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Manga manga = args['manga'];
    final Chapter chapter = args['chapter'];

    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar
              SliverAppBar(
                pinned: true,
                backgroundColor: Color(0xFF1e293b),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Chương ${chapter.number}: ${chapter.title}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.list, color: Colors.white),
                    onPressed: () => _showChapterSelector(manga, chapter),
                  ),
                ],
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          showControls = !showControls;
                        });
                      },
                      child: Container(
                        color: Colors.black,
                        child: Image.network(
                          chapter.pages[index],
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                  childCount: chapter.pages.length,
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Color(0xFF1e293b),
                  child: Column(
                    children: [
                      Text(
                        'Đã đọc xong chương ${chapter.number}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _navigateToPreviousChapter(manga, chapter),
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              label: Text('Chương trước', style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white38),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToNextChapter(manga, chapter),
                              icon: Icon(Icons.arrow_forward, color: Colors.white),
                              label: Text('Chương tiếp', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF06b6d4),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showChapterSelector(manga, chapter),
                        icon: Icon(Icons.list, color: Color(0xFF06b6d4)),
                        label: Text('Chọn chương', style: TextStyle(color: Color(0xFF06b6d4))),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF06b6d4)),
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (showFloatingButtons)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height / 2 - 80,
              child: Column(
                children: [
                  // Nút like
                  FloatingActionButton(
                    heroTag: 'like',
                    mini: true,
                    backgroundColor: Color(0xFF1e293b),
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isLiked ? 'Đã thích chương này' : 'Đã bỏ thích'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Color(0xFFec4899) : Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Nút comment
                  FloatingActionButton(
                    heroTag: 'comment',
                    mini: true,
                    backgroundColor: Color(0xFF1e293b),
                    onPressed: () => _showChapterComments(chapter),
                    child: Icon(Icons.comment, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  // Nút về đầu
                  FloatingActionButton(
                    heroTag: 'top',
                    mini: true,
                    backgroundColor: Color(0xFF1e293b),
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ],
              ),
            ),

          // Chỉ báo trang
          if (showControls)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentPage + 1} / ${chapter.pages.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Hiển thị bộ chọn chương
  void _showChapterSelector(Manga manga, Chapter currentChapter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách chương',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: manga.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = manga.chapters[index];
                    final isCurrent = chapter.id == currentChapter.id;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? Color(0xFF06b6d4).withOpacity(0.2) : Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrent ? Border.all(color: Color(0xFF06b6d4)) : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrent 
                                ? Color(0xFF06b6d4)
                                : chapter.isRead 
                                    ? Color(0xFF10b981).withOpacity(0.2)
                                    : Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              chapter.number.toString(),
                              style: TextStyle(
                                color: isCurrent || chapter.isRead ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          chapter.releaseDate,
                          style: TextStyle(color: Colors.white54),
                        ),
                        trailing: chapter.isRead
                            ? Icon(Icons.check_circle, color: Color(0xFF10b981))
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (!isCurrent) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/reader',
                              arguments: {
                                'manga': manga,
                                'chapter': chapter,
                              },
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hiển thị bình luận chương
  void _showChapterComments(Chapter chapter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1e293b),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bình luận chương ${chapter.number}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: chapter.comments.isEmpty
                        ? Center(
                            child: Text(
                              'Chưa có bình luận nào cho chương này',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: chapter.comments.length,
                            itemBuilder: (context, index) {
                              final comment = chapter.comments[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF0f172a),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: NetworkImage(comment.userAvatar),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          comment.userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      comment.content,
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                    icon: Icon(Icons.add_comment, color: Colors.white),
                    label: Text('Thêm bình luận', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF06b6d4),
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Chuyển chương trước
  void _navigateToPreviousChapter(Manga manga, Chapter currentChapter) {
    final currentIndex = manga.chapters.indexWhere((c) => c.id == currentChapter.id);
    if (currentIndex > 0) {
      Navigator.pushReplacementNamed(
        context,
        '/reader',
        arguments: {
          'manga': manga,
          'chapter': manga.chapters[currentIndex - 1],
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đây là chương đầu tiên')),
      );
    }
  }

  // Chuyển chương tiếp
  void _navigateToNextChapter(Manga manga, Chapter currentChapter) {
    final currentIndex = manga.chapters.indexWhere((c) => c.id == currentChapter.id);
    if (currentIndex < manga.chapters.length - 1) {
      Navigator.pushReplacementNamed(
        context,
        '/reader',
        arguments: {
          'manga': manga,
          'chapter': manga.chapters[currentIndex + 1],
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đây là chương mới nhất')),
      );
    }
  }
}