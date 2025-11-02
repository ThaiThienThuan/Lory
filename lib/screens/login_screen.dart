import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final Function(Locale) onChangeLanguage;
  const LoginScreen({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

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

  // Đăng nhập Email
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/main');
      } else if (result['needsVerification'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor:
                Theme.of(context).dialogTheme.backgroundColor, // ✅ Sửa
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFf59e0b), size: 28),
                const SizedBox(width: 12),
                Text(
                  'dialog.email_not_verified_title'.tr(),
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.titleLarge?.color, // ✅ Thêm
                  ),
                ),
              ],
            ),
            content: Text(
              result['message'],
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color, // ✅ Thêm
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('dialog.cancel'.tr()),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);

                  final resendResult =
                      await _authService.resendVerificationEmail(
                    result['email'],
                    _passwordController.text,
                  );

                  setState(() => _isLoading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(resendResult['message']),
                      backgroundColor:
                          resendResult['success'] ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: Text(
                  'dialog.resend'.tr(),
                  style: const TextStyle(
                      color: Color(0xFF06b6d4), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Đăng nhập Google
  // Đăng nhập Google
  void _handleGoogleLogin() async {
    developer.log('[v0] Bắt đầu xử lý Google login', name: 'LoginScreen');
    setState(() => _isLoading = true);

    final result = await _authService.loginWithGoogle();

    setState(() => _isLoading = false);

    if (result['success']) {
      // ✅ NEW: tạo user Firestore nếu chưa có
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _authService.createUserIfNotExists(user);
        developer.log(
            '[v0] Đã đảm bảo user tồn tại trong Firestore: ${user.uid}',
            name: 'LoginScreen');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 Hàm đổi ngôn ngữ toàn cục
  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Đã đúng
      appBar: AppBar(
        title: Text('login.title'.tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).cardTheme.color?.withOpacity(0.8), // ✅ Sửa
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), // ✅ Sửa
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🌗 Icon chuyển Dark/Light
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color, // ✅ Sửa
                  ),
                  onPressed: widget.onToggleTheme,
                  tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
                ),

                // 🌍 Dropdown chọn ngôn ngữ
                DropdownButton<Locale>(
                  value: context.locale,
                  underline: const SizedBox(),
                  dropdownColor: Theme.of(context).cardTheme.color, // ✅ Sửa
                  borderRadius: BorderRadius.circular(16),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).iconTheme.color, // ✅ Thêm
                  ),
                  items: [
                    DropdownMenuItem(
                      value: const Locale('vi'),
                      child: Row(
                        children: [
                          Image.asset('assets/images/vn_flag.png', width: 22),
                          const SizedBox(width: 6),
                          Text(
                            'VI',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color, // ✅ Thêm
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Row(
                        children: [
                          Image.asset('assets/images/en_flag.png', width: 22),
                          const SizedBox(width: 6),
                          Text(
                            'EN',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color, // ✅ Thêm
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      widget.onChangeLanguage(newLocale);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // ------------------ BODY ------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Column(
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        size: 64, color: Color(0xFF06b6d4)),
                    const SizedBox(height: 16),
                    Text(
                      'app_name'.tr(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.color, // ✅ Sửa
                      ),
                    ),
                    Text(
                      'app_subtitle'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7), // ✅ Sửa
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // ---------------- Email ----------------
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color, // ✅ Sửa
                  ),
                  decoration: InputDecoration(
                    labelText: 'login.email_label'.tr(),
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color, // ✅ Thêm
                    ),
                    hintText: 'login.email_hint'.tr(),
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5), // ✅ Thêm
                    ),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF06b6d4)),
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color, // ✅ Sửa
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF06b6d4),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.email_required'.tr();
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'login.email_invalid'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ---------------- Password ----------------
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color, // ✅ Sửa
                  ),
                  decoration: InputDecoration(
                    labelText: 'login.password_label'.tr(),
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color, // ✅ Thêm
                    ),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF06b6d4)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            isDark ? Colors.white54 : Colors.black54, // ✅ Sửa
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color, // ✅ Sửa
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.white12 : Colors.black12, // ✅ Thêm
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF06b6d4),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'login.password_required'.tr();
                    }
                    if (value.length < 6) {
                      return 'login.password_min_length'.tr();
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(
                          onToggleTheme: widget.onToggleTheme,
                        ),
                      ),
                    ),
                    child: Text(
                      'login.forgot_password'.tr(),
                      style: const TextStyle(
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------------- Login Button ----------------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06b6d4),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF06b6d4).withOpacity(0.6), // ✅ Thêm
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('login.title'.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- OR Divider ----------------
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color:
                            isDark ? Colors.white24 : Colors.black26, // ✅ Thêm
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'hoặc',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.6), // ✅ Thêm
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color:
                            isDark ? Colors.white24 : Colors.black26, // ✅ Thêm
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ---------------- Google Login ----------------
                SizedBox(
                  width: double
                      .infinity, // 🔥 luôn full chiều ngang, không co giãn
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Text(
                      'login.button_google'.tr(), // 🔹 dùng localization
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'login.no_account'.tr(),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7), // ✅ Sửa
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(
                            onToggleTheme: widget.onToggleTheme,
                          ),
                        ),
                      ),
                      child: Text('login.register_now'.tr(),
                          style: const TextStyle(
                              color: Color(0xFF06b6d4),
                              fontWeight: FontWeight.w600)),
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
