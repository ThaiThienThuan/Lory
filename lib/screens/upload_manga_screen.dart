import 'package:flutter/material.dart';
import '../models/manga.dart';

// Màn hình đăng/chỉnh sửa truyện cho nhóm dịch và admin
class UploadMangaScreen extends StatefulWidget {
  final Manga? manga; // Null nếu đăng mới, có giá trị nếu chỉnh sửa

  const UploadMangaScreen({super.key, this.manga});

  @override
  State<UploadMangaScreen> createState() => _UploadMangaScreenState();
}

class _UploadMangaScreenState extends State<UploadMangaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  List<String> _selectedGenres = [];
  String _status = 'ongoing';
  String? _coverImageUrl;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers với dữ liệu hiện có nếu đang chỉnh sửa
    _titleController = TextEditingController(text: widget.manga?.title ?? '');
    _authorController = TextEditingController(text: widget.manga?.author ?? '');
    _descriptionController = TextEditingController(text: widget.manga?.description ?? '');
    _selectedGenres = widget.manga?.genres ?? [];
    _status = widget.manga?.status ?? 'ongoing';
    _coverImageUrl = widget.manga?.cover;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.manga != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: Text(
          isEditing ? 'Chỉnh Sửa Truyện' : 'Đăng Truyện Mới',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveManga,
            child: Text(
              isEditing ? 'Cập Nhật' : 'Đăng',
              style: const TextStyle(
                color: Colors.cyan,
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
            // Ảnh bìa
            GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: _coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _coverImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.cyan, size: 48),
                          const SizedBox(height: 8),
                          const Text(
                            'Chọn ảnh bìa',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Tên truyện
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tên truyện *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập tên truyện',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1e293b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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

            // Tác giả
            TextFormField(
              controller: _authorController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tác giả *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập tên tác giả',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1e293b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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

            // Mô tả
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mô tả *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập mô tả truyện',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1e293b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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

            // Thể loại
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thể loại *',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        backgroundColor: const Color(0xFF0f172a),
                        selectedColor: Colors.cyan.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.cyan : Colors.white70,
                        ),
                        checkmarkColor: Colors.cyan,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trạng thái
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trạng thái',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Đang ra', style: TextStyle(color: Colors.white)),
                          value: 'ongoing',
                          groupValue: _status,
                          activeColor: Colors.cyan,
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Hoàn thành', style: TextStyle(color: Colors.white)),
                          value: 'completed',
                          groupValue: _status,
                          activeColor: Colors.cyan,
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút thêm chương
            if (isEditing)
              ElevatedButton.icon(
                onPressed: _addChapter,
                icon: const Icon(Icons.add),
                label: const Text('Thêm Chương Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

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

  void _pickCoverImage() {
    // Trong thực tế, sẽ mở image picker
    // Ở đây chỉ demo với placeholder
    setState(() {
      _coverImageUrl = '/placeholder.svg?height=300&width=200';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã chọn ảnh bìa'),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  void _saveManga() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất một thể loại'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_coverImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ảnh bìa'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Lưu truyện (trong thực tế sẽ gọi API)
      final isEditing = widget.manga != null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Đã cập nhật truyện!' : 'Đã đăng truyện mới!'),
          backgroundColor: Colors.cyan,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _addChapter() {
    // Điều hướng đến màn hình thêm chương
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadChapterScreen(manga: widget.manga!),
      ),
    );
  }
}

// Màn hình đăng chương mới
class UploadChapterScreen extends StatefulWidget {
  final Manga manga;

  const UploadChapterScreen({super.key, required this.manga});

  @override
  State<UploadChapterScreen> createState() => _UploadChapterScreenState();
}

class _UploadChapterScreenState extends State<UploadChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final List<String> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: Text(
          'Thêm Chương - ${widget.manga.title}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveChapter,
            child: const Text(
              'Đăng',
              style: TextStyle(
                color: Colors.cyan,
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
            // Số chương
            TextFormField(
              controller: _numberController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số chương *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'VD: 1, 2, 3...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1e293b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số chương';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tên chương
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tên chương *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập tên chương',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1e293b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên chương';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Danh sách ảnh
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ảnh chương',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate, color: Colors.cyan),
                        label: const Text('Thêm ảnh', style: TextStyle(color: Colors.cyan)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedImages.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade600),
                            const SizedBox(height: 8),
                            Text(
                              'Chưa có ảnh nào',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lưu ý: Ảnh sẽ được hiển thị theo thứ tự từ trái sang phải, trên xuống dưới',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImages() {
    // Trong thực tế, sẽ mở image picker để chọn nhiều ảnh
    // Ở đây chỉ demo với placeholder
    setState(() {
      for (int i = 0; i < 5; i++) {
        _selectedImages.add('/placeholder.svg?height=800&width=600&text=Page${_selectedImages.length + 1}');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm 5 ảnh mẫu'),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  void _saveChapter() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một ảnh'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Lưu chương (trong thực tế sẽ gọi API)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng chương mới!'),
          backgroundColor: Colors.cyan,
        ),
      );
      Navigator.pop(context);
    }
  }
}
