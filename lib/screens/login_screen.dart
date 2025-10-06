import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Giả lập thời gian xử lý đăng nhập
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      // Hiển thị Snackbar thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thành công!'),
          backgroundColor: Color(0xFF06b6d4),
          duration: Duration(seconds: 2),
        ),
      );

      // Chuyển sang màn hình chính
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4F9), // Màu nền hồng nhạt như trong hình
      appBar: AppBar(
        title: Text(
          'Đăng nhập',
          style: TextStyle(
            color: Color(0xFF1e293b),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo hoặc tiêu đề ứng dụng
                Container(
                  margin: EdgeInsets.only(bottom: 48),
                  child: Text(
                    'Truyện Tranh Xã Hội',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                ),

                // Trường nhập Email
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Vui lòng nhập Email',
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF06b6d4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFec4899)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
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
                  margin: EdgeInsets.only(bottom: 32),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      hintText: 'Vui lòng nhập Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF06b6d4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFec4899)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
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

                // Nút Đăng nhập
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFec4899),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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

                // Liên kết đăng ký (tùy chọn)
                Container(
                  margin: EdgeInsets.only(top: 24),
                  child: TextButton(
                    onPressed: () {
                      // Có thể thêm màn hình đăng ký sau
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tính năng đăng ký sẽ được cập nhật sau!'),
                          backgroundColor: Color(0xFF06b6d4),
                        ),
                      );
                    },
                    child: Text(
                      'Chưa có tài khoản? Đăng ký ngay',
                      style: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
