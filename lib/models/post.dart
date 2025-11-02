import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'community.dart';

class Post {
  final String id;
  final User user;
  final String content;
  final List<String> images;
  final List<String> tags;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final String? mangaReference;
  final Community? community;
  final String? sharedFromUserId; // Add field to track original post author
  final String? sharedFromPostId; // Add field to track original post ID

  Post({
    required this.id,
    required this.user,
    required this.content,
    required this.images,
    this.tags = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.mangaReference,
    this.community,
    this.sharedFromUserId,
    this.sharedFromPostId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      createdAt: _parseDateTime(json['createdAt']),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      mangaReference: json['mangaReference'] as String?,
      community: json['community'] != null
          ? Community.fromJson(json['community'] as Map<String, dynamic>)
          : null,
      sharedFromUserId: json['sharedFromUserId'] as String?, // Parse shared info
      sharedFromPostId: json['sharedFromPostId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'content': content,
      'images': images,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'mangaReference': mangaReference,
      'community': community?.toJson(),
      'sharedFromUserId': sharedFromUserId, // Include in JSON
      'sharedFromPostId': sharedFromPostId,
    };
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else {
      return DateTime.now();
    }
  }

  int get totalInteractions => likes + comments + shares;

  Post copyWith({
    String? id,
    User? user,
    String? content,
    List<String>? images,
    List<String>? tags,
    DateTime? createdAt,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    String? mangaReference,
    Community? community,
    String? sharedFromUserId,
    String? sharedFromPostId,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      mangaReference: mangaReference ?? this.mangaReference,
      community: community ?? this.community,
      sharedFromUserId: sharedFromUserId ?? this.sharedFromUserId, // Add to copyWith
      sharedFromPostId: sharedFromPostId ?? this.sharedFromPostId,
    );
  }
}
