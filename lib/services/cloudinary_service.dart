import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

/// Service để xử lý upload ảnh lên Cloudinary
class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  final ImagePicker _picker = ImagePicker();

  // Singleton pattern
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;

  CloudinaryService._internal() {
    _initializeCloudinary();
  }

  void _initializeCloudinary() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw Exception(
          'Cloudinary credentials not found. Please configure .env file with:\n'
          'CLOUDINARY_CLOUD_NAME=your_cloud_name\n'
          'CLOUDINARY_UPLOAD_PRESET=your_upload_preset');
    }

    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // ✅ Nhỏ hơn cho avatar
        maxHeight: 512,
        imageQuality: 90,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add file validation before upload
  Future<bool> _validateFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return false;
      }

      final fileSize = await imageFile.length();
      const maxSizeBytes = 10 * 1024 * 1024; // 10MB limit

      if (fileSize > maxSizeBytes) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fixed named parameters - must be enclosed in curly braces {}
  /// Add retry logic for upload failures
  Future<String?> _uploadWithRetry({
    required CloudinaryFile cloudinaryFile,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        CloudinaryResponse response =
            await _cloudinary.uploadFile(cloudinaryFile);
        return response.secureUrl;
      } catch (e) {
        if (attempt < maxRetries) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: attempt * 2));
        } else {
          return null;
        }
      }
    }
    return null;
  }

  /// Upload manga cover to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadMangaCover(File imageFile, String mangaTitle) async {
    try {
      if (!await _validateFile(imageFile)) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${mangaTitle.replaceAll(' ', '_')}_$timestamp';

      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'manga_covers',
        publicId: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

      return await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
    } catch (e) {
      return null;
    }
  }

  /// Upload gallery/fanart image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadGalleryImage(File imageFile, String title) async {
    try {
      if (!await _validateFile(imageFile)) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title.replaceAll(' ', '_')}_$timestamp';

      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'gallery',
        publicId: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

      return await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
    } catch (e) {
      return null;
    }
  }

  /// Upload chapter page to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadChapterPage(
    String imagePath,
    String mangaId,
    String pageName,
  ) async {
    try {
      final file = File(imagePath);

      if (!await _validateFile(file)) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${pageName}_$timestamp';

      final cloudinaryFile = CloudinaryFile.fromFile(
        file.path,
        folder: 'chapters/$mangaId',
        publicId: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

      return await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
    } catch (e) {
      return null;
    }
  }

  /// Upload user profile avatar
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      if (!await _validateFile(imageFile)) {
        return null;
      }

      final fileName = 'avatar_$userId';

      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'avatars',
        publicId: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

      return await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
    } catch (e) {
      return null;
    }
  }

  /// Upload community/post image
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadPostImage(File imageFile, String postId) async {
    try {
      if (!await _validateFile(imageFile)) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${postId}_$timestamp';

      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'posts',
        publicId: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

      return await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
    } catch (e) {
      return null;
    }
  }

  /// Delete image from Cloudinary by URL
  /// Note: Deletion requires authentication and is better done from backend
  /// This is a placeholder for future backend implementation
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract public_id from URL
      // Format: https://res.cloudinary.com/{cloud_name}/image/upload/v{version}/{folder}/{public_id}.{format}
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 4) {
        return false;
      }

      // For cloudinary_public package, deletion requires API key/secret
      // which should be done from backend for security
      // TODO: Implement backend API call for deletion
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload multiple images (for bulk upload)
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String folder,
  ) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        if (!await _validateFile(imageFiles[i])) {
          continue;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${folder}_${timestamp}_$i';

        final cloudinaryFile = CloudinaryFile.fromFile(
          imageFiles[i].path,
          folder: folder,
          publicId: fileName,
          resourceType: CloudinaryResourceType.Image,
        );

        final url = await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        // Continue with next image even if one fails
      }
    }

    return uploadedUrls;
  }

  /// Get optimized image URL with transformations
  /// Example transformations: width, height, crop, quality
  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? crop,
    int? quality,
  }) {
    try {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments.toList();

      // Find 'upload' segment
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return originalUrl;

      // Build transformation string
      final transformations = <String>[];
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      if (crop != null) transformations.add('c_$crop');
      if (quality != null) transformations.add('q_$quality');

      if (transformations.isEmpty) return originalUrl;

      // Insert transformations after 'upload'
      pathSegments.insert(uploadIndex + 1, transformations.join(','));

      return uri.replace(pathSegments: pathSegments).toString();
    } catch (e) {
      return originalUrl;
    }
  }

  /// Upload multiple post images (optimized for social feed)
  /// Returns list of secure URLs
  Future<List<String>> uploadPostImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        if (!await _validateFile(imageFiles[i])) {
          continue;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'post_${timestamp}_$i';

        final cloudinaryFile = CloudinaryFile.fromFile(
          imageFiles[i].path,
          folder: 'posts',
          publicId: fileName,
          resourceType: CloudinaryResourceType.Image,
        );

        final url = await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        print('Error uploading post image $i: $e');
        // Continue with next image even if one fails
      }
    }

    return uploadedUrls;
  }

  /// Pick multiple images from gallery (for posts)
  Future<List<File>> pickMultipleImagesFromGallery({int limit = 10}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Limit số lượng ảnh
        final limitedImages = images.take(limit).toList();
        return limitedImages.map((xFile) => File(xFile.path)).toList();
      }
      return [];
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Upload single post image with optimized settings
  Future<String?> uploadSinglePostImage(File imageFile) async {
    try {
      if (!await _validateFile(imageFile)) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_$timestamp';

      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'posts',
        publicId: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

      return await _uploadWithRetry(cloudinaryFile: cloudinaryFile);
    } catch (e) {
      print('Error uploading single post image: $e');
      return null;
    }
  }
}
