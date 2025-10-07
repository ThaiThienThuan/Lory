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
}
