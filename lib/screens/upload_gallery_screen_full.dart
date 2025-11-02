import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// Màn hình đăng fanart/gallery cho nhóm dịch và admin (Cloudinary version)
class UploadGalleryScreenFull extends StatefulWidget {
  const UploadGalleryScreenFull({super.key});

  @override
  State<UploadGalleryScreenFull> createState() =>
      _UploadGalleryScreenFullState();
}

class _UploadGalleryScreenFullState extends State<UploadGalleryScreenFull> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _storageService = StorageService();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  File? _selectedImageFile;
  String? _uploadedImageUrl;
  String? _selectedMangaId;
  final List<String> _selectedTags = [];
  bool _isUploading = false;

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
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                ),
              ),
            )
          else
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
                child: _selectedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _uploadedImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _uploadedImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  color: Colors.cyan, size: 64),
                              const SizedBox(height: 12),
                              const Text(
                                'Chọn ảnh fanart',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Khuyến nghị: 1080x1350px',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_upload,
                                        color: Colors.cyan, size: 16),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Upload với Cloudinary',
                                      style: TextStyle(
                                          color: Colors.cyan, fontSize: 12),
                                    ),
                                  ],
                                ),
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
                        icon:
                            const Icon(Icons.add, color: Colors.cyan, size: 16),
                        label: const Text('Thêm',
                            style: TextStyle(color: Colors.cyan)),
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
                          deleteIcon: const Icon(Icons.close,
                              size: 16, color: Colors.cyan),
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

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: const Text('Chọn Ảnh', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.cyan),
                title: const Text('Thư viện ảnh',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyan),
                title: const Text('Chụp ảnh',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final file = await _storageService.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _selectedImageFile = file;
        _uploadedImageUrl = null;
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
    final file = await _storageService.pickImageFromCamera();
    if (file != null) {
      setState(() {
        _selectedImageFile = file;
        _uploadedImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chụp ảnh'),
          backgroundColor: Colors.green,
        ),
      );
    }
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

  Future<void> _saveGallery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImageFile == null && _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh'),
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

      String imageUrl;

      if (_selectedImageFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang upload ảnh lên Cloudinary...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        final uploadedUrl = await _storageService.uploadGalleryImage(
          _selectedImageFile!,
          _titleController.text.trim(),
        );

        if (uploadedUrl == null) {
          throw Exception('Không thể upload ảnh');
        }

        imageUrl = uploadedUrl;
      } else {
        imageUrl = _uploadedImageUrl!;
      }

      // TODO: Save to Firestore (implement GalleryItem model and firestoreService method)
      // await _firestoreService.addGalleryItem(...);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đăng fanart thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng fanart: $e'),
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
