import 'package:flutter/material.dart';

// Màn hình đăng fanart/gallery cho nhóm dịch và admin
class UploadGalleryScreen extends StatefulWidget {
  const UploadGalleryScreen({super.key});

  @override
  State<UploadGalleryScreen> createState() => _UploadGalleryScreenState();
}

class _UploadGalleryScreenState extends State<UploadGalleryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedImageUrl;
  String? _selectedMangaId;
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text(
          'Đăng Fanart',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveGallery,
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
            // Ảnh fanart
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: _selectedImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.cyan, size: 64),
                          const SizedBox(height: 12),
                          const Text(
                            'Chọn ảnh fanart',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Khuyến nghị: 1080x1350px',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tiêu đề *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập tiêu đề fanart',
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
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Mô tả
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập mô tả về fanart (tùy chọn)',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1e293b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Chọn truyện liên quan
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
                    'Truyện liên quan',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectManga,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.book, color: Colors.cyan),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedMangaId != null
                                  ? 'Truyện đã chọn'
                                  : 'Chọn truyện (tùy chọn)',
                              style: TextStyle(
                                color: _selectedMangaId != null ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tags
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
                        'Tags',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add, color: Colors.cyan, size: 16),
                        label: const Text('Thêm', style: TextStyle(color: Colors.cyan)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedTags.isEmpty)
                    Text(
                      'Chưa có tag nào',
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.cyan.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.cyan),
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.cyan),
                          onDeleted: () {
                            setState(() {
                              _selectedTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    // Trong thực tế, sẽ mở image picker
    // Ở đây chỉ demo với placeholder
    setState(() {
      _selectedImageUrl = '/placeholder.svg?height=400&width=300';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã chọn ảnh'),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  void _selectManga() {
    // Trong thực tế, sẽ mở dialog chọn truyện
    setState(() {
      _selectedMangaId = '1';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã chọn truyện'),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: const Text('Thêm Tag', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nhập tag',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: const Color(0xFF0f172a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _selectedTags.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _saveGallery() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ảnh'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Lưu gallery (trong thực tế sẽ gọi API)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng fanart!'),
          backgroundColor: Colors.cyan,
        ),
      );
      Navigator.pop(context);
    }
  }
}
