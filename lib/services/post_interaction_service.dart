import 'package:cloud_firestore/cloud_firestore.dart';

class PostInteractionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== LIKES =====

  /// Check if user liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final doc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Stream để listen realtime like status
  Stream<bool> userLikeStream(String postId, String userId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Toggle like
  Future<void> toggleLike(String postId, String userId) async {
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final postRef = _firestore.collection('posts').doc(postId);

    try {
      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // Unlike: Xóa like và giảm count
        await likeRef.delete();
        await postRef.update({
          'likes': FieldValue.increment(-1),
        });
      } else {
        // Like: Thêm like và tăng count
        await likeRef.set({
          'likedAt': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Không thể like bài viết');
    }
  }

  // ===== GET USERS WHO LIKED =====

  /// Get list of users who liked a post
  Future<List<String>> getUsersWhoLiked(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }
}
