import '../models/comment.dart';
class Manga {
  final String id;
  final String title;
  final String cover;
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
    this.totalRatings = 0,
    this.comments = const [],
  });
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
}