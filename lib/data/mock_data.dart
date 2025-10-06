import '../models/user.dart';
import '../models/manga.dart';
import '../models/post.dart';

class MockData {
  // Dữ liệu người dùng mẫu
  static final List<User> users = [
    User(
      id: '1',
      name: 'Akira Tanaka',
      avatar: '/placeholder.svg?height=50&width=50',
      bio: 'Người đam mê truyện tranh | Yêu thích thể loại hành động và lãng mạn',
      followers: 1250,
      following: 340,
      favoriteGenres: ['Action', 'Romance', 'Drama'],
    ),
    User(
      id: '2',
      name: 'Sakura Yamamoto',
      avatar: '/placeholder.svg?height=50&width=50',
      bio: 'Họa sĩ và nhà phê bình truyện tranh | Đang vẽ câu chuyện của riêng mình',
      followers: 2100,
      following: 180,
      favoriteGenres: ['Slice of Life', 'Comedy', 'Romance'],
    ),
    User(
      id: '3',
      name: 'Hiroshi Sato',
      avatar: '/placeholder.svg?height=50&width=50',
      bio: 'Người sưu tập truyện tranh hiếm | 15 năm kinh nghiệm đọc truyện',
      followers: 890,
      following: 420,
      favoriteGenres: ['Horror', 'Mystery', 'Thriller'],
    ),
  ];

  // Dữ liệu truyện tranh mẫu
  static final List<Manga> mangaList = [
    Manga(
      id: '1',
      title: 'Di Sản Rồng Thiêng',
      cover: '/placeholder.svg?height=300&width=200',
      description: 'Một chiến binh trẻ khám phá ra mối liên hệ của mình với những con rồng cổ đại và phải cứu thế giới khỏi một phù thủy tà ác đang đe dọa phá hủy mọi thứ anh ta yêu quý.',
      genres: ['Action', 'Fantasy', 'Adventure', 'Manga'],
      rating: 4.8,
      views: 125000,
      author: 'Kenji Nakamura',
      status: 'ongoing',
      chapters: [
        Chapter(
          id: '1-1',
          title: 'Sự Thức Tỉnh',
          number: 1,
          releaseDate: '2024-01-15',
          pages: [
            '/placeholder.svg?height=800&width=600',
            '/placeholder.svg?height=800&width=600',
            '/placeholder.svg?height=800&width=600',
          ],
        ),
        Chapter(
          id: '1-2',
          title: 'Trận Chiến Đầu Tiên',
          number: 2,
          releaseDate: '2024-01-22',
          pages: [
            '/placeholder.svg?height=800&width=600',
            '/placeholder.svg?height=800&width=600',
          ],
        ),
      ],
      isFollowed: true,
      isLiked: true,
    ),
    Manga(
      id: '2',
      title: 'Tình Yêu Tuổi 17',
      cover: '/placeholder.svg?height=300&width=200',
      description: 'Một câu chuyện ấm áp về tình yêu tuổi teen, tình bạn và trưởng thành ở Tokyo hiện đại. Theo chân Yuki và những người bạn qua năm cuối cấp ba.',
      genres: ['Romance', 'Slice of Life', 'Comedy', 'Manga'],
      rating: 4.6,
      views: 89000,
      author: 'Miki Taniguchi',
      status: 'ongoing',
      chapters: [
        Chapter(
          id: '2-1',
          title: 'Học Kỳ Mới',
          number: 1,
          releaseDate: '2024-02-01',
          pages: [
            '/placeholder.svg?height=800&width=600',
            '/placeholder.svg?height=800&width=600',
          ],
        ),
      ],
      isFollowed: false,
      isLiked: false,
    ),
    Manga(
      id: '3',
      title: 'Biên Niên Sử Ninja Mạng',
      cover: '/placeholder.svg?height=300&width=200',
      description: 'Trong một tương lai dystopia nơi công nghệ và võ thuật cổ đại va chạm, một ninja trẻ phải điều hướng thế giới ngầm kỹ thuật số để khám phá một âm mưu.',
      genres: ['Action', 'Sci-Fi', 'Thriller', 'Manga'],
      rating: 4.7,
      views: 156000,
      author: 'Ryo Ishikawa',
      status: 'completed',
      chapters: [
        Chapter(
          id: '3-1',
          title: 'Bóng Tối Kỹ Thuật Số',
          number: 1,
          releaseDate: '2023-12-10',
          pages: [
            '/placeholder.svg?height=800&width=600',
            '/placeholder.svg?height=800&width=600',
          ],
        ),
      ],
      isFollowed: true,
      isLiked: false,
    ),
    Manga(
      id: '4',
      title: 'Học Viện Nữ Phù Thủy',
      cover: '/placeholder.svg?height=300&width=200',
      description: 'Những cô gái trẻ với sức mạnh phép thuật theo học tại một học viện đặc biệt để học cách bảo vệ thế giới khỏi các thế lực đen tối trong khi đối phó với những vấn đề tuổi teen thông thường.',
      genres: ['Magic', 'Comedy', 'Friendship', 'Manhwa'],
      rating: 4.4,
      views: 67000,
      author: 'Yui Matsumoto',
      status: 'ongoing',
      chapters: [
        Chapter(
          id: '4-1',
          title: 'Chào Mừng Đến Học Viện',
          number: 1,
          releaseDate: '2024-01-30',
          pages: [
            '/placeholder.svg?height=800&width=600',
            '/placeholder.svg?height=800&width=600',
          ],
        ),
      ],
      isFollowed: false,
      isLiked: true,
    ),
  ];

