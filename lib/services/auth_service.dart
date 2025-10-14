import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

// Service quản lý xác thực người dùng
class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserPhotoUrl = 'userPhotoUrl';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Lưu thông tin đăng nhập
  Future<void> saveLoginInfo(String email, String userId, {String? displayName, String? photoUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserId, userId);
    if (displayName != null) {
      await prefs.setString(_keyUserName, displayName);
    }
    if (photoUrl != null) {
      await prefs.setString(_keyUserPhotoUrl, photoUrl);
    }
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

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<String?> getUserPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPhotoUrl);
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          await _auth.signOut();
          return {
            'success': false, 
            'message': 'Email chưa được xác thực. Vui lòng kiểm tra email và click vào link xác thực.',
            'needsVerification': true,
            'email': email,
          };
        }
        
        await saveLoginInfo(
          userCredential.user!.email ?? email,
          userCredential.user!.uid,
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
        );
        return {'success': true, 'message': 'Đăng nhập thành công!'};
      }
      
      return {'success': false, 'message': 'Đăng nhập thất bại'};
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
          break;
        default:
          message = 'Email hoặc mật khẩu không đúng';
      }
      
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Đã xảy ra lỗi: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      developer.log('[v0] Bắt đầu đăng nhập Google', name: 'AuthService');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      developer.log('[v0] GoogleSignInAccount: ${googleUser?.email ?? "null"}', name: 'AuthService');
      
      if (googleUser == null) {
        developer.log('[v0] Người dùng hủy đăng nhập', name: 'AuthService');
        return {'success': false, 'message': 'Đăng nhập bị hủy'};
      }

      developer.log('[v0] Đang lấy authentication details', name: 'AuthService');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      developer.log('[v0] AccessToken: ${googleAuth.accessToken != null ? "có" : "null"}', name: 'AuthService');
      developer.log('[v0] IdToken: ${googleAuth.idToken != null ? "có" : "null"}', name: 'AuthService');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      developer.log('[v0] Đang đăng nhập vào Firebase', name: 'AuthService');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      developer.log('[v0] UserCredential user: ${userCredential.user?.email ?? "null"}', name: 'AuthService');
      
      if (userCredential.user != null) {
        await saveLoginInfo(
          userCredential.user!.email ?? googleUser.email,
          userCredential.user!.uid,
          displayName: userCredential.user!.displayName ?? googleUser.displayName,
          photoUrl: userCredential.user!.photoURL ?? googleUser.photoUrl,
        );
        developer.log('[v0] Đăng nhập thành công!', name: 'AuthService');
        return {'success': true, 'message': 'Đăng nhập Google thành công!'};
      }
      
      developer.log('[v0] UserCredential.user là null', name: 'AuthService');
      return {'success': false, 'message': 'Đăng nhập thất bại'};
    } on FirebaseAuthException catch (e) {
      developer.log('[v0] FirebaseAuthException: ${e.code} - ${e.message}', name: 'AuthService');
      String message = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Tài khoản đã tồn tại với phương thức đăng nhập khác';
          break;
        case 'invalid-credential':
          message = 'Thông tin xác thực không hợp lệ';
          break;
        case 'operation-not-allowed':
          message = 'Phương thức đăng nhập chưa được kích hoạt';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
        default:
          message = 'Đăng nhập Google thất bại: ${e.code}';
      }
      
      return {'success': false, 'message': message};
    } catch (e) {
      developer.log('[v0] Exception: ${e.toString()}', name: 'AuthService');
      return {'success': false, 'message': 'Đã xảy ra lỗi: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
        await _auth.signOut();
        return {
          'success': true,
          'message': 'Đăng ký thành công! Chúng tôi đã gửi link xác thực đến email của bạn. Vui lòng kiểm tra email và click vào link để kích hoạt tài khoản.',
          'email': email,
        };
      }
      
      return {'success': false, 'message': 'Đăng ký thất bại'};
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu';
          break;
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        default:
          message = 'Đăng ký thất bại';
      }
      
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Đã xảy ra lỗi: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail(String email, String password) async {
    try {
      // Sign in temporarily to resend verification email
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          await _auth.signOut();
          return {'success': false, 'message': 'Email đã được xác thực. Bạn có thể đăng nhập.'};
        }
        
        await userCredential.user!.sendEmailVerification();
        await _auth.signOut();
        return {'success': true, 'message': 'Link xác thực đã được gửi lại. Vui lòng kiểm tra email.'};
      }
      
      return {'success': false, 'message': 'Gửi lại thất bại'};
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
          break;
        default:
          message = 'Gửi lại thất bại';
      }
      
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Đã xảy ra lỗi: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Email khôi phục đã được gửi!'};
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      
      switch (e.code) {
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này';
          break;
        default:
          message = 'Gửi email thất bại';
      }
      
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Đã xảy ra lỗi: ${e.toString()}'};
    }
  }
  
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
