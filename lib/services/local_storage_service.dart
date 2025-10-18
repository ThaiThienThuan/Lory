import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Lấy thư mục gốc để lưu ảnh
  Future<Directory> get _baseDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    return appDir;
  }

  // Lấy thư mục lưu ảnh bìa manga
  Future<Directory> get mangaCoversDirectory async {
    final baseDir = await _baseDirectory;
    final coversDir = Directory(path.join(baseDir.path, 'manga_covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  // Lấy thư mục lưu ảnh chương
  Future<Directory> getMangaChapterDirectory(String mangaId, String chapterId) async {
    final baseDir = await _baseDirectory;
    final chapterDir = Directory(
      path.join(baseDir.path, 'manga_chapters', mangaId, chapterId),
    );
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }
    return chapterDir;
  }

  // Lưu ảnh bìa manga
  Future<String> saveMangaCover(File imageFile, String mangaId) async {
    try {
      final coversDir = await mangaCoversDirectory;
      final extension = path.extension(imageFile.path);
      final fileName = '$mangaId$extension';
      final savedFile = File(path.join(coversDir.path, fileName));
      
      await imageFile.copy(savedFile.path);
      print('[v0] Đã lưu ảnh bìa: ${savedFile.path}');
      
      return savedFile.path;
    } catch (e) {
      print('[v0] Lỗi lưu ảnh bìa: $e');
      rethrow;
    }
  }

  // Lưu nhiều ảnh chương
  Future<List<String>> saveChapterImages(
    List<File> imageFiles,
    String mangaId,
    String chapterId,
  ) async {
    try {
      final chapterDir = await getMangaChapterDirectory(mangaId, chapterId);
      final savedPaths = <String>[];

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final extension = path.extension(imageFile.path);
        final fileName = 'page_${i + 1}$extension';
        final savedFile = File(path.join(chapterDir.path, fileName));
        
        await imageFile.copy(savedFile.path);
        savedPaths.add(savedFile.path);
        
        print('[v0] Đã lưu trang ${i + 1}/${imageFiles.length}');
      }

      print('[v0] Đã lưu ${savedPaths.length} ảnh chương');
      return savedPaths;
    } catch (e) {
      print('[v0] Lỗi lưu ảnh chương: $e');
      rethrow;
    }
  }

  // Download ảnh từ URL và lưu local
  Future<String> downloadAndSaveImage(
    String imageUrl,
    String savePath,
  ) async {
    try {
      final http = HttpClient();
      final request = await http.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.parent.create(recursive: true);
        
        final bytes = await consolidateHttpClientResponseBytes(response);
        await file.writeAsBytes(bytes);
        
        print('[v0] Đã download và lưu: $savePath');
        return savePath;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Lỗi download ảnh: $e');
      rethrow;
    }
  }

  // Download và lưu ảnh bìa từ URL
  Future<String> downloadAndSaveMangaCover(String imageUrl, String mangaId) async {
    try {
      final coversDir = await mangaCoversDirectory;
      final extension = path.extension(Uri.parse(imageUrl).path);
      final fileName = '$mangaId${extension.isEmpty ? '.jpg' : extension}';
      final savePath = path.join(coversDir.path, fileName);
      
      return await downloadAndSaveImage(imageUrl, savePath);
    } catch (e) {
      print('[v0] Lỗi download ảnh bìa: $e');
      rethrow;
    }
  }

  // Download và lưu nhiều ảnh chương từ URLs
  Future<List<String>> downloadAndSaveChapterImages(
    List<String> imageUrls,
    String mangaId,
    String chapterId,
  ) async {
    try {
      final chapterDir = await getMangaChapterDirectory(mangaId, chapterId);
      final savedPaths = <String>[];

      for (int i = 0; i < imageUrls.length; i++) {
        final imageUrl = imageUrls[i];
        final extension = path.extension(Uri.parse(imageUrl).path);
        final fileName = 'page_${i + 1}${extension.isEmpty ? '.jpg' : extension}';
        final savePath = path.join(chapterDir.path, fileName);
        
        try {
          final savedPath = await downloadAndSaveImage(imageUrl, savePath);
          savedPaths.add(savedPath);
          print('[v0] Đã download trang ${i + 1}/${imageUrls.length}');
          
          // Delay nhỏ giữa các download
          if (i < imageUrls.length - 1) {
            await Future.delayed(Duration(milliseconds: 500));
          }
        } catch (e) {
          print('[v0] Lỗi download trang ${i + 1}: $e');
          // Tiếp tục download các trang khác
        }
      }

      print('[v0] Đã download ${savedPaths.length}/${imageUrls.length} ảnh');
      return savedPaths;
    } catch (e) {
      print('[v0] Lỗi download ảnh chương: $e');
      rethrow;
    }
  }

  // Xóa ảnh bìa manga
  Future<void> deleteMangaCover(String mangaId) async {
    try {
      final coversDir = await mangaCoversDirectory;
      final files = coversDir.listSync();
      
      for (var file in files) {
        if (file is File && path.basenameWithoutExtension(file.path) == mangaId) {
          await file.delete();
          print('[v0] Đã xóa ảnh bìa: ${file.path}');
          break;
        }
      }
    } catch (e) {
      print('[v0] Lỗi xóa ảnh bìa: $e');
    }
  }

  // Xóa tất cả ảnh của một manga
  Future<void> deleteMangaData(String mangaId) async {
    try {
      // Xóa ảnh bìa
      await deleteMangaCover(mangaId);
      
      // Xóa thư mục chương
      final baseDir = await _baseDirectory;
      final mangaChaptersDir = Directory(
        path.join(baseDir.path, 'manga_chapters', mangaId),
      );
      
      if (await mangaChaptersDir.exists()) {
        await mangaChaptersDir.delete(recursive: true);
        print('[v0] Đã xóa thư mục chương: ${mangaChaptersDir.path}');
      }
    } catch (e) {
      print('[v0] Lỗi xóa dữ liệu manga: $e');
    }
  }

  // Kiểm tra file có tồn tại không
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Lấy kích thước thư mục (để hiển thị dung lượng đã dùng)
  Future<int> getDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      print('[v0] Lỗi tính kích thước thư mục: $e');
    }
    return totalSize;
  }

  // Lấy tổng dung lượng đã sử dụng
  Future<String> getTotalStorageUsed() async {
    try {
      final baseDir = await _baseDirectory;
      final totalBytes = await getDirectorySize(baseDir);
      final mb = totalBytes / (1024 * 1024);
      
      if (mb < 1) {
        return '${(totalBytes / 1024).toStringAsFixed(2)} KB';
      } else if (mb < 1024) {
        return '${mb.toStringAsFixed(2)} MB';
      } else {
        return '${(mb / 1024).toStringAsFixed(2)} GB';
      }
    } catch (e) {
      return '0 KB';
    }
  }
}

// Helper function để consolidate HTTP response bytes
Future<List<int>> consolidateHttpClientResponseBytes(HttpClientResponse response) async {
  final bytes = <int>[];
  await for (var chunk in response) {
    bytes.addAll(chunk);
  }
  return bytes;
}