  // Dữ liệu bài đăng mẫu
  static final List<Post> posts = [
    Post(
      id: '1',
      user: users[0],
      content: 'Vừa đọc xong chương mới nhất của Di Sản Rồng Thiêng! Tình tiết bất ngờ thật không thể tin được! 🔥 Không thể chờ đợi chương tiếp theo!',
      images: ['/placeholder.svg?height=300&width=400'],
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      likes: 45,
      comments: 12,
      shares: 8,
      isLiked: true,
      mangaReference: '1',
    ),
    Post(
      id: '2',
      user: users[1],
      content: 'Đang vẽ fan art cho Tình Yêu Tuổi 17! Đây là cách tôi hình dung Yuki-chan 💕',
      images: ['/placeholder.svg?height=400&width=300'],
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      likes: 78,
      comments: 23,
      shares: 15,
      isLiked: false,
      mangaReference: '2',
    ),
    Post(
      id: '3',
      user: users[2],
      content: 'Bộ sưu tập truyện tranh của tôi đang phát triển! Vừa thêm 5 tập mới vào kệ. Có ai gợi ý truyện kinh dị hay không?',
      images: ['/placeholder.svg?height=300&width=400'],
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
      likes: 32,
      comments: 18,
      shares: 5,
      isLiked: true,
    ),
    Post(
      id: '4',
      user: users[0],
      content: 'Biên Niên Sử Ninja Mạng có những cảnh hành động hay nhất mà tôi từng thấy trong truyện tranh! Phong cách nghệ thuật thật tuyệt vời.',
      images: [],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      likes: 56,
      comments: 9,
      shares: 12,
      isLiked: false,
      mangaReference: '3',
    ),
  ];

  // Truyện tranh nổi bật cho banner
  static List<Manga> get featuredManga => mangaList.take(3).toList();

  // Thể loại phổ biến
  static final List<String> popularGenres = [
    'Action',
    'Romance',
    'Comedy',
    'Fantasy',
    'Slice of Life',
    'Horror',
    'Sci-Fi',
    'Mystery',
    'Drama',
    'Adventure',
    'Manga',
    'Manhwa',
    'Manhua',
  ];
}