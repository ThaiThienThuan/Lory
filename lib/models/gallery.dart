// Model cho Gallery (Fanart)
class GalleryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String artistId;
  final String artistName;
  final String artistAvatar;
  final String? mangaReference;
  final String? mangaTitle;
  final DateTime createdAt;
  final int likes;
  final int views;
  final bool isLiked;
  final List<String> tags;

  GalleryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.artistId,
    required this.artistName,
    required this.artistAvatar,
    this.mangaReference,
    this.mangaTitle,
    required this.createdAt,
    this.likes = 0,
    this.views = 0,
    this.isLiked = false,
    this.tags = const [],
  });
}
