import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/manga.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../models/community.dart';
import '../models/message.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _mangaCollection => _firestore.collection('manga');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _postsCollection => _firestore.collection('posts');
  CollectionReference get _communitiesCollection =>
      _firestore.collection('communities');

//Lấy tất cả bài đăng có tag #fanart
  Future<List<Post>> getFanartPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('tags', arrayContains: 'fanart')
          .orderBy('createdAt', descending: true)
          .get();
      print('Số fanart lấy được: ${querySnapshot.docs.length}');
      for (var d in querySnapshot.docs) {
        print('🖼️ ${d.id} → ${(d.data() as Map)['tags']}');
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Đảm bảo doc có đủ dữ liệu
        if (data.isEmpty) return null;

        // Gán id cho post nếu model không có sẵn
        final postJson = Map<String, dynamic>.from(data);
        postJson['id'] = doc.id;

        return Post.fromJson(postJson);
      }).whereType<Post>().toList();
    } catch (e, stack) {
      print('🔥 Lỗi khi tải fanart posts: $e');
      print(stack);
      return [];
    }
  }
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
              manga.genres
                  .any((genre) => genre.toLowerCase().contains(lowerQuery)))
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
  Future<bool> setUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(
            data,
            SetOptions(merge: true), // Merge with existing data
          );

      developer.log('[v0] User set: $userId', name: 'FirestoreService');
      return true;
    } catch (e) {
      developer.log('[v0] Lỗi set user: $e', name: 'FirestoreService');
      return false;
    }
  }

  // Cập nhật thông tin user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);

      developer.log('[v0] User updated: $userId', name: 'FirestoreService');
      return true;
    } catch (e) {
      developer.log('[v0] Lỗi update user: $e', name: 'FirestoreService');
      return false;
    }
  }

