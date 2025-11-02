// Model cho bình luận
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;

  final String? parentId; // ID của comment cha (null nếu là root comment)
  final List<Comment> replies; // List các reply con

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.parentId, // ✅ THÊM
    this.replies = const [], // ✅ THÊM
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] != null ? DateTime.now() : DateTime.now()),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      parentId: json['parentId'], // ✅ THÊM
      replies: (json['replies'] as List<dynamic>?) // ✅ THÊM
              ?.map((r) => Comment.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
      'parentId': parentId, // ✅ THÊM
      'replies': replies.map((r) => r.toJson()).toList(), // ✅ THÊM
    };
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
    String? parentId,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }
}
