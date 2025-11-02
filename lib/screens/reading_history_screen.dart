import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/manga.dart';
import 'dart:developer' as developer;

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _readingHistory = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadReadingHistory();
  }

  Future<void> _loadReadingHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        developer.log('[v0] User not logged in', name: 'ReadingHistoryScreen');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _userId = userId;

      // Get reading sessions
      final sessions = await _firestoreService.getUserReadingHistory(userId);

      developer.log('[v0] Raw sessions count: ${sessions.length}',
          name: 'ReadingHistoryScreen');

      // Group by manga and get latest chapter per manga
      final Map<String, Map<String, dynamic>> groupedByManga = {};

      for (var session in sessions) {
        try {
          // ✅ NULL-SAFE casting
          final mangaId = session['mangaId'] as String?;
          final mangaTitle = session['mangaTitle'] as String?;
          final chapterTitle = session['chapterTitle'] as String?;
          final timestamp = session['timestamp'] as String?;

          // ✅ Skip nếu thiếu data quan trọng
          if (mangaId == null || timestamp == null) {
            developer.log(
              '[v0] Skipping session with null mangaId or timestamp',
              name: 'ReadingHistoryScreen',
            );
            continue;
          }

          // ✅ Store with null-safe data
          if (!groupedByManga.containsKey(mangaId) ||
              timestamp.compareTo(
                      groupedByManga[mangaId]!['timestamp'] as String) >
                  0) {
            groupedByManga[mangaId] = {
              'mangaId': mangaId,
              'mangaTitle': mangaTitle ?? 'Unknown',
              'chapterTitle': chapterTitle ?? 'Unknown',
              'timestamp': timestamp,
              'chapterId': session['chapterId'] as String? ?? '',
            };
          }
        } catch (e) {
          developer.log('[v0] Error processing session: $e',
              name: 'ReadingHistoryScreen');
          continue;
        }
      }

      // Convert to list and sort by timestamp
      final historyList = groupedByManga.values.toList()
        ..sort((a, b) {
          final aTime = a['timestamp'] as String? ?? '';
          final bTime = b['timestamp'] as String? ?? '';
          return bTime.compareTo(aTime);
        });

      setState(() {
        _readingHistory = historyList;
        _isLoading = false;
      });

      developer.log(
        '[v0] Loaded ${historyList.length} manga from history',
        name: 'ReadingHistoryScreen',
      );
    } catch (e) {
      developer.log('[v0] Lỗi load history: $e', name: 'ReadingHistoryScreen');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Không thể tải lịch sử: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'Xóa lịch sử đọc?',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa toàn bộ lịch sử đọc?',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // TODO: Implement clear all reading history in FirestoreService
      setState(() {
        _readingHistory.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Đã xóa lịch sử đọc'),
            ],
          ),
          backgroundColor: Color(0xFF10b981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Lỗi khi xóa lịch sử'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Lịch sử đọc',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          if (_readingHistory.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              tooltip: 'Xóa tất cả',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF06b6d4)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải lịch sử...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : _readingHistory.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReadingHistory,
                  color: Color(0xFF06b6d4),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _readingHistory.length,
                    itemBuilder: (context, index) {
                      final session = _readingHistory[index];
                      return _buildHistoryItem(session, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFF06b6d4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 80,
              color: Color(0xFF06b6d4),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Chưa có lịch sử đọc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Bắt đầu đọc truyện để xem lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to home/browse
            },
            icon: Icon(Icons.explore, color: Colors.white),
            label: Text(
              'Khám phá truyện',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF06b6d4),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> session, bool isDark) {
    final mangaTitle = session['mangaTitle'] as String? ?? 'Unknown';
    final chapterTitle = session['chapterTitle'] as String? ?? 'Unknown';
    final timestamp = session['timestamp'] as String;
    final mangaId = session['mangaId'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Navigate to manga detail
            try {
              final manga = await _firestoreService.getMangaById(mangaId);
              if (manga != null && mounted) {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: manga,
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không thể mở truyện'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mangaTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        chapterTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF06b6d4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
