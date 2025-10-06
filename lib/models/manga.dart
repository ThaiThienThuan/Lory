class Manga {
  final String id;
  final String title;
  final String cover;
  final String description;
  final List<String> genres;
  final double rating;
  final int views;
  final String author;
  final String status; // ongoing, completed, hiatus
  final List<Chapter> chapters;
  final bool isFollowed;
  final bool isLiked;

  Manga({
    required this.id,
    required this.title,
    required this.cover,
    required this.description,
    required this.genres,
    required this.rating,
    required this.views,
    required this.author,
    required this.status,
    required this.chapters,
    this.isFollowed = false,
    this.isLiked = false,
  });
}

class Chapter {
  final String id;
  final String title;
  final int number;
  final String releaseDate;
  final List<String> pages;
  final bool isRead;

  Chapter({
    required this.id,
    required this.title,
    required this.number,
    required this.releaseDate,
    required this.pages,
    this.isRead = false,
  });
}