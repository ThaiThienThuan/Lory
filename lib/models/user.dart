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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String,
      followers: json['followers'] as int,
      following: json['following'] as int,
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'followers': followers,
      'following': following,
      'favoriteGenres': favoriteGenres,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? bio,
    int? followers,
    int? following,
    List<String>? favoriteGenres,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
    );
  }
}
