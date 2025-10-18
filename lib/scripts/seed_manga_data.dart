import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';
import '../models/manga.dart';

// Script để thêm dữ liệu truyện mẫu vào Firestore
void main() async {
  print('[v0] Bắt đầu seed dữ liệu manga...');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firestore = FirebaseFirestore.instance;
  
  // Danh sách truyện mẫu
  final sampleMangas = [
    {
      'title': 'One Piece',
      'author': 'Eiichiro Oda',
      'description': 'Câu chuyện về Monkey D. Luffy và băng hải tặc Mũ Rơm trong hành trình tìm kiếm kho báu One Piece để trở thành Vua Hải Tặc.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/2/253146.jpg',
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'status': 'Đang ra',
      'views': 1500000,
      'rating': 4.9,
      'isFeatured': true,
      'isHot': true,
    },
    {
      'title': 'Naruto',
      'author': 'Masashi Kishimoto',
      'description': 'Câu chuyện về Uzumaki Naruto, một ninja trẻ với ước mơ tr��� thành Hokage - người lãnh đạo mạnh nhất làng Lá.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/3/249658.jpg',
      'genres': ['Action', 'Adventure', 'Martial Arts'],
      'status': 'Hoàn thành',
      'views': 2000000,
      'rating': 4.8,
      'isFeatured': true,
      'isHot': true,
    },
    {
      'title': 'Attack on Titan',
      'author': 'Hajime Isayama',
      'description': 'Nhân loại sống trong những bức tường khổng lồ để tránh những Titan khổng lồ ăn thịt người. Eren Yeager quyết tâm tiêu diệt tất cả Titan.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/2/37846.jpg',
      'genres': ['Action', 'Drama', 'Fantasy', 'Horror'],
      'status': 'Hoàn thành',
      'views': 1800000,
      'rating': 4.9,
      'isFeatured': true,
      'isHot': true,
    },
    {
      'title': 'My Hero Academia',
      'author': 'Kohei Horikoshi',
      'description': 'Trong thế giới mà 80% dân số có siêu năng lực, Izuku Midoriya sinh ra không có năng lực nhưng vẫn mơ ước trở thành anh hùng.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/1/209370.jpg',
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'status': 'Đang ra',
      'views': 1200000,
      'rating': 4.7,
      'isFeatured': false,
      'isHot': true,
    },
    {
      'title': 'Demon Slayer',
      'author': 'Koyoharu Gotouge',
      'description': 'Tanjiro Kamado trở thành thợ săn quỷ để tìm cách cứu em gái đã biến thành quỷ và trả thù cho gia đình.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/3/179023.jpg',
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'status': 'Hoàn thành',
      'views': 1600000,
      'rating': 4.8,
      'isFeatured': true,
      'isHot': true,
    },
    {
      'title': 'Tokyo Ghoul',
      'author': 'Sui Ishida',
      'description': 'Ken Kaneki trở thành nửa người nửa ghoul sau một tai nạn và phải học cách sống trong thế giới đen tối của những sinh vật ăn thịt người.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/3/54525.jpg',
      'genres': ['Action', 'Horror', 'Mystery', 'Drama'],
      'status': 'Hoàn thành',
      'views': 1400000,
      'rating': 4.6,
      'isFeatured': false,
      'isHot': true,
    },
    {
      'title': 'Death Note',
      'author': 'Tsugumi Ohba',
      'description': 'Light Yagami tìm thấy một cuốn sổ có khả năng giết người chỉ bằng cách viết tên họ vào đó.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/2/253119.jpg',
      'genres': ['Mystery', 'Thriller', 'Drama'],
      'status': 'Hoàn thành',
      'views': 1700000,
      'rating': 4.9,
      'isFeatured': true,
      'isHot': false,
    },
    {
      'title': 'Fullmetal Alchemist',
      'author': 'Hiromu Arakawa',
      'description': 'Hai anh em Edward và Alphonse Elric tìm kiếm Hòn đá Hiền giả để khôi phục cơ thể của họ sau một thí nghiệm giả kim thuật thất bại.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/3/243675.jpg',
      'genres': ['Action', 'Adventure', 'Drama', 'Fantasy'],
      'status': 'Hoàn thành',
      'views': 1300000,
      'rating': 4.9,
      'isFeatured': false,
      'isHot': false,
    },
    {
      'title': 'Jujutsu Kaisen',
      'author': 'Gege Akutami',
      'description': 'Yuji Itadori nuốt một ngón tay bị nguyền rủa và trở thành vật chứa của Sukuna, vua của những lời nguyền.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/3/210341.jpg',
      'genres': ['Action', 'Fantasy', 'Horror'],
      'status': 'Đang ra',
      'views': 1100000,
      'rating': 4.7,
      'isFeatured': false,
      'isHot': true,
    },
    {
      'title': 'Chainsaw Man',
      'author': 'Tatsuki Fujimoto',
      'description': 'Denji hợp nhất với con quỷ cưa máy Pochita và trở thành Chainsaw Man, một thợ săn quỷ với sức mạnh đặc biệt.',
      'coverImage': 'https://cdn.myanimelist.net/images/manga/3/216464.jpg',
      'genres': ['Action', 'Horror', 'Drama'],
      'status': 'Hoàn thành',
      'views': 900000,
      'rating': 4.6,
      'isFeatured': false,
      'isHot': true,
    },
  ];
  
  print('[v0] Đang thêm ${sampleMangas.length} truyện vào Firestore...');
  
  int successCount = 0;
  int errorCount = 0;
  
  for (var mangaData in sampleMangas) {
    try {
      // Tạo document mới với ID tự động
      final docRef = await firestore.collection('manga').add({
        ...mangaData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      successCount++;
      print('[v0] ✓ Đã thêm: ${mangaData['title']} (ID: ${docRef.id})');
    } catch (e) {
      errorCount++;
      print('[v0] ✗ Lỗi khi thêm ${mangaData['title']}: $e');
    }
  }
  
  print('\n[v0] ========== KẾT QUẢ ==========');
  print('[v0] Thành công: $successCount truyện');
  print('[v0] Thất bại: $errorCount truyện');
  print('[v0] Hoàn tất seed dữ liệu!');
  print('[v0] ================================\n');
}
