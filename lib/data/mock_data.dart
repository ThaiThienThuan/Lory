import '../models/user.dart';

import '../models/manga.dart';

import '../models/post.dart';

import '../models/comment.dart'; // Import Comment model

import '../models/gallery.dart'; // Import Gallery model

import '../models/translation_group.dart'; // Import TranslationGroup model

import '../models/community.dart';

import '../models/message.dart';
import '../models/conversation.dart'; // Import Conversation model

class MockData {
  // Dữ liệu người dùng mẫu
  static final List<User> users = [
    User(
      id: '1',
      name: 'Akira Tanaka',
      avatar: 'https://i.pravatar.cc/150?img=1',
      bio:
          'Người đam mê truyện tranh | Yêu thích thể loại hành động và lãng mạn',
      followers: 1250,
      following: 340,
      favoriteGenres: ['Action', 'Romance', 'Drama'],
    ),
    User(
      id: '2',
      name: 'Sakura Yamamoto',
      avatar: 'https://i.pravatar.cc/150?img=5',
      bio:
          'Họa sĩ và nhà phê bình truyện tranh | Đang vẽ câu chuyện của riêng mình',
      followers: 2100,
      following: 180,
      favoriteGenres: ['Slice of Life', 'Comedy', 'Romance'],
    ),
    User(
      id: '3',
      name: 'Hiroshi Sato',
      avatar: 'https://i.pravatar.cc/150?img=12',
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
      coverImage: 'https://picsum.photos/seed/manga1/200/300',
      description:
          'Một chiến binh trẻ khám phá ra mối liên hệ của mình với những con rồng cổ đại và phải cứu thế giới khỏi một phù thủy tà ác đang đe dọa phá hủy mọi thứ anh ta yêu quý.',
      genres: ['Action', 'Fantasy', 'Adventure', 'Manga'],
      rating: 4.8,
      views: 125000,
      author: 'Kenji Nakamura',
      status: 'Đang ra',
      totalRatings: 1250,
      comments: [
        Comment(
          id: 'c1',
          userId: '1',
          userName: 'Akira Tanaka',
          userAvatar: 'https://i.pravatar.cc/150?img=1',
          content:
              'Truyện hay quá! Đồ họa đẹp và cốt truyện hấp dẫn. Rất đáng đọc!',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          likes: 15,
          isLiked: true,
        ),
        Comment(
          id: 'c2',
          userId: '2',
          userName: 'Sakura Yamamoto',
          userAvatar: 'https://i.pravatar.cc/150?img=5',
          content:
              'Nhân vật chính rất được phát triển tốt. Mong chờ chương tiếp theo!',
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
          likes: 8,
        ),
      ],
      chapters: [
        Chapter(
          id: '1-1',
          title: 'Sự Thức Tỉnh',
          number: 1,
          releaseDate: '2 giờ trước',
          pages: List.generate(
              15, (i) => 'https://picsum.photos/seed/page${i}/600/800'),
          likes: 234,
          isLiked: false,
          comments: [
            Comment(
              id: 'cc1',
              userId: '3',
              userName: 'Hiroshi Sato',
              userAvatar: 'https://i.pravatar.cc/150?img=12',
              content: 'Chương mở đầu rất ấn tượng!',
              createdAt: DateTime.now().subtract(Duration(minutes: 30)),
              likes: 5,
            ),
          ],
        ),
        Chapter(
          id: '1-2',
          title: 'Trận Chiến Đầu Tiên',
          number: 2,
          releaseDate: '1 ngày trước',
          pages: List.generate(
              18, (i) => 'https://picsum.photos/seed/page${i + 15}/600/800'),
          likes: 189,
          comments: [],
        ),
        Chapter(
          id: '1-3',
          title: 'Sức Mạnh Tiềm Ẩn',
          number: 3,
          releaseDate: '3 ngày trước',
          pages: List.generate(
              20, (i) => 'https://picsum.photos/seed/page${i + 33}/600/800'),
          likes: 156,
          comments: [],
        ),
      ],
      isFollowed: true,
      isLiked: false,
    ),
    Manga(
      id: '2',
      title: 'Tình Yêu Tuổi 17',
      coverImage: 'https://picsum.photos/seed/manga2/200/300',
      description:
          'Một câu chuyện ấm áp về tình yêu tuổi teen, tình bạn và trưởng thành ở Tokyo hiện đại. Theo chân Yuki và những người bạn qua năm cuối cấp ba.',
      genres: ['Romance', 'Slice of Life', 'Comedy', 'Manga'],
      rating: 4.6,
      views: 89000,
      author: 'Miki Taniguchi',
      status: 'Đang ra',
      totalRatings: 890,
      comments: [],
      chapters: [
        Chapter(
          id: '2-1',
          title: 'Học Kỳ Mới',
          number: 1,
          releaseDate: '5 giờ trước',
          pages: List.generate(
              16, (i) => 'https://picsum.photos/seed/page2${i}/600/800'),
          likes: 145,
          comments: [],
        ),
        Chapter(
          id: '2-2',
          title: 'Cuộc Gặp Gỡ Định Mệnh',
          number: 2,
          releaseDate: '2 ngày trước',
          pages: List.generate(
              17, (i) => 'https://picsum.photos/seed/page2${i + 16}/600/800'),
          likes: 132,
          comments: [],
        ),
      ],
      isFollowed: false,
      isLiked: false,
    ),
    Manga(
      id: '3',
      title: 'Biên Niên Sử Ninja Mạng',
      coverImage: 'https://picsum.photos/seed/manga3/200/300',
      description:
          'Trong một tương lai dystopia nơi công nghệ và võ thuật cổ đại va chạm, một ninja trẻ phải điều hướng thế giới ngầm kỹ thuật số để khám phá một âm mưu.',
      genres: ['Action', 'Sci-Fi', 'Thriller', 'Manga'],
      rating: 4.7,
      views: 156000,
      author: 'Ryo Ishikawa',
      status: 'Hoàn thành',
      totalRatings: 1560,
      comments: [],
      chapters: [
        Chapter(
          id: '3-1',
          title: 'Bóng Tối Kỹ Thuật Số',
          number: 1,
          releaseDate: '1 tuần trước',
          pages: List.generate(
              22, (i) => 'https://picsum.photos/seed/page3${i}/600/800'),
          likes: 278,
          comments: [],
        ),
      ],
      isFollowed: true,
      isLiked: false,
    ),
    Manga(
      id: '4',
      title: 'Học Viện Nữ Phù Thủy',
      coverImage: 'https://picsum.photos/seed/manga4/200/300',
      description:
          'Những cô gái trẻ với sức mạnh phép thuật theo học tại một học viện đặc biệt để học cách bảo vệ thế giới khỏi các thế lực đen tối trong khi đối phó với những vấn đề tuổi teen thông thường.',
      genres: ['Magic', 'Comedy', 'Friendship', 'Manhwa'],
      rating: 4.4,
      views: 67000,
      author: 'Yui Matsumoto',
      status: 'Đang ra',
      totalRatings: 670,
      comments: [],
      chapters: [
        Chapter(
          id: '4-1',
          title: 'Chào Mừng Đến Học Viện',
          number: 1,
          releaseDate: '3 giờ trước',
          pages: List.generate(
              19, (i) => 'https://picsum.photos/seed/page4${i}/600/800'),
          likes: 98,
          comments: [],
        ),
      ],
      isFollowed: false,
      isLiked: false,
    ),
    Manga(
      id: '5',
      title: 'Võ Thần Truyền Kỳ',
      coverImage: 'https://picsum.photos/seed/manga5/200/300',
      description:
          'Hành trình tu luyện của một thiếu niên từ kẻ yếu đuối trở thành võ thần tối cao, chinh phục các đỉnh cao võ học và bảo vệ người thân.',
      genres: ['Action', 'Martial Arts', 'Adventure', 'Manhua'],
      rating: 4.9,
      views: 234000,
      author: 'Chen Wei',
      status: 'Đang ra',
      totalRatings: 2340,
      comments: [],
      chapters: [
        Chapter(
          id: '5-1',
          title: 'Khởi Đầu Tu Luyện',
          number: 1,
          releaseDate: '1 giờ trước',
          pages: List.generate(
              25, (i) => 'https://picsum.photos/seed/page5${i}/600/800'),
          likes: 456,
          comments: [],
        ),
      ],
      isFollowed: true,
      isLiked: false,
    ),
    Manga(
      id: '6',
      title: 'Thám Tử Thành Phố',
      coverImage: 'https://picsum.photos/seed/manga6/200/300',
      description:
          'Một thám tử tài ba giải quyết những vụ án bí ẩn nhất thành phố với trí thông minh phi thường và khả năng quan sát tuyệt vời.',
      genres: ['Mystery', 'Thriller', 'Drama', 'Manga'],
      rating: 4.5,
      views: 98000,
      author: 'Takeshi Yamada',
      status: 'Đang ra',
      totalRatings: 980,
      comments: [],
      chapters: [
        Chapter(
          id: '6-1',
          title: 'Vụ Án Đầu Tiên',
          number: 1,
          releaseDate: '4 giờ trước',
          pages: List.generate(
              21, (i) => 'https://picsum.photos/seed/page6${i}/600/800'),
          likes: 167,
          comments: [],
        ),
      ],
      isFollowed: false,
      isLiked: false,
    ),
  ];

