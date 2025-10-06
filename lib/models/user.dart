class User {
  final String id;
  final String name;
  final String avatar;
  final String bio;
  final int followers;
  final int following;
  final List<String> favoriteGenres;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
    required this.favoriteGenres,
  });
}