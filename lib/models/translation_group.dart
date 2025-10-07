// Model cho nhóm dịch
class TranslationGroup {
  final String id;
  final String name;
  final String avatar;
  final String description;
  final int members;
  final int mangaCount;
  final bool isFollowing;
  final List<String> adminIds;

  TranslationGroup({
    required this.id,
    required this.name,
    required this.avatar,
    required this.description,
    required this.members,
    required this.mangaCount,
    this.isFollowing = false,
    this.adminIds = const [],
  });
}
