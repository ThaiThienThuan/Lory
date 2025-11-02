import 'dart:io';
import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/mangadex_service.dart';

class UploadMangaWithChaptersScreen extends StatefulWidget {
  final String? mangaId;
  final String? mangaTitle;

  const UploadMangaWithChaptersScreen({
    super.key,
    this.mangaId,
    this.mangaTitle,
  });

  @override
  State<UploadMangaWithChaptersScreen> createState() =>
      _UploadMangaWithChaptersScreenState();
}

class _UploadMangaWithChaptersScreenState
    extends State<UploadMangaWithChaptersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _storageService = StorageService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _chapterTitleController = TextEditingController();
  final TextEditingController _chapterNumberController =
      TextEditingController();

  File? _selectedCoverImage;
  String? _uploadedCoverUrl;

  String _selectedStatus = 'Đang ra';
  final List<String> _selectedGenres = [];
  bool _isUploading = false;
  bool _isImporting = false;

  List<Map<String, dynamic>> _chapters = [];
  List<String> _currentChapterPages = [];
  bool _showChapterForm = false;
  double _uploadProgress = 0.0;

  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Thriller',
  ];

  final List<String> _statusOptions = ['Đang ra', 'Hoàn thành', 'Tạm dừng'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _chapterTitleController.dispose();
    _chapterNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Đăng Truyện & Chương',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
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
          else if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFec4899)),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _uploadManga,
              child: const Text(
                'Đăng',
                style: TextStyle(
                  color: Color(0xFF06b6d4),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF06b6d4).withOpacity(0.3)),
                ),
                child: _selectedCoverImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedCoverImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _uploadedCoverUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder.png',
                              image: _uploadedCoverUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              fadeInDuration: const Duration(milliseconds: 300),
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(context).cardTheme.color,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 64),
                                      SizedBox(height: 12),
                                      Text(
                                        'Không thể tải ảnh',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: _showImageSourceDialog,
                                        icon:
                                            const Icon(Icons.refresh, size: 16),
                                        label: const Text('Chọn ảnh khác'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF06b6d4),
                                          foregroundColor:
                                              Theme.of(context).cardTheme.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  color: Color(0xFF06b6d4), size: 64),
                              SizedBox(height: 12),
                              Text(
                                'Nhấn để thêm ảnh bìa',
                                style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Khuyến nghị: 300x400px',
                                style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.5),
                                    fontSize: 12),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Tên truyện *',
                labelStyle: const TextStyle(color: Color(0xFF06b6d4)),
                hintText: 'Nhập tên truyện',
                // ignore: deprecated_member_use
                hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.5)),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF06b6d4),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên truyện';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Tác giả *',
                labelStyle: const TextStyle(color: Color(0xFF06b6d4)),
                hintText: 'Nhập tên tác giả',
                // ignore: deprecated_member_use
                hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.5)),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  // ✅ THÊM
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  // ✅ THÊM
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF06b6d4),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên tác giả';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mô tả *',
                labelStyle: const TextStyle(color: Color(0xFF06b6d4)),
                hintText: 'Nhập mô tả về truyện',
                // ignore: deprecated_member_use
                hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.5)),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  // ✅ THÊM
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  // ✅ THÊM
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF06b6d4),
                    width: 2,
                  ),
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mô tả';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trạng thái',
                    style: TextStyle(
                      color: Color(0xFF06b6d4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    dropdownColor: Theme.of(context).cardTheme.color,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thể loại *',
                        style: TextStyle(
                          color: Color(0xFF06b6d4),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showGenreSelector,
                        icon: const Icon(Icons.add,
                            color: Color(0xFF06b6d4), size: 16),
                        label: const Text('Thêm',
                            style: TextStyle(color: Color(0xFF06b6d4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedGenres.isEmpty)
                    Text(
                      'Chưa chọn thể loại nào',
                      // ignore: deprecated_member_use
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.5)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedGenres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: Color(0xFF06b6d4).withOpacity(0.2),
                          labelStyle: const TextStyle(color: Color(0xFF06b6d4)),
                          deleteIcon: const Icon(Icons.close,
                              size: 16, color: Color(0xFF06b6d4)),
                          onDeleted: () {
                            setState(() {
                              _selectedGenres.remove(genre);
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFec4899).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chương',
                        style: TextStyle(
                          color: Color(0xFFec4899),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_chapters.length} chương',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_chapters.isEmpty)
                    Text(
                      'Chưa thêm chương nào (tùy chọn)',
                      style:
                          // ignore: deprecated_member_use
                          TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.5),
                              fontSize: 12),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = _chapters[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Chương ${chapter['number']}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      chapter['title'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${chapter['pages'].length} trang',
                                      style: TextStyle(
                                        // ignore: deprecated_member_use
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.5),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _chapters.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showChapterForm = !_showChapterForm;
                        if (!_showChapterForm) {
                          _chapterTitleController.clear();
                          _chapterNumberController.clear();
                          _currentChapterPages.clear();
                        }
                      });
                    },
                    icon: Icon(_showChapterForm ? Icons.close : Icons.add),
                    label: Text(_showChapterForm ? 'Hủy' : 'Thêm Chương'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFec4899),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_showChapterForm) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFec4899).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thêm Chương Mới',
                      style: TextStyle(
                        color: Color(0xFFec4899),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _chapterNumberController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        labelText: 'Số chương *',
                        labelStyle: const TextStyle(color: Color(0xFFec4899)),
                        hintText: 'Ví dụ: 1',
                        // ignore: deprecated_member_use
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5)),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white12
                                : Colors.black12, // ✅ THÊM
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          // ✅ THÊM
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // ✅ THÊM
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF06b6d4),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số chương';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Số chương phải là số';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _chapterTitleController,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề chương *',
                        labelStyle: const TextStyle(color: Color(0xFFec4899)),
                        hintText: 'Ví dụ: Khởi đầu cuộc phiêu lưu',
                        // ignore: deprecated_member_use
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.5)),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          // ✅ THÊM
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // ✅ THÊM
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF06b6d4),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tiêu đề chương';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickChapterImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Chọn ảnh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).cardTheme.color,
                              foregroundColor: Color(0xFFec4899),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addChapterPageUrl,
                            icon: const Icon(Icons.link),
                            label: const Text('Thêm URL'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFFec4899),
                              side: const BorderSide(color: Color(0xFFec4899)),
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
                                Theme.of(context).scaffoldBackgroundColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFec4899)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đang tải lên... ${(_uploadProgress * 100).toInt()}%',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                                fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    if (_currentChapterPages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentChapterPages.length} trang',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                                fontSize: 12),
                          ),
                          const SizedBox(height: 8),
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
                                      color: Theme.of(context).cardTheme.color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            Color(0xFFec4899).withOpacity(0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _currentChapterPages[index],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
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
                                        color:
                                            Theme.of(context).cardTheme.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
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
                                          color:
                                              Theme.of(context).cardTheme.color,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveChapter,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFec4899),
                                    foregroundColor:
                                        Theme.of(context).cardTheme.color,
                                  ),
                                  child: const Text('Lưu Chương'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showChapterForm = false;
                                      _chapterTitleController.clear();
                                      _chapterNumberController.clear();
                                      _currentChapterPages.clear();
                                      _uploadProgress = 0.0;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFFec4899),
                                    side: const BorderSide(
                                        color: Color(0xFFec4899)),
                                  ),
                                  child: const Text('Hủy'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          title: Text('Chọn Ảnh Bìa',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF06b6d4)),
                title: Text('Thư viện ảnh',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF06b6d4)),
                title: Text('Chụp ảnh',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Color(0xFF06b6d4)),
                title: Text('Nhập URL',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pop(context);
                  _showCoverUrlDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _storageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedCoverImage = image;
        _uploadedCoverUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chọn ảnh từ thư viện'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _storageService.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedCoverImage = image;
        _uploadedCoverUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chụp ảnh'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCoverUrlDialog() {
    final controller = TextEditingController(text: _uploadedCoverUrl ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark; // ✅ Thêm

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          title: Text(
            'URL Ảnh Bìa',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color, // ✅ Sửa - dùng titleLarge
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập URL ảnh bìa',
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontSize: 12,
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,

              // ✅ THÊM: Border cho tất cả states
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54, // ✅ Sửa
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.warning,
                              color: Colors.white), // ✅ Thêm icon
                          SizedBox(width: 12),
                          Text('Vui lòng nhập URL'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                setState(() {
                  _uploadedCoverUrl = url;
                  _selectedCoverImage = null;
                });
                Navigator.pop(context);

                // ✅ Thêm success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Đã cập nhật URL ảnh bìa'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06b6d4),
                foregroundColor: Colors.white, // ✅ Sửa - text phải trắng
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _showGenreSelector() {
    // ✅ Tạo temporary list để lưu selections trong dialog
    List<String> tempSelectedGenres = List.from(_selectedGenres);
    showDialog(
      context: context,
      builder: (context) {
        // ✅ Wrap với StatefulBuilder để update UI trong dialog
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn Thể Loại',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ✅ Hiển thị số thể loại đã chọn
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06b6d4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tempSelectedGenres.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableGenres.length,
                  itemBuilder: (context, index) {
                    final genre = _availableGenres[index];
                    final isSelected = tempSelectedGenres.contains(genre);

                    return CheckboxListTile(
                      title: Text(
                        genre,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      value: isSelected,
                      activeColor: const Color(0xFF06b6d4),
                      checkColor: Colors.white,

                      // ✅ Chỉ update dialog state, không đóng dialog
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedGenres.add(genre);
                          } else {
                            tempSelectedGenres.remove(genre);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                // ✅ Nút Clear All
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempSelectedGenres.clear();
                    });
                  },
                  child: Text(
                    'Xóa hết',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ),

                // ✅ Nút Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ),

                // ✅ Nút Done - Lưu selections
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedGenres.clear();
                      _selectedGenres.addAll(tempSelectedGenres);
                    });
                    Navigator.pop(context);

                    // ✅ Feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                                'Đã chọn ${tempSelectedGenres.length} thể loại'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06b6d4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xong'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickChapterImages() async {
    try {
      final images = await _storageService.pickMultipleImages();
      if (images.isEmpty) return;

      setState(() {
        _uploadProgress = 0.0;
      });

      List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
        try {
          final url = await _storageService.uploadChapterPage(
            images[i].path,
            'temp_manga',
            'chapter_page_${i + 1}',
          );

          if (url != null) {
            uploadedUrls.add(url);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi upload trang ${i + 1}: $e'),
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
      });

      if (uploadedUrls.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${uploadedUrls.length} trang'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addChapterPageUrl() async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark; // ✅ Thêm

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text(
          'Thêm URL Trang',
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .titleLarge
                ?.color, // ✅ Sửa - dùng titleLarge
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: 'Nhập URL ảnh trang',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,

            // ✅ THÊM: Borders cho tất cả states
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF06b6d4), // ✅ Cyan thay vì purple
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54, // ✅ Sửa
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim(); // ✅ Thêm trim()
              if (url.isEmpty) {
                // ✅ Thêm validation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Vui lòng nhập URL'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, url); // ✅ Return trimmed URL
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF06b6d4), // ✅ Sửa - dùng cyan thay vì purple
              foregroundColor: Colors.white, // ✅ Sửa - text màu trắng
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

      // ✅ Thêm success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Đã thêm trang mới'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _saveChapter() {
    if (_chapterNumberController.text.isEmpty ||
        _chapterTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số chương và tiêu đề'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final chapterNumber = int.tryParse(_chapterNumberController.text.trim());
    if (chapterNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số chương phải là một số hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentChapterPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 trang'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _chapters.add({
        'number': chapterNumber,
        'title': _chapterTitleController.text.trim(),
        'pages': List.from(_currentChapterPages),
      });
      _showChapterForm = false;
      _chapterTitleController.clear();
      _chapterNumberController.clear();
      _currentChapterPages.clear();
      _uploadProgress = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu chương'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _uploadManga() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCoverImage == null && _uploadedCoverUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ảnh bìa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một thể loại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Không thể xác định người dùng');
      }

      // ✅ Upload cover image
      String coverUrl;
      if (_selectedCoverImage != null) {
        final uploadedUrl = await _storageService.uploadMangaCover(
          _selectedCoverImage!,
          _titleController.text.trim(),
        );
        if (uploadedUrl == null) {
          throw Exception('Không thể tải ảnh lên');
        }
        coverUrl = uploadedUrl;
      } else {
        coverUrl = _uploadedCoverUrl!;
      }

      final manga = Manga(
        id: '',
        title: _titleController.text.trim(),
        coverImage: coverUrl,
        description: _descriptionController.text.trim(),
        genres: _selectedGenres,
        rating: 0.0,
        views: 0,
        author: _authorController.text.trim(),
        status: _selectedStatus,
        chapters: [],
        isFollowed: false,
        isLiked: false,
        totalRatings: 0,
        comments: [],
        uploaderId: userId, // ✅ MUST HAVE
      );

      final mangaId = await _firestoreService.addManga(manga);

      if (mangaId != null) {
        if (_chapters.isNotEmpty) {
          for (final chapterData in _chapters) {
            final chapterNumber = chapterData['number'] is int
                ? chapterData['number']
                : int.tryParse(chapterData['number'].toString()) ?? 0;

            final chapter = Chapter(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  chapterNumber.toString(),
              title: chapterData['title'],
              number: chapterNumber,
              releaseDate: DateTime.now().toIso8601String(),
              pages: List<String>.from(chapterData['pages']),
              isRead: false,
              likes: 0,
              isLiked: false,
              comments: [],
            );

            await _firestoreService.addChapterToManga(mangaId, chapter);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _chapters.isEmpty
                    ? 'Đã đăng truyện thành công!'
                    : 'Đã đăng truyện với ${_chapters.length} chương!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Không thể lưu truyện');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng truyện: $e'),
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
