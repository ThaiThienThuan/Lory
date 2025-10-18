import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manga.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../models/community.dart';
//import '../models/chapter.dart'; // Import Chapter model

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _mangaCollection => _firestore.collection('manga');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _postsCollection => _firestore.collection('posts');
  CollectionReference get _communitiesCollection => _firestore.collection('communities');

  // ==================== MANGA OPERATIONS ====================

  // Lấy tất cả manga
  Stream<List<Manga>> getMangaStream() {
    return _mangaCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Manga.fromJson(data);
      }).toList();
    });
  }

  // Lấy manga theo ID
  Future<Manga?> getMangaById(String id) async {
    try {
      final doc = await _mangaCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Manga.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy manga: $e');
      return null;
    }
  }

  // Thêm manga mới
  Future<String?> addManga(Manga manga) async {
    try {
      final docRef = await _mangaCollection.add(manga.toJson());
      return docRef.id;
    } catch (e) {
      print('Lỗi khi thêm manga: $e');
      return null;
    }
  }

  // Cập nhật manga
  Future<bool> updateManga(String id, Map<String, dynamic> data) async {
    try {
      await _mangaCollection.doc(id).update(data);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật manga: $e');
      return false;
    }
  }

  // Xóa manga
  Future<bool> deleteManga(String id) async {
    try {
      await _mangaCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa manga: $e');
      return false;
    }
  }

  // Lấy manga hot (sắp xếp theo views)
  Stream<List<Manga>> getHotMangaStream({int limit = 10}) {
    return _mangaCollection
        .orderBy('views', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Manga.fromJson(data);
      }).toList();
    });
  }

  // Lấy manga theo thể loại
  Stream<List<Manga>> getMangaByGenre(String genre) {
    return _mangaCollection
        .where('genres', arrayContains: genre)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Manga.fromJson(data);
      }).toList();
    });
  }

  // Tìm kiếm manga
  Future<List<Manga>> searchManga(String query) async {
    try {
      final lowerQuery = query.toLowerCase().trim();
      final snapshot = await _mangaCollection
          .where('title', isGreaterThanOrEqualTo: lowerQuery)
          .where('title', isLessThanOrEqualTo: lowerQuery + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Manga.fromJson(data);
          })
          .where((manga) =>
              manga.title.toLowerCase().contains(lowerQuery) ||
              manga.author.toLowerCase().contains(lowerQuery) ||
              manga.genres.any((genre) =>
                  genre.toLowerCase().contains(lowerQuery)))
          .toList();
    } catch (e) {
      print('Lỗi khi tìm kiếm manga: $e');
      return [];
    }
  }

  // ==================== USER OPERATIONS ====================

  // Lấy user theo ID
  Future<User?> getUserById(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  // Tạo hoặc cập nhật user
  Future<bool> setUser(String id, User user) async {
    try {
      await _usersCollection.doc(id).set(user.toJson());
      return true;
    } catch (e) {
      print('Lỗi khi lưu thông tin người dùng: $e');
      return false;
    }
  }

  // Cập nhật thông tin user
  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(id).update(data);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return false;
    }
  }

  // ==================== POST OPERATIONS ====================

  // Lấy tất cả posts
  Stream<List<Post>> getPostsStream({int limit = 20}) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Post.fromJson(data);
      }).toList();
    });
  }

  // Thêm post mới
  Future<String?> addPost(Post post) async {
    try {
      final docRef = await _postsCollection.add(post.toJson());
      return docRef.id;
    } catch (e) {
      print('Lỗi khi thêm bài viết: $e');
      return null;
    }
  }

  // Cập nhật post
  Future<bool> updatePost(String id, Map<String, dynamic> data) async {
    try {
      await _postsCollection.doc(id).update(data);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật bài viết: $e');
      return false;
    }
  }

  // Xóa post
  Future<bool> deletePost(String id) async {
    try {
      await _postsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Lỗi khi xóa bài viết: $e');
      return false;
    }
  }

  // Lấy posts theo community
  Stream<List<Post>> getPostsByCommunity(String communityId) {
    return _postsCollection
        .where('community.id', isEqualTo: communityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Post.fromJson(data);
      }).toList();
    });
  }

  // ==================== COMMUNITY OPERATIONS ====================

  // Lấy tất cả communities
  Stream<List<Community>> getCommunitiesStream() {
    return _communitiesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Community.fromJson(data);
      }).toList();
    });
  }

  // Lấy community theo ID
  Future<Community?> getCommunityById(String id) async {
    try {
      final doc = await _communitiesCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Community.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin cộng đồng: $e');
      return null;
    }
  }

  // Thêm community mới
  Future<String?> addCommunity(Community community) async {
    try {
      final docRef = await _communitiesCollection.add(community.toJson());
      return docRef.id;
    } catch (e) {
      print('Lỗi khi thêm cộng đồng: $e');
      return null;
    }
  }

  // Cập nhật community
  Future<bool> updateCommunity(String id, Map<String, dynamic> data) async {
    try {
      await _communitiesCollection.doc(id).update(data);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật cộng đồng: $e');
      return false;
    }
  }

  // ==================== COMMENT OPERATIONS ====================

  // Thêm comment vào manga
  Future<bool> addCommentToManga(String mangaId, Comment comment) async {
    try {
      final manga = await getMangaById(mangaId);
      if (manga != null) {
        final updatedComments = [...manga.comments, comment];
        await updateManga(mangaId, {
          'comments': updatedComments.map((c) => c.toJson()).toList(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi thêm bình luận vào manga: $e');
      return false;
    }
  }

  // Thêm comment vào chapter
  Future<bool> addCommentToChapter(
      String mangaId, String chapterId, Comment comment) async {
    try {
      final manga = await getMangaById(mangaId);
      if (manga != null) {
        final updatedChapters = manga.chapters.map((chapter) {
          if (chapter.id == chapterId) {
            final updatedComments = [...chapter.comments, comment];
            return Chapter(
              id: chapter.id,
              title: chapter.title,
              number: chapter.number,
              releaseDate: chapter.releaseDate,
              pages: chapter.pages,
              isRead: chapter.isRead,
              likes: chapter.likes,
              isLiked: chapter.isLiked,
              comments: updatedComments,
            );
          }
          return chapter;
        }).toList();

        await updateManga(mangaId, {
          'chapters': updatedChapters.map((c) => c.toJson()).toList(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi thêm bình luận vào chapter: $e');
      return false;
    }
  }

  // ==================== CHAPTER OPERATIONS ====================

  // Thêm chương vào manga
  Future<bool> addChapterToManga(String mangaId, Chapter chapter) async {
    try {
      final manga = await getMangaById(mangaId);
      if (manga != null) {
        final updatedChapters = [...manga.chapters, chapter];
        await updateManga(mangaId, {
          'chapters': updatedChapters.map((c) => c.toJson()).toList(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi thêm chương: $e');
      return false;
    }
  }

  // Cập nhật chương
  Future<bool> updateChapter(String mangaId, String chapterId, Map<String, dynamic> updates) async {
    try {
      final manga = await getMangaById(mangaId);
      if (manga != null) {
        final updatedChapters = manga.chapters.map((chapter) {
          if (chapter.id == chapterId) {
            final chapterJson = chapter.toJson();
            chapterJson.addAll(updates);
            return Chapter.fromJson(chapterJson);
          }
          return chapter;
        }).toList();

        await updateManga(mangaId, {
          'chapters': updatedChapters.map((c) => c.toJson()).toList(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi cập nhật chương: $e');
      return false;
    }
  }

  // Xóa chương
  Future<bool> deleteChapter(String mangaId, String chapterId) async {
    try {
      final manga = await getMangaById(mangaId);
      if (manga != null) {
        final updatedChapters = manga.chapters.where((chapter) => chapter.id != chapterId).toList();
        await updateManga(mangaId, {
          'chapters': updatedChapters.map((c) => c.toJson()).toList(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi xóa chương: $e');
      return false;
    }
  }

  // ==================== LIKE OPERATIONS ====================

  // Toggle like manga
  Future<bool> toggleLikeManga(String mangaId, bool currentLikeState) async {
    try {
      await updateManga(mangaId, {'isLiked': !currentLikeState});
      return true;
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái thích manga: $e');
      return false;
    }
  }

  // Toggle follow manga
  Future<bool> toggleFollowManga(String mangaId, bool currentFollowState) async {
    try {
      await updateManga(mangaId, {'isFollowed': !currentFollowState});
      return true;
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái theo dõi manga: $e');
      return false;
    }
  }

  // Tăng view count
  Future<bool> incrementMangaViews(String mangaId) async {
    try {
      await _mangaCollection.doc(mangaId).update({
        'views': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Lỗi khi tăng lượt xem: $e');
      return false;
    }
  }
}
