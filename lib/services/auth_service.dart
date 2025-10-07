import 'package:shared_preferences/shared_preferences.dart';

// Service quản lý xác thực người dùng
class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserId = 'userId';

  // Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Lưu thông tin đăng nhập
  Future<void> saveLoginInfo(String email, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserId, userId);
  }

  // Lấy email người dùng
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Lấy ID người dùng
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Đăng nhập với email và mật khẩu
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    // Giả lập API call
    await Future.delayed(Duration(seconds: 1));
    
    // Kiểm tra thông tin đăng nhập (mock)
    if (email.isNotEmpty && password.length >= 6) {
      await saveLoginInfo(email, 'user_${DateTime.now().millisecondsSinceEpoch}');
      return {'success': true, 'message': 'Đăng nhập thành công!'};
    }
    
    return {'success': false, 'message': 'Email hoặc mật khẩu không đúng'};
  }

  // Đăng nhập với Google (mock)
  Future<Map<String, dynamic>> loginWithGoogle() async {
    await Future.delayed(Duration(seconds: 1));
    
    // Mock Google login
    final email = 'user@gmail.com';
    await saveLoginInfo(email, 'google_user_${DateTime.now().millisecondsSinceEpoch}');
    
    return {'success': true, 'message': 'Đăng nhập Google thành công!'};
  }

  // Đăng ký tài khoản mới
  Future<Map<String, dynamic>> register(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    
    if (email.isNotEmpty && password.length >= 6) {
      return {'success': true, 'message': 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực OTP.'};
    }
    
    return {'success': false, 'message': 'Thông tin không hợp lệ'};
  }

  // Xác thực OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    await Future.delayed(Duration(seconds: 1));
    
    // Mock OTP verification
    if (otp.length == 6) {
      await saveLoginInfo(email, 'user_${DateTime.now().millisecondsSinceEpoch}');
      return {'success': true, 'message': 'Xác thực thành công!'};
    }
    
    return {'success': false, 'message': 'Mã OTP không đúng'};
  }

  // Gửi email khôi phục mật khẩu
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    await Future.delayed(Duration(seconds: 1));
    
    if (email.isNotEmpty) {
      return {'success': true, 'message': 'Email khôi phục đã được gửi!'};
    }
    
    return {'success': false, 'message': 'Email không hợp lệ'};
  }
}
