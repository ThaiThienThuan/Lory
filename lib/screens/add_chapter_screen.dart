//import 'dart:io';
import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AddChapterScreen extends StatefulWidget {
  final String mangaId;
  final String mangaTitle;

  const AddChapterScreen({
    super.key,
    required this.mangaId,
    required this.mangaTitle,
  });

  @override
  State<AddChapterScreen> createState() => _AddChapterScreenState();
}

class _AddChapterScreenState extends State<AddChapterScreen> {
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  final TextEditingController _chapterTitleController = TextEditingController();
  final TextEditingController _chapterNumberController =
      TextEditingController();

  List<String> _currentChapterPages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _chapterTitleController.dispose();
    _chapterNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Sửa
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ Sửa
        elevation: 0,
        title: Text(
          'Thêm Chương - ${widget.mangaTitle}',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor, // ✅ Sửa
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveChapter,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: Color(0xFF06b6d4),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thông tin chương
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color, // ✅ Sửa
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF06b6d4).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin chương',
                  style: TextStyle(
                    color: Color(0xFF06b6d4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _chapterNumberController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color, // ✅ Sửa
                  ),
                  decoration: InputDecoration(
                    labelText: 'Số chương *',
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color, // ✅ Sửa
                    ),
                    hintText: 'Ví dụ: 1',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5), // ✅ Sửa
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).scaffoldBackgroundColor, // ✅ Sửa
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF06b6d4),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _chapterTitleController,
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color, // ✅ Sửa
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề chương *',
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color, // ✅ Sửa
                    ),
                    hintText: 'Ví dụ: Khởi đầu cuộc phiêu lưu',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5), // ✅ Sửa
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).scaffoldBackgroundColor, // ✅ Sửa
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF06b6d4),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Trang chương
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color, // ✅ Sửa
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF06b6d4).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trang chương',
                      style: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_currentChapterPages.length} trang',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7), // ✅ Sửa
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickChapterImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Chọn ảnh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .scaffoldBackgroundColor, // ✅ Sửa
                          foregroundColor: Color(0xFF06b6d4),
                          disabledBackgroundColor: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.5), // ✅ Thêm
                          side: BorderSide(
                            color: Color(0xFF06b6d4).withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _addChapterPageUrl,
                        icon: const Icon(Icons.link),
                        label: const Text('Thêm URL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF06b6d4),
                          side: const BorderSide(color: Color(0xFF06b6d4)),
                          disabledForegroundColor:
                              Color(0xFF06b6d4).withOpacity(0.5), // ✅ Thêm
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_uploadProgress > 0 && _uploadProgress < 1)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor, // ✅ Sửa
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF06b6d4)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đang tải lên... ${(_uploadProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7), // ✅ Sửa
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                if (_currentChapterPages.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _currentChapterPages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor, // ✅ Sửa
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFF06b6d4).withOpacity(0.3),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _currentChapterPages[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.5), // ✅ Sửa
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentChapterPages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Chưa thêm trang nào',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.5), // ✅ Sửa
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickChapterImages() async {
    try {
      final images = await _storageService.pickMultipleImages();
      if (images.isEmpty) return;

      setState(() {
        _uploadProgress = 0.0;
        _isUploading = true;
      });

      List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
        try {
          final url = await _storageService.uploadChapterPage(
            images[i].path,
            widget.mangaId,
            'chapter_page_${i + 1}',
          );

          if (url != null) {
            uploadedUrls.add(url);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Lỗi upload trang ${i + 1}: $e')),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        setState(() {
          _uploadProgress = (i + 1) / images.length;
        });
      }

      setState(() {
        _currentChapterPages.addAll(uploadedUrls);
        _uploadProgress = 0.0;
        _isUploading = false;
      });

      if (uploadedUrls.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Đã thêm ${uploadedUrls.length} trang'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Lỗi khi chọn ảnh: $e')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addChapterPageUrl() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor, // ✅ Sửa
        title: Text(
          'Thêm URL Trang',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color, // ✅ Sửa
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color, // ✅ Sửa
          ),
          decoration: InputDecoration(
            hintText: 'Nhập URL ảnh trang',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.5), // ✅ Sửa
            ),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Sửa
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black54, // ✅ Sửa
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF06b6d4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentChapterPages.add(result);
      });
    }
  }

  Future<void> _saveChapter() async {
    if (_chapterNumberController.text.isEmpty ||
        _chapterTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Vui lòng nhập số chương và tiêu đề')),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final chapterNumber = int.tryParse(_chapterNumberController.text.trim());
    if (chapterNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Số chương phải là một số hợp lệ')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentChapterPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Vui lòng thêm ít nhất 1 trang')),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final chapter = Chapter(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            chapterNumber.toString(),
        title: _chapterTitleController.text.trim(),
        number: chapterNumber,
        releaseDate: DateTime.now().toIso8601String(),
        pages: List<String>.from(_currentChapterPages),
        isRead: false,
        likes: 0,
        isLiked: false,
        comments: [],
      );

      await _firestoreService.addChapterToManga(widget.mangaId, chapter);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Đã lưu chương thành công!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi khi lưu chương: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
