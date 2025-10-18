import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/manga.dart';
import 'local_storage_service.dart';

class NetTruyenScraper {
  static const String baseUrl = 'https://www.nettruyenmax.com';
  static const Duration requestDelay = Duration(milliseconds: 1000);
  final LocalStorageService _localStorage = LocalStorageService();

  // Lấy thông tin manga từ URL
  Future<Map<String, dynamic>> scrapeMangaInfo(String mangaUrl) async {
    print('[v0] Đang scrape manga info từ: $mangaUrl');
    
    try {
      await Future.delayed(requestDelay); // Rate limiting
      final response = await http.get(
        Uri.parse(mangaUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load manga page: ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);

      // Lấy thông tin cơ bản
      final title = document.querySelector('h1.title-detail')?.text.trim() ?? 
                   document.querySelector('.title-detail')?.text.trim() ?? 
                   'Unknown Title';
      
      final coverImage = document.querySelector('.col-image img')?.attributes['src'] ?? 
                        document.querySelector('.detail-info img')?.attributes['src'] ?? '';
      
      // Lấy thông tin chi tiết
      final infoElements = document.querySelectorAll('.list-info .row');
      String author = 'Unknown';
      String status = 'Đang ra';
      List<String> genres = [];

      for (var element in infoElements) {
        final label = element.querySelector('.info-item')?.text.toLowerCase() ?? '';
        
        if (label.contains('tác giả') || label.contains('author')) {
          author = element.querySelector('a')?.text.trim() ?? 'Unknown';
        } else if (label.contains('tình trạng') || label.contains('status')) {
          status = element.querySelector('.info-value')?.text.trim() ?? 'Đang ra';
        } else if (label.contains('thể loại') || label.contains('genres')) {
          genres = element.querySelectorAll('a')
              .map((e) => e.text.trim())
              .where((g) => g.isNotEmpty)
              .toList();
        }
      }

      // Lấy mô tả
      final description = document.querySelector('.detail-content p')?.text.trim() ?? 
                         document.querySelector('.content-detail')?.text.trim() ?? 
                         'Không có mô tả';

      // Lấy danh sách chương
      final chapters = await _scrapeChapterList(document, mangaUrl);

      print('[v0] Đã scrape thành công: $title với ${chapters.length} chương');

      return {
        'title': title,
        'author': author,
        'description': description,
        'coverImage': coverImage.startsWith('http') ? coverImage : baseUrl + coverImage,
        'status': status,
        'genres': genres,
        'chapters': chapters,
      };
    } catch (e) {
      print('[v0] Lỗi khi scrape manga info: $e');
      rethrow;
    }
  }

  // Lấy danh sách chương
  Future<List<Map<String, dynamic>>> _scrapeChapterList(
    Document document,
    String mangaUrl,
  ) async {
    final chapters = <Map<String, dynamic>>[];
    
    final chapterElements = document.querySelectorAll('.list-chapter li a') +
                           document.querySelectorAll('#nt_listchapter a');

    for (var element in chapterElements) {
      final chapterTitle = element.text.trim();
      final chapterUrl = element.attributes['href'] ?? '';
      
      if (chapterTitle.isNotEmpty && chapterUrl.isNotEmpty) {
        chapters.add({
          'title': chapterTitle,
          'url': chapterUrl.startsWith('http') ? chapterUrl : baseUrl + chapterUrl,
        });
      }
    }

    // NetTruyen thường hiển thị chương mới nhất ở trên, đảo ngược để có thứ tự đúng
    return chapters.reversed.toList();
  }

  // Lấy tất cả ảnh của một chương
  Future<List<String>> scrapeChapterImages(String chapterUrl) async {
    print('[v0] Đang scrape chapter images từ: $chapterUrl');
    
    try {
      await Future.delayed(Duration(milliseconds: 500)); // Rate limiting
      final response = await http.get(
        Uri.parse(chapterUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Referer': baseUrl,
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final images = <String>[];

        // NetTruyen thường có ảnh trong .reading-detail img hoặc .page-chapter img
        final imageElements = document.querySelectorAll('.reading-detail img') +
                             document.querySelectorAll('.page-chapter img');

        for (var element in imageElements) {
          final src = element.attributes['data-original'] ?? 
                     element.attributes['data-src'] ?? 
                     element.attributes['src'] ?? '';
          
          if (src.isNotEmpty && !src.contains('loading') && !src.contains('placeholder')) {
            final imageUrl = src.startsWith('http') ? src : baseUrl + src;
            images.add(imageUrl);
          }
        }

        print('[v0] Đã tìm thấy ${images.length} ảnh trong chương');
        return images;
      }
      return [];
    } catch (e) {
      print('[v0] Lỗi khi scrape chapter images: $e');
      return [];
    }
  }

  Future<String?> downloadAndSaveImage(
    String imageUrl,
    String mangaId,
    String chapterId,
    int pageNumber,
  ) async {
    try {
      print('[v0] Đang download ảnh từ: $imageUrl');
      await Future.delayed(Duration(milliseconds: 500));
      
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Referer': baseUrl,
        },
      );

      if (response.statusCode == 200) {
        // Lưu tạm vào file
        final tempDir = Directory.systemTemp;
        final extension = imageUrl.split('.').last.split('?').first;
        final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.$extension');
        await tempFile.writeAsBytes(response.bodyBytes);
        
        print('[v0] Đang lưu vào bộ nhớ thiết bị...');
        final chapterDir = await _localStorage.getMangaChapterDirectory(mangaId, chapterId);
        final savedPath = '${chapterDir.path}/page_$pageNumber.$extension';
        await tempFile.copy(savedPath);
        
        // Xóa file tạm
        await tempFile.delete();
        
        print('[v0] Lưu thành công: $savedPath');
        return savedPath;
      }
      return null;
    } catch (e) {
      print('[v0] Lỗi khi download/save ảnh $imageUrl: $e');
      return null;
    }
  }

  Future<List<String>> downloadAndSaveMultipleImages(
    List<String> imageUrls,
    String mangaId,
    String chapterId,
  ) async {
    final savedPaths = <String>[];
    
    for (int i = 0; i < imageUrls.length; i++) {
      final imageUrl = imageUrls[i];
      
      final savedPath = await downloadAndSaveImage(imageUrl, mangaId, chapterId, i + 1);
      if (savedPath != null) {
        savedPaths.add(savedPath);
      }
      
      // Delay giữa các download
      if (i < imageUrls.length - 1) {
        await Future.delayed(Duration(seconds: 2));
      }
    }
    
    return savedPaths;
  }

  Future<String?> downloadAndSaveMangaCover(String imageUrl, String mangaId) async {
    try {
      print('[v0] Đang download ảnh bìa từ: $imageUrl');
      
      final savedPath = await _localStorage.downloadAndSaveMangaCover(imageUrl, mangaId);
      print('[v0] Đã lưu ảnh bìa: $savedPath');
      
      return savedPath;
    } catch (e) {
      print('[v0] Lỗi download ảnh bìa: $e');
      return null;
    }
  }
}
