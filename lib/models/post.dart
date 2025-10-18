import 'user.dart';
import 'community.dart';

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
  final Community? community;

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
    this.community,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      shares: json['shares'] as int,
      isLiked: json['isLiked'] as bool? ?? false,
      mangaReference: json['mangaReference'] as String?,
      community: json['community'] != null
          ? Community.fromJson(json['community'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'content': content,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'mangaReference': mangaReference,
      'community': community?.toJson(),
    };
  }
}