  static final List<Community> communities = [
    Community(
      id: 'cm1',
      name: 'Cộng Đồng Manga Việt',
      avatar: 'https://picsum.photos/seed/community1/400/200',
      description:
          'Cộng đồng yêu thích manga lớn nhất Việt Nam. Nơi chia sẻ đam mê và thảo luận về các bộ manga yêu thích.',
      memberCount: 15420,
      isJoined: true,
      isPrivate: false,
      adminId: '1',
    ),
    Community(
      id: 'cm2',
      name: 'Manhwa Lovers',
      avatar: 'https://picsum.photos/seed/community2/400/200',
      description:
          'Dành cho những người yêu thích manhwa Hàn Quốc. Cập nhật nhanh nhất các bộ manhwa hot.',
      memberCount: 8930,
      isJoined: false,
      isPrivate: false,
      adminId: '2',
    ),
    Community(
      id: 'cm3',
      name: 'Manhua Fan Club',
      avatar: 'https://picsum.photos/seed/community3/400/200',
      description:
          'Cộng đồng manhua Trung Quốc. Thảo luận về tu tiên, huyền huyễn và nhiều thể loại khác.',
      memberCount: 6750,
      isJoined: true,
      isPrivate: false,
      adminId: '3',
    ),
  ];

  // Dữ liệu bài đăng mẫu
  static final List<Post> posts = [
    Post(
      id: '1',
      user: users[0],
      content:
          'Vừa đọc xong chương mới nhất của Di Sản Rồng Thiêng! Tình tiết bất ngờ thật không thể tin được! Không thể chờ đợi chương tiếp theo!',
      images: ['https://picsum.photos/seed/post1/400/300'],
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      likes: 45,
      comments: 12,
      shares: 8,
      isLiked: true,
      mangaReference: '1',
      community: communities[0],
    ),
    Post(
      id: '2',
      user: users[1],
      content:
          'Đang vẽ fan art cho Tình Yêu Tuổi 17! Đây là cách tôi hình dung Yuki-chan',
      images: ['https://picsum.photos/seed/post2/300/400'],
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
      likes: 78,
      comments: 23,
      shares: 15,
      isLiked: false,
      mangaReference: '2',
      community: communities[0],
    ),
    Post(
      id: '3',
      user: users[2],
      content:
          'Bộ sưu tập truyện tranh của tôi đang phát triển! Vừa thêm 5 tập mới vào kệ. Có ai gợi ý truyện kinh dị hay không?',
      images: ['https://picsum.photos/seed/post3/400/300'],
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
      likes: 32,
      comments: 18,
      shares: 5,
      isLiked: true,
    ),
    Post(
      id: '4',
      user: users[0],
      content:
          'Biên Niên Sử Ninja Mạng có những cảnh hành động hay nhất mà tôi từng thấy trong truyện tranh! Phong cách nghệ thuật thật tuyệt vời.',
      images: [],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      likes: 56,
      comments: 9,
      shares: 12,
      isLiked: false,
      mangaReference: '3',
      community: communities[1],
    ),
  ];

