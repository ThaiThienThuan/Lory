import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../services/firestore_service.dart';
import 'add_chapter_screen.dart';
import 'dart:developer' as developer;

class EditMangaScreen extends StatefulWidget {
  final Manga manga;

  const EditMangaScreen({Key? key, required this.manga}) : super(key: key);

  @override
  State<EditMangaScreen> createState() => _EditMangaScreenState();
}

class _EditMangaScreenState extends State<EditMangaScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _authorController;

  late String _selectedStatus;
  late List<String> _selectedGenres;

  bool _isLoading = false;

  final List<String> _statusOptions = ['Đang ra', 'Hoàn thành', 'Tạm dừng'];
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
    'Supernatural',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.manga.title);
    _descriptionController =
        TextEditingController(text: widget.manga.description);
    _authorController = TextEditingController(text: widget.manga.author);
    _selectedStatus = widget.manga.status;
    _selectedGenres = List.from(widget.manga.genres);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Vui lòng chọn ít nhất 1 thể loại'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updates = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'author': _authorController.text.trim(),
        'status': _selectedStatus,
        'genres': _selectedGenres,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final success = await _firestoreService.updateManga(
        widget.manga.id,
        updates,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Đã cập nhật truyện'),
              ],
            ),
            backgroundColor: Color(0xFF10b981),
          ),
        );

        // Go back
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật truyện'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      developer.log('[v0] Update error: $e', name: 'EditMangaScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa truyện',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Cover Image Preview
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.manga.coverImage,
                  width: 150,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 220,
                      color: Color(0xFF06b6d4).withOpacity(0.1),
                      child: Icon(
                        Icons.broken_image,
                        color: Color(0xFF06b6d4),
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Ảnh bìa không thể thay đổi',
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
            SizedBox(height: 24),

            // Title
            Text(
              'Tiêu đề',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập tiêu đề truyện',
                prefixIcon: Icon(Icons.book, color: Color(0xFF06b6d4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Author
            Text(
              'Tác giả',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _authorController,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập tên tác giả',
                prefixIcon: Icon(Icons.person, color: Color(0xFF06b6d4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên tác giả';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Description
            Text(
              'Mô tả',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập mô tả truyện',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mô tả';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Status
            Text(
              'Trạng thái',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // Genres
            Text(
              'Thể loại',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableGenres.map((genre) {
                final isSelected = _selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                  selectedColor: Color(0xFF06b6d4).withOpacity(0.3),
                  checkmarkColor: Color(0xFF06b6d4),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Color(0xFF06b6d4)
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddChapterScreen(
                      mangaId: widget.manga.id,
                      mangaTitle: widget.manga.title,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Thêm chương',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF10b981),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveChanges,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.check, color: Colors.white),
              label: Text(
                _isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
