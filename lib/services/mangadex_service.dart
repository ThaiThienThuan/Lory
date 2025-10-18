import 'dart:convert';
import 'package:http/http.dart' as http;

class MangaDexService {
  static const String baseUrl = 'https://api.mangadex.org';
  
  // Extract manga ID from MangaDex URL
  static String? extractMangaId(String url) {
    try {
      // MangaDex URLs: https://mangadex.org/title/{id}/{slug}
      final regex = RegExp(r'mangadex\.org/title/([a-f0-9-]+)');
      final match = regex.firstMatch(url);
      final id = match?.group(1);
      
      print('[v0] Extracting manga ID from URL: $url');
      print('[v0] Extracted manga ID: $id');
      
      return id;
    } catch (e) {
      print('[v0] Error extracting manga ID: $e');
      return null;
    }
  }
  
  // Fetch manga details from MangaDex API
  static Future<Map<String, dynamic>?> fetchMangaDetails(String mangaId) async {
    try {
      final url = '$baseUrl/manga/$mangaId?includes[]=cover_art&includes[]=author';
      print('[v0] Fetching manga details from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('[v0] Response status code: ${response.statusCode}');
      print('[v0] Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[v0] Successfully parsed manga data');
        return data['data'];
      } else {
        print('[v0] API Error: Status ${response.statusCode}');
        print('[v0] Response body: ${response.body}');
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[v0] Error fetching manga details: $e');
      rethrow; // Rethrow to get the actual error message
    }
  }
  
  // Fetch all chapters for a manga
  static Future<List<Map<String, dynamic>>> fetchMangaChapters(String mangaId) async {
    try {
      final chapters = <Map<String, dynamic>>[];
      int offset = 0;
      const int limit = 100;
      
      print('[v0] Fetching chapters for manga: $mangaId');
      
      while (true) {
        final url = '$baseUrl/manga/$mangaId/feed?limit=$limit&offset=$offset&translatedLanguage[]=en&order[chapter]=asc';
        print('[v0] Fetching chapters from: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
        
        print('[v0] Chapters response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['data'] as List;
          
          print('[v0] Found ${results.length} chapters in this batch');
          
          if (results.isEmpty) break;
          
          chapters.addAll(results.cast<Map<String, dynamic>>());
          offset += limit;
          
          // Limit to first 50 chapters for testing
          if (chapters.length >= 50) {
            print('[v0] Reached 50 chapters limit');
            break;
          }
        } else {
          print('[v0] Chapter fetch error: Status ${response.statusCode}');
          break;
        }
      }
      
      print('[v0] Total chapters fetched: ${chapters.length}');
      return chapters;
    } catch (e) {
      print('[v0] Error fetching chapters: $e');
      return [];
    }
  }
  
  // Fetch chapter page URLs
  static Future<List<String>> fetchChapterPages(String chapterId) async {
    try {
      print('[v0] Fetching pages for chapter: $chapterId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/at-home/server/$chapterId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('[v0] Pages response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final baseUrl = data['baseUrl'];
        final hash = data['chapter']['hash'];
        final pages = data['chapter']['data'] as List;
        
        final pageUrls = pages.map((page) => '$baseUrl/data/$hash/$page').toList().cast<String>();
        print('[v0] Found ${pageUrls.length} pages');
        
        return pageUrls;
      }
      
      print('[v0] Failed to fetch pages: Status ${response.statusCode}');
      return [];
    } catch (e) {
      print('[v0] Error fetching chapter pages: $e');
      return [];
    }
  }
  
  // Parse manga data into app format
  static Map<String, dynamic> parseMangaData(Map<String, dynamic> mangaData) {
    try {
      print('[v0] Parsing manga data...');
      
      final attributes = mangaData['attributes'];
      if (attributes == null) {
        throw Exception('Manga attributes not found in response');
      }
      
      final relationships = mangaData['relationships'] as List?;
      if (relationships == null) {
        throw Exception('Manga relationships not found in response');
      }
      
      // Get title (prefer English)
      final titleMap = attributes['title'] as Map<String, dynamic>?;
      String title = 'Unknown Title';
      if (titleMap != null && titleMap.isNotEmpty) {
        title = (titleMap['en'] ?? titleMap.values.first) as String;
      }
      print('[v0] Title: $title');
      
      // Get description (prefer English)
      final descMap = attributes['description'] as Map<String, dynamic>?;
      String description = '';
      if (descMap != null && descMap.isNotEmpty) {
        description = (descMap['en'] ?? descMap.values.first) as String? ?? '';
      }
      
      // Get author
      Map<String, dynamic>? authorRel;
      try {
        authorRel = relationships.firstWhere(
          (rel) => rel['type'] == 'author',
          orElse: () => <String, dynamic>{},
        ) as Map<String, dynamic>?;
      } catch (e) {
        print('[v0] No author found: $e');
      }
      
      final author = authorRel?['attributes']?['name'] as String? ?? 'Unknown';
      print('[v0] Author: $author');
      
      // Get cover art
      Map<String, dynamic>? coverRel;
      try {
        coverRel = relationships.firstWhere(
          (rel) => rel['type'] == 'cover_art',
          orElse: () => <String, dynamic>{},
        ) as Map<String, dynamic>?;
      } catch (e) {
        print('[v0] No cover art found: $e');
      }
      
      final coverFileName = coverRel?['attributes']?['fileName'] as String?;
      final mangaId = mangaData['id'] as String?;
      String coverUrl = '';
      if (coverFileName != null && mangaId != null) {
        coverUrl = 'https://uploads.mangadex.org/covers/$mangaId/$coverFileName';
      }
      print('[v0] Cover URL: $coverUrl');
      
      // Get genres/tags
      final tagsList = attributes['tags'] as List?;
      final tags = <String>[];
      if (tagsList != null) {
        for (var tag in tagsList.take(5)) {
          try {
            final tagName = tag['attributes']?['name']?['en'] as String?;
            if (tagName != null) {
              tags.add(tagName);
            }
          } catch (e) {
            print('[v0] Error parsing tag: $e');
          }
        }
      }
      print('[v0] Genres: $tags');
      
      // Get status
      final statusValue = attributes['status'] as String?;
      final status = statusValue == 'completed' ? 'Hoàn thành' : 'Đang tiến hành';
      
      return {
        'title': title,
        'author': author,
        'description': description,
        'coverUrl': coverUrl,
        'genres': tags,
        'status': status,
      };
    } catch (e) {
      print('[v0] Error parsing manga data: $e');
      print('[v0] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
  
  // Parse chapter data into app format
  static Map<String, dynamic> parseChapterData(
    Map<String, dynamic> chapterData,
    int index,
  ) {
    final attributes = chapterData['attributes'];
    final chapterNum = attributes['chapter'] ?? '${index + 1}';
    final title = attributes['title'] ?? 'Chapter $chapterNum';
    
    return {
      'id': chapterData['id'],
      'number': chapterNum,
      'title': title,
    };
  }
}
