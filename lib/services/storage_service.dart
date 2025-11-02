import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

/// Service để xử lý upload ảnh
/// Hỗ trợ cả Firebase Storage và Cloudinary
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  // Flag để chọn storage provider (true = Cloudinary, false = Firebase)
  // Đặt thành true để sử dụng Cloudinary
  static const bool _useCloudinary = true;

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1350,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1350,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1350,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Upload image to Firebase Storage and return download URL
  Future<String?> uploadMangaCover(File imageFile, String mangaTitle) async {
    if (_useCloudinary) {
      return await _cloudinaryService.uploadMangaCover(imageFile, mangaTitle);
    }
    
    try {
      // Create a unique filename using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${mangaTitle.replaceAll(' ', '_')}_$timestamp.jpg';
      
      // Reference to storage location
      final ref = _storage.ref().child('manga_covers/$fileName');
      
      // Upload file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'mangaTitle': mangaTitle},
        ),
      );
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload gallery/fanart image
  Future<String?> uploadGalleryImage(File imageFile, String title) async {
    if (_useCloudinary) {
      return await _cloudinaryService.uploadGalleryImage(imageFile, title);
    }
    
    // Firebase Storage implementation (fallback)
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title.replaceAll(' ', '_')}_$timestamp.jpg';
      
      final ref = _storage.ref().child('gallery/$fileName');
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'title': title},
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading gallery image: $e');
      return null;
    }
  }

  // Upload chapter page
  Future<String?> uploadChapterPage(String imagePath, String mangaId, String pageName) async {
    if (_useCloudinary) {
      return await _cloudinaryService.uploadChapterPage(imagePath, mangaId, pageName);
    }
    
    // Firebase Storage implementation (fallback)
    try {
      final file = File(imagePath);
      
      if (!await file.exists()) {
        print('Error: File does not exist at path: $imagePath');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${pageName}_$timestamp.jpg';
      
      // Store chapter pages in a structured path: chapters/{mangaId}/{fileName}
      final ref = _storage.ref().child('chapters/$mangaId/$fileName');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'mangaId': mangaId, 'pageName': pageName},
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading chapter page: $e');
      return null;
    }
  }

  // Delete image from storage
  Future<bool> deleteImage(String imageUrl) async {
    if (_useCloudinary) {
      return await _cloudinaryService.deleteImage(imageUrl);
    }
    
    // Firebase Storage implementation (fallback)
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
  
  /// Upload avatar image
  Future<String?> uploadAvatar(File imageFile, String userId) async {
    if (_useCloudinary) {
      return await _cloudinaryService.uploadAvatar(imageFile, userId);
    }
    
    // Firebase Storage implementation (fallback)
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avatar_${userId}_$timestamp.jpg';
      
      final ref = _storage.ref().child('avatars/$fileName');
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
  
  /// Upload post/community image
  Future<String?> uploadPostImage(File imageFile, String postId) async {
    if (_useCloudinary) {
      return await _cloudinaryService.uploadPostImage(imageFile, postId);
    }
    
    // Firebase Storage implementation (fallback)
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${postId}_$timestamp.jpg';
      
      final ref = _storage.ref().child('posts/$fileName');
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'postId': postId},
        ),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      return null;
    }
  }
}
