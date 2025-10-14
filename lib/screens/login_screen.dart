import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Xử lý đăng nhập với email
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Color(0xFF10b981),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        if (result['needsVerification'] == true) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Color(0xFF1e293b),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFf59e0b), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Email chưa xác thực',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['message'],
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bạn có muốn gửi lại email xác thực?',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                    });
                    
                    final resendResult = await _authService.resendVerificationEmail(
                      result['email'],
                      _passwordController.text,
                    );
                    
                    setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(resendResult['message']),
                        backgroundColor: resendResult['success'] 
                            ? Color(0xFF10b981) 
                            : Color(0xFFef4444),
                      ),
                    );
                  },
                  child: Text(
                    'Gửi lại',
                    style: TextStyle(color: Color(0xFF06b6d4), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Color(0xFFef4444),
            ),
          );
        }
      }
    }
  }

  // Xử lý đăng nhập với Google
  void _handleGoogleLogin() async {
    developer.log('[v0] Bắt đầu xử lý Google login', name: 'LoginScreen');
    
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.loginWithGoogle();
    
    developer.log('[v0] Kết quả Google login: ${result['success']} - ${result['message']}', name: 'LoginScreen');

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Color(0xFF10b981),
          duration: Duration(seconds: 2),
        ),
      );
      developer.log('[v0] Chuyển hướng đến /main', name: 'LoginScreen');
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      developer.log('[v0] Đăng nhập thất bại: ${result['message']}', name: 'LoginScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Color(0xFFef4444),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        title: Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                
                Container(
                  margin: EdgeInsets.only(bottom: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: Color(0xFF06b6d4),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Lory',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Cộng đồng đọc truyện',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trường nhập Email
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Vui lòng nhập Email',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF06b6d4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                      ),
                      filled: true,
                      fillColor: Color(0xFF1e293b),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ),

                // Trường nhập Mật khẩu
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Vui lòng nhập Mật khẩu',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF06b6d4)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                      ),
                      filled: true,
                      fillColor: Color(0xFF1e293b),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Nút Đăng nhập
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF06b6d4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hoặc',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: Icon(Icons.g_mobiledata, size: 28),
                    label: Text('Đăng nhập với Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Link đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Color(0xFF06b6d4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
