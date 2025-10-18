import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manga.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/mangadex_service.dart';

class UploadMangaScreen extends StatefulWidget {
  const UploadMangaScreen({super.key});

  @override
  State<UploadMangaScreen> createState() => _UploadMangaScreenState();
}

class _UploadMangaScreenState extends State<UploadMangaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _storageService = StorageService();
  // REMOVED: final _mangaDexService = MangaDexService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  
  File? _selectedCoverImage;
  String? _uploadedCoverUrl;
  
  String _selectedStatus = 'Đang ra';
  final List<String> _selectedGenres = [];
  bool _isUploading = false;
  bool _isImporting = false;

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

  final List<String> _statusOptions = [
    'Đang ra',
    'Hoàn thành',
    'Tạm dừng',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text(
          'Đăng Truyện Mới',
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
          else if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _uploadManga,
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
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
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
                                print('[v0] Image loading error: $error');
                                print('[v0] URL: $_uploadedCoverUrl');
                                print('[v0] Stack trace: $stackTrace');
                                
                                return Container(
                                  color: const Color(0xFF1e293b),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Không thể tải ảnh',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          error.toString(),
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            final temp = _uploadedCoverUrl;
                                            _uploadedCoverUrl = null;
                                            Future.delayed(const Duration(milliseconds: 100), () {
                                              setState(() {
                                                _uploadedCoverUrl = temp;
                                              });
                                            });
                                          });
                                        },
                                        icon: const Icon(Icons.refresh, size: 16),
                                        label: const Text('Thử lại'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.cyan,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _showImageSourceDialog,
                                        child: const Text(
                                          'Chọn ảnh khác',
                                          style: TextStyle(color: Colors.cyan),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              placeholderErrorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                                  ),
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, color: Colors.cyan, size: 64),
                              const SizedBox(height: 12),
                              const Text(
                                'Nhấn để thêm ảnh bìa',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Khuyến nghị: 300x400px',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
              ),
            ),
            if (_uploadedCoverUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _uploadedCoverUrl!,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

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

            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mô tả *',
                labelStyle: const TextStyle(color: Colors.cyan),
                hintText: 'Nhập mô tả về truyện',
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
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    dropdownColor: const Color(0xFF0f172a),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0f172a),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
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
                        'Thể loại *',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showGenreSelector,
                        icon: const Icon(Icons.add, color: Colors.cyan, size: 16),
                        label: const Text('Thêm', style: TextStyle(color: Colors.cyan)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedGenres.isEmpty)
                    Text(
                      'Chưa chọn thể loại nào',
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedGenres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: Colors.cyan.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.cyan),
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.cyan),
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
          backgroundColor: const Color(0xFF1e293b),
          title: const Text('Chọn Ảnh Bìa', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_download, color: Colors.purple),
                title: const Text('Import từ MangaDex', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Tự động lấy thông tin & chương',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showMangaDexImportDialog();
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.cyan),
                title: const Text('Thư viện ảnh', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.cyan),
                title: const Text('Chụp ảnh', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.cyan),
                title: const Text('Nhập URL', style: TextStyle(color: Colors.white)),
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
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: const Text('URL Ảnh Bìa', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập URL ảnh bìa\n(ví dụ: https://example.com/image.jpg)',
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0f172a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Lưu ý:',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• URL phải bắt đầu bằng http:// hoặc https://\n'
                      '• URL phải trỏ trực tiếp đến file ảnh (.jpg, .png, .webp)\n'
                      '• Đảm bảo kết nối mạng ổn định',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập URL'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (!url.startsWith('http://') && !url.startsWith('https://')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL phải bắt đầu bằng http:// hoặc https://'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã thêm URL ảnh bìa'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _showGenreSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: const Text('Chọn Thể Loại', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableGenres.length,
              itemBuilder: (context, index) {
                final genre = _availableGenres[index];
                final isSelected = _selectedGenres.contains(genre);
                return CheckboxListTile(
                  title: Text(genre, style: const TextStyle(color: Colors.white)),
                  value: isSelected,
                  activeColor: Colors.cyan,
                  checkColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
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
      
      String coverUrl;
      
      if (_selectedCoverImage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang tải ảnh lên...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        
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
        uploaderId: userId, // Save uploader ID
      );

      final mangaId = await _firestoreService.addManga(manga);

      if (mangaId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đăng truyện thành công!'),
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

  void _showMangaDexImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: Row(
            children: [
              const Icon(Icons.cloud_download, color: Colors.purple),
              const SizedBox(width: 8),
              const Text('Import từ MangaDex', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Nhập URL MangaDex\n(ví dụ: https://mangadex.org/title/...)',
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0f172a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.purple, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Tính năng:',
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Tự động lấy tên, tác giả, mô tả\n'
                      '• Tự động lấy ảnh bìa chất lượng cao\n'
                      '• Tự động import tất cả chương (tối đa 50)\n'
                      '• Tiết kiệm thời gian upload',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập URL MangaDex'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (!url.contains('mangadex.org/title/')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL không hợp lệ. Vui lòng nhập URL MangaDex'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _importFromMangaDex(url);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importFromMangaDex(String url) async {
    setState(() {
      _isImporting = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đang import từ MangaDex...',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng đợi, quá trình này có thể mất vài phút',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      print('[v0] Starting MangaDex import for URL: $url');
      
      // Extract manga ID from URL
      final mangaId = MangaDexService.extractMangaId(url);
      if (mangaId == null) {
        throw Exception('URL không hợp lệ. Không thể trích xuất manga ID từ URL này.');
      }
      print('[v0] Manga ID: $mangaId');

      // Fetch manga details
      print('[v0] Fetching manga details...');
      final mangaData = await MangaDexService.fetchMangaDetails(mangaId);
      
      // Parse manga data
      print('[v0] Parsing manga data...');
      final parsedData = MangaDexService.parseMangaData(mangaData!);

      // Fetch chapters
      print('[v0] Fetching chapters...');
      final chaptersData = await MangaDexService.fetchMangaChapters(mangaId);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Populate form fields
      setState(() {
        _titleController.text = parsedData['title'];
        _authorController.text = parsedData['author'];
        _descriptionController.text = parsedData['description'];
        _uploadedCoverUrl = parsedData['coverUrl'];
        _selectedCoverImage = null;
        _selectedStatus = parsedData['status'];
        _selectedGenres.clear();
        _selectedGenres.addAll((parsedData['genres'] as List).cast<String>());
      });

      // Show success message with chapter count
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import thành công! Đã lấy ${chaptersData.length} chương',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Ask if user wants to upload with chapters
        if (chaptersData.isNotEmpty) {
          _showChapterImportConfirmation(mangaId, chaptersData);
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      print('[v0] Import error: $e');
      
      if (mounted) {
        _showErrorDialog(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _showErrorDialog(dynamic error) {
    String errorTitle = 'Lỗi khi import';
    String errorMessage = '';
    String technicalDetails = error.toString();
    
    // Provide user-friendly error messages
    if (error.toString().contains('SocketException') || 
        error.toString().contains('Failed host lookup')) {
      errorTitle = 'Lỗi kết nối';
      errorMessage = 'Không thể kết nối đến MangaDex. Vui lòng kiểm tra:\n\n'
          '• Kết nối internet của bạn\n'
          '• MangaDex có thể đang bảo trì\n'
          '• Thử lại sau vài phút';
    } else if (error.toString().contains('TimeoutException')) {
      errorTitle = 'Hết thời gian chờ';
      errorMessage = 'Yêu cầu mất quá nhiều thời gian. Vui lòng:\n\n'
          '• Kiểm tra tốc độ mạng\n'
          '• Thử lại sau';
    } else if (error.toString().contains('404')) {
      errorTitle = 'Không tìm thấy';
      errorMessage = 'Không tìm thấy truyện trên MangaDex. Vui lòng:\n\n'
          '• Kiểm tra lại URL\n'
          '• Đảm bảo truyện vẫn còn trên MangaDex';
    } else if (error.toString().contains('429')) {
      errorTitle = 'Quá nhiều yêu cầu';
      errorMessage = 'MangaDex đang giới hạn số lượng yêu cầu.\n\n'
          'Vui lòng thử lại sau 5-10 phút.';
    } else if (error.toString().contains('trích xuất manga ID')) {
      errorTitle = 'URL không hợp lệ';
      errorMessage = 'Không thể đọc URL MangaDex. Vui lòng:\n\n'
          '• Sao chép URL từ thanh địa chỉ trình duyệt\n'
          '• Đảm bảo URL có dạng:\n'
          '  https://mangadex.org/title/[id]/[tên-truyện]';
    } else {
      errorMessage = 'Đã xảy ra lỗi không xác định.\n\n'
          'Vui lòng xem chi tiết kỹ thuật bên dưới.';
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorTitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white, height: 1.5),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text(
                    'Chi tiết kỹ thuật',
                    style: TextStyle(color: Colors.cyan, fontSize: 12),
                  ),
                  iconColor: Colors.cyan,
                  collapsedIconColor: Colors.cyan,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        technicalDetails,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
  }

  void _showChapterImportConfirmation(
    String mangaId,
    List<Map<String, dynamic>> chaptersData,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e293b),
          title: const Text(
            'Import Chương?',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đã tìm thấy ${chaptersData.length} chương. Bạn có muốn import tất cả chương ngay bây giờ không?',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quá trình này có thể mất 5-10 phút',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn có thể thêm chương sau'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text('Bỏ qua', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _uploadMangaWithChapters(mangaId, chaptersData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Import Chương'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadMangaWithChapters(
    String mangaDexId,
    List<Map<String, dynamic>> chaptersData,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Show progress dialog
    int processedChapters = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e293b),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang upload chương $processedChapters/${chaptersData.length}...',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: chaptersData.isNotEmpty ? processedChapters / chaptersData.length : 0,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Không thể xác định người dùng');
      }

      // Create manga first
      final manga = Manga(
        id: '',
        title: _titleController.text.trim(),
        coverImage: _uploadedCoverUrl ?? '',
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
        uploaderId: userId,
      );

      final savedMangaId = await _firestoreService.addManga(manga);
      if (savedMangaId == null) {
        throw Exception('Không thể lưu truyện');
      }

      // Fetch and add chapters
      final chapters = <Chapter>[];
      for (int i = 0; i < chaptersData.length; i++) {
        final chapterData = chaptersData[i];
        final parsedChapter = MangaDexService.parseChapterData(chapterData, i);
        
        // Fetch chapter pages
        final pages = await MangaDexService.fetchChapterPages(parsedChapter['id']);
        
        if (pages.isNotEmpty) {
          final chapter = Chapter(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            title: parsedChapter['title'],
            number: parsedChapter['number'],
            releaseDate: DateTime.now().toIso8601String(),
            pages: pages,
            isRead: false,
            likes: 0,
            isLiked: false,
            comments: [],
          );
          
          chapters.add(chapter);
        }
        
        processedChapters = i + 1;
        // Update progress dialog state if possible (requires passing setState to dialog)
        // For now, the dialog will show the final value after the loop
      }

      // Add all chapters to manga
      for (final chapter in chapters) {
        await _firestoreService.addChapterToManga(savedMangaId, chapter);
      }

      // Close progress dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đăng truyện với ${chapters.length} chương!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Close progress dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi upload: $e'),
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
