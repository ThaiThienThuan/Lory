import '../models/comment.dart';

class Manga {
  final String id;
  final String title;
  final String coverImage;
  final String description;
  final List<String> genres;
  final double rating;
  final int views;
  final String author;
  final String status;
  final List<Chapter> chapters;
  final bool isFollowed;
  final bool isLiked;
  final int totalRatings;
  final List<Comment> comments;
  final String? uploaderId;

  Manga({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.description,
    required this.genres,
    required this.rating,
    required this.views,
    required this.author,
    required this.status,
    required this.chapters,
    this.isFollowed = false,
    this.isLiked = false,
    this.totalRatings = 0,
    this.comments = const [],
    this.uploaderId,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    // Logic an toàn: Ưu tiên 'coverImage' (Firestore),
    // nếu không có, lấy 'cover' (Mock data), nếu cả hai đều null/rỗng thì mặc định là ''.
    final String safeCoverUrl =
        (json['coverImage'] as String?) ?? (json['cover'] as String?) ?? '';

    return Manga(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      // Sử dụng biến đã được xử lý an toàn
      coverImage: safeCoverUrl,
      description: json['description'] as String? ?? 'Không có mô tả',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: ((json['rating'] as num?) ?? 0).toDouble(),
      views: json['views'] as int? ?? 0,
      author: json['author'] as String? ?? 'Không rõ tác giả',
      status: json['status'] as String? ?? 'Đang ra',
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isFollowed: json['isFollowed'] as bool? ?? false,
      isLiked: json['isLiked'] as bool? ?? false,
      totalRatings: json['totalRatings'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uploaderId: json['uploaderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverImage': coverImage,
      'description': description,
      'genres': genres,
      'rating': rating,
      'views': views,
      'author': author,
      'status': status,
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'isFollowed': isFollowed,
      'isLiked': isLiked,
      'totalRatings': totalRatings,
      'comments': comments.map((e) => e.toJson()).toList(),
      'uploaderId': uploaderId,
    };
  }

  Manga copyWith({
    String? id,
    String? title,
    String? coverImage,
    String? description,
    List<String>? genres,
    double? rating,
    int? views,
    String? author,
    String? status,
    List<Chapter>? chapters,
    bool? isFollowed,
    bool? isLiked,
    int? totalRatings,
    List<Comment>? comments,
    String? uploaderId,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      author: author ?? this.author,
      status: status ?? this.status,
      chapters: chapters ?? this.chapters,
      isFollowed: isFollowed ?? this.isFollowed,
      isLiked: isLiked ?? this.isLiked,
      totalRatings: totalRatings ?? this.totalRatings,
      comments: comments ?? this.comments,
      uploaderId: uploaderId ?? this.uploaderId,
    );
  }

  factory Manga.empty() {
    return Manga(
      id: '',
      title: 'Không có tiêu đề',
      coverImage: '',
      description: 'Không có mô tả',
      genres: [],
      rating: 0,
      views: 0,
      author: 'Không rõ tác giả',
      status: 'Đang ra',
      chapters: [],
      isFollowed: false,
      isLiked: false,
      totalRatings: 0,
      comments: [],
      uploaderId: null,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final int number;
  final String releaseDate;
  final List<String> pages;
  final bool isRead;
  final int likes;
  final bool isLiked;
  final List<Comment> comments;

  Chapter({
    required this.id,
    required this.title,
    required this.number,
    required this.releaseDate,
    required this.pages,
    this.isRead = false,
    this.likes = 0,
    this.isLiked = false,
    this.comments = const [],
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Chương không có tiêu đề',
      number: json['number'] as int? ?? 0,
      releaseDate: json['releaseDate'] as String? ?? '',
      pages:
          (json['pages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      isRead: json['isRead'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'number': number,
      'releaseDate': releaseDate,
      'pages': pages,
      'isRead': isRead,
      'likes': likes,
      'isLiked': isLiked,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }
}
