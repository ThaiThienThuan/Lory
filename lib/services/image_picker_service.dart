import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Pick image từ gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      developer.log('[v0] Lỗi khi pick image: $e', name: 'ImagePickerService');
      return null;
    }
  }

  /// Pick image từ camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      developer.log('[v0] Lỗi khi pick image: $e', name: 'ImagePickerService');
      return null;
    }
  }

  /// Upload image lên Firebase Storage
  Future<String?> uploadUserAvatar(String userId, File imageFile) async {
    try {
      developer.log('[v0] Bắt đầu upload avatar...',
          name: 'ImagePickerService');

      // Create reference
      final ref = _storage.ref().child('user_avatars/$userId.jpg');

      // Upload file
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      developer.log('[v0] Upload thành công: $downloadUrl',
          name: 'ImagePickerService');

      return downloadUrl;
    } catch (e) {
      developer.log('[v0] Lỗi khi upload avatar: $e',
          name: 'ImagePickerService');
      return null;
    }
  }

  /// Delete old avatar
  Future<bool> deleteUserAvatar(String userId) async {
    try {
      final ref = _storage.ref().child('user_avatars/$userId.jpg');
      await ref.delete();
      developer.log('[v0] Đã xóa avatar cũ', name: 'ImagePickerService');
      return true;
    } catch (e) {
      developer.log('[v0] Lỗi khi xóa avatar: $e', name: 'ImagePickerService');
      return false;
    }
  }
}
