// Model cho cộng đồng/nhóm
class Community {
  final String id;
  final String name;
  final String avatar;
  final String description;
  final int memberCount;
  final bool isJoined;
  final bool isPrivate;
  final String adminId;

  Community({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.memberCount,
    this.isJoined = false,
    this.isPrivate = false,
    required this.adminId,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      description: json['description'] as String,
      memberCount: json['memberCount'] as int,
      isJoined: json['isJoined'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      adminId: json['adminId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'description': description,
      'memberCount': memberCount,
      'isJoined': isJoined,
      'isPrivate': isPrivate,
      'adminId': adminId,
    };
  }
}
