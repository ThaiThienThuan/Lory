import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

// Script để xóa toàn bộ dữ liệu manga trong Firestore
void main() async {
  print('[v0] Bắt đầu xóa dữ liệu manga...');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final firestore = FirebaseFirestore.instance;
  
  // Lấy tất cả documents trong collection manga
  final snapshot = await firestore.collection('manga').get();
  
  print('[v0] Tìm thấy ${snapshot.docs.length} truyện');
  
  if (snapshot.docs.isEmpty) {
    print('[v0] Không có dữ liệu để xóa!');
    return;
  }
  
  int deletedCount = 0;
  
  // Xóa từng document
  for (var doc in snapshot.docs) {
    try {
      await doc.reference.delete();
      deletedCount++;
      print('[v0] ✓ Đã xóa: ${doc.data()['title']} (ID: ${doc.id})');
    } catch (e) {
      print('[v0] ✗ Lỗi khi xóa ${doc.id}: $e');
    }
  }
  
  print('\n[v0] ========== KẾT QUẢ ==========');
  print('[v0] Đã xóa: $deletedCount truyện');
  print('[v0] Hoàn tất xóa dữ liệu!');
  print('[v0] ================================\n');
}