  static final List<GalleryItem> galleryItems = [
    GalleryItem(
      id: 'g1',
      title: 'Di Sản Rồng Thiêng - Fan Art',
      imageUrl: 'https://picsum.photos/seed/gallery1/300/400',
      artistId: '2',
      artistName: 'Sakura Yamamoto',
      artistAvatar: 'https://i.pravatar.cc/150?img=5',
      mangaReference: '1',
      mangaTitle: 'Di Sản Rồng Thiêng',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      likes: 234,
      views: 1250,
      isLiked: true,
      tags: ['Fanart', 'Digital Art', 'Fantasy'],
    ),
    GalleryItem(
      id: 'g2',
      title: 'Yuki-chan Portrait',
      imageUrl: 'https://picsum.photos/seed/gallery2/300/400',
      artistId: '2',
      artistName: 'Sakura Yamamoto',
      artistAvatar: 'https://i.pravatar.cc/150?img=5',
      mangaReference: '2',
      mangaTitle: 'Tình Yêu Tuổi 17',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      likes: 456,
      views: 2340,
      isLiked: false,
      tags: ['Fanart', 'Romance', 'Watercolor'],
    ),
    GalleryItem(
      id: 'g3',
      title: 'Ninja Cyber Action Scene',
      imageUrl: 'https://picsum.photos/seed/gallery3/300/400',
      artistId: '1',
      artistName: 'Akira Tanaka',
      artistAvatar: 'https://i.pravatar.cc/150?img=1',
      mangaReference: '3',
      mangaTitle: 'Biên Niên Sử Ninja Mạng',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      likes: 189,
      views: 980,
      tags: ['Fanart', 'Action', 'Sci-Fi'],
    ),
    GalleryItem(
      id: 'g4',
      title: 'Witch Academy Group',
      imageUrl: 'https://picsum.photos/seed/gallery4/300/400',
      artistId: '2',
      artistName: 'Sakura Yamamoto',
      artistAvatar: 'https://i.pravatar.cc/150?img=5',
      mangaReference: '4',
      mangaTitle: 'Học Viện Nữ Phù Thủy',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      likes: 312,
      views: 1560,
      tags: ['Fanart', 'Magic', 'Cute'],
    ),
  ];

