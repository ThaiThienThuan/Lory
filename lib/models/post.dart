import 'user.dart';
class Post {
  final String id;
  final User user;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final String? mangaReference; 

  Post({
    required this.id,
    required this.user,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    this.mangaReference,
  });
}