// ==================== USER FOLLOW OPERATIONS ====================

  /// ✅ Toggle follow user với cập nhật followers/following counts
  Future<bool> toggleFollowUser(
    String currentUserId,
    String targetUserId,
    bool isCurrentlyFollowing,
  ) async {
    try {
      if (isCurrentlyFollowing) {
        // ❌ UNFOLLOW
        print('🔴 UNFOLLOW: $currentUserId -> $targetUserId');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId)
            .delete();

        developer.log(
          '[Follow] Unfollowed: $currentUserId -> $targetUserId',
          name: 'FirestoreService',
        );
      } else {
        // ✅ FOLLOW
        print('🟢 FOLLOW: $currentUserId -> $targetUserId');

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId)
            .set({
          'followedUserId': targetUserId,
          'followedAt': FieldValue.serverTimestamp(),
        });

        developer.log(
          '[Follow] Followed: $currentUserId -> $targetUserId',
          name: 'FirestoreService',
        );
      }

      return true;
    } catch (e) {
      developer.log('[Follow] Lỗi khi toggle follow user: $e',
          name: 'FirestoreService');
      print('Lỗi khi toggle follow user: $e');
      return false;
    }
  }

  /// ✅ Kiểm tra user đã follow chưa
  Future<bool> isFollowingUser(
      String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Lỗi khi kiểm tra follow: $e');
      return false;
    }
  }

  /// ✅ Get followers count stream (real-time)
  Stream<int> getUserFollowersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => (snapshot.data()?['followers'] as int?) ?? 0);
  }

  /// ✅ Get following count stream (real-time)
  Stream<int> getUserFollowingStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => (snapshot.data()?['following'] as int?) ?? 0);
  }

  // ==================== USER INTERACTIONS ====================

  // Save user's like/unlike for a manga
  Future<bool> toggleMangaLike(
      String userId, String mangaId, bool isLiked) async {
    try {
      final docId = '${userId}_${mangaId}';
      if (isLiked) {
        await _firestore.collection('user_interactions').doc(docId).set({
          'userId': userId,
          'mangaId': mangaId,
          'liked': true,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await _firestore.collection('user_interactions').doc(docId).update({
          'liked': false,
        });
      }
      return true;
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái thích: $e');
      return false;
    }
  }

  // Save user's follow/unfollow for a manga
  Future<bool> toggleMangaFollow(
      String userId, String mangaId, bool isFollowed) async {
    try {
      final docId = '${userId}_${mangaId}';
      if (isFollowed) {
        await _firestore.collection('user_interactions').doc(docId).set({
          'userId': userId,
          'mangaId': mangaId,
          'followed': true,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await _firestore.collection('user_interactions').doc(docId).update({
          'followed': false,
        });
      }
      return true;
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái theo dõi: $e');
      return false;
    }
  }

  // Save user's rating for a manga
  Future<bool> saveMangaRating(
      String userId, String mangaId, double rating) async {
    try {
      final docId = '${userId}_${mangaId}';
      await _firestore.collection('user_interactions').doc(docId).set({
        'userId': userId,
        'mangaId': mangaId,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await updateMangaRatingStats(mangaId);

      return true;
    } catch (e) {
      print('Lỗi khi lưu đánh giá: $e');
      return false;
    }
  }

  // Get user's interaction with a manga
  Future<Map<String, dynamic>?> getUserMangaInteraction(
      String userId, String mangaId) async {
    try {
      final docId = '${userId}_${mangaId}';
      final doc =
          await _firestore.collection('user_interactions').doc(docId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin tương tác: $e');
      return null;
    }
  }

  // Get user's followed manga list
  Future<List<String>> getUserFollowedManga(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_interactions')
          .where('userId', isEqualTo: userId)
          .where('followed', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => doc['mangaId'] as String).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách truyện theo dõi: $e');
      return [];
    }
  }

  // Get user's liked manga list
  Future<List<String>> getUserLikedManga(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_interactions')
          .where('userId', isEqualTo: userId)
          .where('liked', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => doc['mangaId'] as String).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách truyện yêu thích: $e');
      return [];
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

  // ==================== POST LIKE OPERATIONS ====================

  Future<bool> togglePostLike(
      String postId, String userId, bool currentLikeState) async {
    try {
      final docId = '${userId}_${postId}';

      if (currentLikeState) {
        // Unlike: delete the like document
        await _firestore.collection('post_likes').doc(docId).delete();
      } else {
        // Like: create the like document
        await _firestore.collection('post_likes').doc(docId).set({
          'userId': userId,
          'postId': postId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái like bài viết: $e');
      return false;
    }
  }

  Future<int> getPostLikesCount(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('post_likes')
          .where('postId', isEqualTo: postId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Lỗi khi lấy số likes: $e');
      return 0;
    }
  }

  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final docId = '${userId}_${postId}';
      final doc = await _firestore.collection('post_likes').doc(docId).get();
      return doc.exists;
    } catch (e) {
      print('Lỗi khi kiểm tra like: $e');
      return false;
    }
  }

  Stream<int> getPostLikesCountStream(String postId) {
    return _firestore
        .collection('post_likes')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ✅ THÊM HÀM NÀY - Real-time like status check
  Stream<bool> hasUserLikedPostStream(String postId, String userId) {
    return _firestore
        .collection('post_likes')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // ==================== POST COMMENT OPERATIONS ====================

  Future<String?> addCommentToPost(String postId, Comment comment) async {
    try {
      final commentData = comment.toJson();
      commentData.remove('id'); // Remove empty id so Firestore generates one
      
      final docRef = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(commentData);

      // Increment comment count on post
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      print('Lỗi khi thêm bình luận vào bài viết: $e');
      return null;
    }
  }

  Stream<List<Comment>> getPostCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Comment.fromJson(data);
      }).toList();
    });
  }

  // Đếm tất cả comments (root + nested replies)
  Stream<int> getCommentCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) {
          int totalCount = 0;
          for (var doc in snapshot.docs) {
            totalCount++; // Count main comment
            // Count replies in the replies array
            final replies = doc['replies'] as List<dynamic>? ?? [];
            totalCount += replies.length;
          }
          return totalCount;
        });
  }

  Future<bool> deleteCommentFromPost(String postId, String commentId) async {
    try {
      if (postId.isEmpty || commentId.isEmpty) {
        print('Lỗi: postId hoặc commentId rỗng');
        return false;
      }

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comment count on post
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Lỗi khi xóa bình luận: $e');
      return false;
    }
  }

  Future<bool> toggleCommentLike(String postId, String commentId, String userId,
      bool currentLikeState) async {
    try {
      final docId = '${userId}_${commentId}';

      if (currentLikeState) {
        // Unlike: delete the like document
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comment_likes')
            .doc(docId)
            .delete();
      } else {
        // Like: create the like document
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comment_likes')
            .doc(docId)
            .set({
          'userId': userId,
          'commentId': commentId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái like bình luận: $e');
      return false;
    }
  }

  Stream<int> getCommentLikesCountStream(String postId, String commentId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comment_likes')
        .where('commentId', isEqualTo: commentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<bool> hasUserLikedComment(
      String postId, String commentId, String userId) async {
    try {
      final docId = '${userId}_${commentId}';
      final doc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comment_likes')
          .doc(docId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Lỗi khi kiểm tra like bình luận: $e');
      return false;
    }
  }

  Stream<int> getPostCommentsCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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
  Future<bool> updateChapter(
      String mangaId, String chapterId, Map<String, dynamic> updates) async {
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
        final updatedChapters =
            manga.chapters.where((chapter) => chapter.id != chapterId).toList();
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
  Future<bool> toggleFollowManga(
      String mangaId, bool currentFollowState) async {
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
        'lastViewedAt': FieldValue.serverTimestamp(), // ✅ THÊM timestamp
      });
      developer.log('[v0] Đã tăng view count cho manga: $mangaId',
          name: 'FirestoreService');
      return true;
    } catch (e) {
      developer.log('[v0] Lỗi khi tăng lượt xem: $e', name: 'FirestoreService');
      print('Lỗi khi tăng lượt xem: $e');
      return false;
    }
  }

  /// Track reading session để tránh spam view count
  /// - Chỉ tăng view nếu user chưa đọc chapter này trong vòng 24h
  Future<bool> trackReadingSession(
    String userId,
    String mangaId,
    String chapterId,
  ) async {
    try {
      // ✅ GET MANGA & CHAPTER INFO TRƯỚC KHI LƯU
      final manga = await getMangaById(mangaId);
      if (manga == null) {
        developer.log('[v0] Manga not found: $mangaId',
            name: 'FirestoreService');
        return false;
      }

      final chapter = manga.chapters.firstWhere(
        (c) => c.id == chapterId,
        orElse: () => Chapter(
          id: '',
          title: 'Unknown',
          number: 0,
          releaseDate: DateTime.now().toIso8601String(),
          pages: [],
          isRead: false,
          likes: 0,
          isLiked: false,
          comments: [],
        ),
      );

      if (chapter.id.isEmpty) {
        developer.log('[v0] Chapter not found: $chapterId',
            name: 'FirestoreService');
        return false;
      }

      final sessionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('reading_sessions')
          .doc('${mangaId}_${chapterId}');

      // Kiểm tra xem đã đọc chapter này trong vòng 24h chưa
      final session = await sessionRef.get();
      bool shouldIncrementView = true;

      if (session.exists) {
        final data = session.data();
        final lastRead = data?['lastReadAt'] as Timestamp?;

        if (lastRead != null) {
          final lastReadDate = lastRead.toDate();
          final now = DateTime.now();
          final difference = now.difference(lastReadDate);

          // Nếu đã đọc trong vòng 24h thì không tăng view count
          if (difference.inHours < 24) {
            shouldIncrementView = false;
            developer.log(
              '[v0] Đã đọc chapter trong 24h, không tăng view',
              name: 'FirestoreService',
            );
          }
        }
      }

      // Tăng view count nếu cần
      if (shouldIncrementView) {
        await incrementMangaViews(mangaId);
      }

      final now = DateTime.now();
      final timestamp = now.toIso8601String();

      await sessionRef.set({
        'userId': userId,
        'mangaId': mangaId,
        'mangaTitle': manga.title,
        'chapterId': chapterId,
        'chapterTitle': chapter.title,
        'timestamp': timestamp,
        'orderedTimestamp': FieldValue.serverTimestamp(), // <-- THÊM: Để sort chính xác
        'lastReadAt': FieldValue.serverTimestamp(),
        'totalReads': FieldValue.increment(1),
      }, SetOptions(merge: true));

      developer.log(
        '[v0] Tracked session: ${manga.title} - ${chapter.title}',
        name: 'FirestoreService',
      );

      return true;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi track reading session: $e',
        name: 'FirestoreService',
      );
      return false;
    }
  }

  /// Fix: Use orderedTimestamp for correct sorting instead of string timestamp
  /// Lấy reading history của user
  Future<List<Map<String, dynamic>>> getUserReadingHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reading_sessions')
          .orderBy('orderedTimestamp',
              descending: true) // <-- CHANGE: Sort by Timestamp, not string
          .limit(limit)
          .get();

      final sessions = snapshot.docs.map((doc) {
        final data = doc.data();

        developer.log(
          '[v0] Session ${doc.id}: mangaTitle=${data['mangaTitle']}, chapterTitle=${data['chapterTitle']}',
          name: 'FirestoreService',
        );

        return data;
      }).toList();

      developer.log(
        '[v0] Loaded ${sessions.length} reading sessions',
        name: 'FirestoreService',
      );

      return sessions;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi lấy lịch sử đọc: $e',
        name: 'FirestoreService',
      );
      return [];
    }
  }

  /// Xóa reading session cũ (cleanup)
  Future<bool> cleanupOldReadingSessions(String userId,
      {int daysOld = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reading_sessions')
          .where('lastReadAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      developer.log(
        '[v0] Đã xóa ${snapshot.docs.length} reading sessions cũ',
        name: 'FirestoreService',
      );
      return true;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi cleanup reading sessions: $e',
        name: 'FirestoreService',
      );
      return false;
    }
  }

  Future<bool> updateMangaRatingStats(String mangaId) async {
    try {
      // Get all ratings for this manga
      final snapshot = await _firestore
          .collection('user_interactions')
          .where('mangaId', isEqualTo: mangaId)
          .where('rating', isGreaterThan: 0)
          .get();

      if (snapshot.docs.isEmpty) {
        // No ratings yet
        await updateManga(mangaId, {
          'rating': 0.0,
          'totalRatings': 0,
        });
        return true;
      }

      // Calculate average rating
      double totalRating = 0;
      for (var doc in snapshot.docs) {
        final rating = doc['rating'] as double? ?? 0;
        totalRating += rating;
      }

      final averageRating = totalRating / snapshot.docs.length;
      final totalRatings = snapshot.docs.length;

      // Update manga document
      await updateManga(mangaId, {
        'rating': averageRating,
        'totalRatings': totalRatings,
      });

      developer.log(
        '[v0] Đã cập nhật rating stats: avg=$averageRating, total=$totalRatings',
        name: 'FirestoreService',
      );

      return true;
    } catch (e) {
      developer.log('[v0] Lỗi khi cập nhật thống kê đánh giá: $e',
          name: 'FirestoreService');
      print('Lỗi khi cập nhật thống kê đánh giá: $e');
      return false;
    }
  }

  // ==================== COMMENT OPERATIONS ====================

  Future<void> updateComment(String postId, Comment comment) async {
    try {
      final commentData = comment.toJson();
      commentData.remove('id'); // Don't update the id field
      
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.id)
          .update(commentData);
    } catch (e) {
      print('Error updating comment: $e');
      rethrow;
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Gửi tin nhắn mới và lưu vào Firestore
  Future<bool> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      developer.log(
        '[v0] Tin nhắn đã được gửi trong conversation: $conversationId',
        name: 'FirestoreService',
      );
      return true;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi gửi tin nhắn: $e',
        name: 'FirestoreService',
      );
      return false;
    }
  }

  /// Lấy tin nhắn real-time từ một conversation
  Stream<List<Message>> getMessagesStream(String conversationId, {String currentUserId = ''}) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      developer.log(
        '[v0] Received ${snapshot.docs.length} messages from Firestore',
        name: 'FirestoreService',
      );
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        final senderId = data['senderId'] as String? ?? '';
        data['isMe'] = senderId == currentUserId;

        if (data['timestamp'] is Timestamp) {
          data['timestamp'] =
              (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }

        developer.log(
          '[v0] Message: sender=$senderId, isMe=${data['isMe']}, content=${data['content']}',
          name: 'FirestoreService',
        );

        return Message.fromJson(data);
      }).toList();
    }).handleError((error) {
      developer.log(
        '[v0] Error in getMessagesStream: $error',
        name: 'FirestoreService',
      );
      return [];
    });
  }

  /// Tạo hoặc lấy conversation giữa 2 user
  Future<String> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final userIds = [currentUserId, otherUserId]..sort();
      final conversationId = '${userIds[0]}_${userIds[1]}';

      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        await _firestore.collection('conversations').doc(conversationId).set({
          'id': conversationId,
          'participants': [currentUserId, otherUserId],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastSenderId': '',
        });

        developer.log(
          '[v0] Tạo conversation mới: $conversationId',
          name: 'FirestoreService',
        );
      }

      return conversationId;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi tạo/lấy conversation: $e',
        name: 'FirestoreService',
      );
      rethrow;
    }
  }

  /// Lấy danh sách conversations của user (real-time)
  Stream<List<Map<String, dynamic>>> getUserConversationsStream(
    String userId,
  ) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final conversations = <Map<String, dynamic>>[];

      // Sort in-memory instead of using Firestore orderBy with arrayContains
      final sortedDocs = snapshot.docs.toList();
      sortedDocs.sort((a, b) {
        final timeA = a['updatedAt'] as Timestamp? ?? Timestamp.now();
        final timeB = b['updatedAt'] as Timestamp? ?? Timestamp.now();
        return timeB.compareTo(timeA); // Descending order
      });

      for (var doc in sortedDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final participants = (data['participants'] as List<dynamic>)
            .map((p) => p as String)
            .toList();
        
        final otherUserId =
            participants.firstWhere((id) => id != userId, orElse: () => '');

        if (otherUserId.isNotEmpty) {
          final otherUser = await _firestore
              .collection('users')
              .doc(otherUserId)
              .get()
              .then((userDoc) {
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              userData['id'] = userDoc.id;
              developer.log(
                '[v0] Found user: ${userData['name']} (${userData['id']})',
                name: 'FirestoreService',
              );
              return userData;
            } else {
              developer.log(
                '[v0] User not found in Firestore: $otherUserId',
                name: 'FirestoreService',
              );
              return null;
            }
          }).catchError((e) {
            developer.log(
              '[v0] Error fetching user $otherUserId: $e',
              name: 'FirestoreService',
            );
            return null;
          });

          conversations.add({
            'id': doc.id,
            'otherUser': otherUser ?? {
              'id': otherUserId,
              'name': 'User',
              'avatar': 'https://via.placeholder.com/150?text=No+Avatar',
            },
            'lastMessage': data['lastMessage'] ?? '',
            'lastMessageTime': data['lastMessageTime'],
            'lastSenderId': data['lastSenderId'] ?? '',
            'createdAt': data['createdAt'],
            'updatedAt': data['updatedAt'],
          });
        }
      }

      return conversations;
    });
  }

  /// Đánh dấu tin nhắn là đã đọc
  Future<bool> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      // Fetch messages without isNotEqualTo operator
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      
      // Filter in-memory to exclude messages from the current user
      for (var doc in snapshot.docs) {
        final senderId = doc['senderId'] as String?;
        if (senderId != null && senderId != userId) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();

      developer.log(
        '[v0] Đánh dấu tin nhắn là đã đọc',
        name: 'FirestoreService',
      );
      return true;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi đánh dấu tin nhắn: $e',
        name: 'FirestoreService',
      );
      return false;
    }
  }

  /// Xóa tin nhắn
  Future<bool> deleteMessage(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .delete();

      developer.log(
        '[v0] Tin nhắn đã được xóa: $messageId',
        name: 'FirestoreService',
      );
      return true;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi xóa tin nhắn: $e',
        name: 'FirestoreService',
      );
      return false;
    }
  }

  /// Đếm số tin nhắn chưa đọc của user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final conversationsSnapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .get();

      int totalUnread = 0;

      for (var convDoc in conversationsSnapshot.docs) {
        final messagesSnapshot = await _firestore
            .collection('conversations')
            .doc(convDoc.id)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .count()
            .get();

        totalUnread += messagesSnapshot.count ?? 0;
      }

      return totalUnread;
    } catch (e) {
      developer.log(
        '[v0] Lỗi khi đếm tin nhắn chưa đọc: $e',
        name: 'FirestoreService',
      );
      return 0;
    }
  }

  /// Thêm method để lấy bài viết từ những người đã follow
  /// Lấy danh sách bài viết từ tất cả những người mà user đang follow
  Stream<List<Post>> getFollowingPostsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .asyncExpand((followingSnapshot) {
      // Mỗi document ID trong following chính là userId của người đang follow
      final followingUserIds = followingSnapshot.docs
          .map((doc) => doc.id) // ✅ Dùng doc.id thay vì doc['followedUserId']
          .toList();

      print('[v0] Following users: $followingUserIds'); // ✅ Debug log

      if (followingUserIds.isEmpty) {
        // Nếu không follow ai, trả về stream rỗng
        return Stream.value(<Post>[]);
      }

      return _postsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final allPosts = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return Post.fromJson(data);
            })
            .toList();

        // ✅ Filter client-side để lấy chỉ posts từ những user đang follow
        final followingPosts = allPosts
            .where((post) => followingUserIds.contains(post.user.id))
            .toList();

        print('[v0] Found ${followingPosts.length} posts from ${followingUserIds.length} following users');
        return followingPosts;
      });
    });
  }
}