  static final List<TranslationGroup> translationGroups = [
    TranslationGroup(
      id: 'tg1',
      name: 'Lory Translation Team',
      avatar: 'https://picsum.photos/seed/group1/100/100',
      description:
          'Nhóm dịch chuyên nghiệp với hơn 5 năm kinh nghiệm. Chuyên dịch manga, manhwa, manhua chất lượng cao.',
      members: 15,
      mangaCount: 45,
      isFollowing: true,
    ),
    TranslationGroup(
      id: 'tg2',
      name: 'Dragon Scans',
      avatar: 'https://picsum.photos/seed/group2/100/100',
      description:
          'Nhóm dịch truyện hành động và phiêu lưu. Cập nhật nhanh, chất lượng tốt.',
      members: 8,
      mangaCount: 23,
      isFollowing: false,
    ),
    TranslationGroup(
      id: 'tg3',
      name: 'Romance Lovers',
      avatar: 'https://picsum.photos/seed/group3/100/100',
      description:
          'Chuyên dịch truyện lãng mạn và slice of life. Đội ngũ dịch giả tâm huyết.',
      members: 12,
      mangaCount: 34,
      isFollowing: true,
    ),
  ];

  static final List<Message> messages = [
    Message(
      id: 'm1',
      content: 'Chào bạn! Bạn đã đọc chương mới nhất chưa?',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      isMe: false,
      isRead: true,
    ),
    Message(
      id: 'm2',
      content: 'Rồi, truyện hay quá! Tình tiết bất ngờ thật sự.',
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      isMe: true,
      isRead: true,
    ),
    Message(
      id: 'm3',
      content: 'Đúng vậy! Tôi không ngờ nhân vật chính lại làm thế.',
      timestamp: DateTime.now().subtract(Duration(minutes: 3)),
      isMe: false,
      isRead: true,
    ),
    Message(
      id: 'm4',
      content: 'Chương tiếp theo ra khi nào nhỉ?',
      timestamp: DateTime.now().subtract(Duration(minutes: 2)),
      isMe: true,
      isRead: true,
    ),
    Message(
      id: 'm5',
      content: 'Có lẽ tuần sau. Tôi đang chờ không nổi!',
      timestamp: DateTime.now().subtract(Duration(minutes: 1)),
      isMe: false,
      isRead: false,
    ),
  ];

  static final List<Conversation> conversations = [
    Conversation(
      id: 'cv1',
      user: users[0],
      lastMessage: messages[4],
      unreadCount: 2,
    ),
    Conversation(
      id: 'cv2',
      user: users[1],
      lastMessage: Message(
        id: 'm6',
        content: 'Cảm ơn bạn đã chia sẻ fan art!',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        isMe: false,
        isRead: true,
      ),
      unreadCount: 0,
    ),
    Conversation(
      id: 'cv3',
      user: users[2],
      lastMessage: Message(
        id: 'm7',
        content: 'Bạn có gợi ý truyện kinh dị nào không?',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        isMe: true,
        isRead: true,
      ),
      unreadCount: 0,
    ),
  ];

  static List<Manga> get hotManga =>
      List.from(mangaList)..sort((a, b) => b.views.compareTo(a.views));

  static List<Manga> get recentlyUpdatedManga => List.from(mangaList)
    ..sort((a, b) {
      final aLatest = a.chapters.isNotEmpty ? a.chapters.first.releaseDate : '';
      final bLatest = b.chapters.isNotEmpty ? b.chapters.first.releaseDate : '';
      return bLatest.compareTo(aLatest);
    });

  // Truyện tranh nổi bật cho banner
  static List<Manga> get featuredManga => mangaList.take(4).toList();

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
    'Martial Arts',
    'Magic',
    'Thriller',
    'Friendship',
  ];
}

// Các biến global để dễ truy cập
final mockUsers = MockData.users;
final mockMangaList = MockData.mangaList;
final mockPosts = MockData.posts;
final mockGalleryItems = MockData.galleryItems;
final mockTranslationGroups = MockData.translationGroups;
final mockCommunities = MockData.communities;
final mockMessages = MockData.messages;
final mockConversations = MockData.conversations;
