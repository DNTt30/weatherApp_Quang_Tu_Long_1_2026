import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';
import '../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Tài khoản demo mẫu
  static const String _demoEmail = 'demo@phenikaa.edu.vn';
  static const String _demoPassword = '123456';
  static const String _demoUsername = 'Phenikaa Demo';

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isDemoLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Tự động tạo + đăng nhập tài khoản demo ─────────────
  Future<void> _useDemoAccount() async {
    setState(() => _isDemoLoading = true);
    try {
      _emailController.text = _demoEmail;
      _passwordController.text = _demoPassword;

      try {
        await _authService.signIn(_demoEmail, _demoPassword);
      } on FirebaseAuthException catch (e) {
        // Firebase mới trả nhiều code khác nhau — bắt tất cả
        final codesNotFound = [
          'user-not-found',
          'invalid-credential',
          'INVALID_LOGIN_CREDENTIALS',
          'invalid-login-credentials',
          'wrong-password', // dùng sai pass lần đầu — tài khoản chưa có
        ];
        if (codesNotFound.contains(e.code)) {
          // Tài khoản chưa tồn tại → đăng ký mới rồi đăng nhập
          try {
            await _authService.signUp(_demoEmail, _demoUsername, _demoPassword);
          } on FirebaseAuthException catch (signUpErr) {
            // Nếu email đã tồn tại nhưng pass sai → bỏ qua, thử lại sign in
            if (signUpErr.code != 'email-already-in-use') rethrow;
          }
          await _authService.signIn(_demoEmail, _demoPassword);
        } else {
          rethrow;
        }
      }

      // Không cần Navigator — StreamBuilder trong main.dart tự redirect
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.verified_user_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đăng nhập demo thành công!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            backgroundColor: const Color(0xFF1565C0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi Firebase (${e.code}): ${e.message}'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi demo: ${e.toString()}'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDemoLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Thử đăng nhập — nếu tài khoản chưa tồn tại thì tự tạo (chỉ cho demo)
      try {
        await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (innerErr) {
        final notFoundCodes = [
          'user-not-found',
          'invalid-credential',
          'INVALID_LOGIN_CREDENTIALS',
          'invalid-login-credentials',
        ];
        // Nếu là tài khoản demo và chưa có → tự tạo rồi đăng nhập
        if (notFoundCodes.contains(innerErr.code) &&
            _emailController.text.trim() == _demoEmail) {
          try {
            await _authService.signUp(_demoEmail, _demoUsername, _demoPassword);
          } on FirebaseAuthException catch (su) {
            if (su.code != 'email-already-in-use') rethrow;
          }
          await _authService.signIn(_demoEmail, _demoPassword);
        } else {
          rethrow;
        }
      }

      // Không cần Navigator — StreamBuilder trong main.dart tự redirect
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đăng nhập thành công! Chào mừng quay trở lại.',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại! (${e.code})';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' ||
          e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage = 'Email hoặc mật khẩu không chính xác.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Địa chỉ email không hợp lệ.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Tài khoản này đã bị vô hiệu hóa.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Quá nhiều yêu cầu. Thử lại sau.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E335A), // Linear 1 Start
              Color(0xFF1C1B33), // Linear 1 End
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo & Brand Header
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1D47).withOpacity(0.5), // Solid 2
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE0D9FF).withOpacity(0.3), // Solid 4
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF48319D).withOpacity(0.3), // Solid 1
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          size: 64,
                          color: Color(0xFFFFB300),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'WEATHER APP',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'Phenikaa University • Team 1',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE0D9FF), // Solid 4
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cập nhật thời tiết nhanh chóng & chính xác',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFEBEBF5).withOpacity(0.6), // Secondary Text Dark
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1D47).withOpacity(0.7), // Solid 2 Glassmorphic
                      borderRadius: BorderRadius.circular(28.0),
                      border: Border.all(
                        color: const Color(0xFFE0D9FF).withOpacity(0.2), // Solid 4 Border
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: const Color(0xFF48319D).withOpacity(0.25), // Solid 1 purple glow
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đăng Nhập',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Primary Text Dark
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vui lòng đăng nhập để xem thông tin thời tiết',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFEBEBF5).withOpacity(0.6), // Secondary Text Dark
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ Email',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFEBEBF5).withOpacity(0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFFE0D9FF), // Solid 4
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE0D9FF).withOpacity(0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC427FB), // Solid 3
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1C1B33).withOpacity(0.5), // Linear 1 End
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value)) {
                                return 'Vui lòng nhập email hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFEBEBF5).withOpacity(0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFFE0D9FF), // Solid 4
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFFEBEBF5).withOpacity(0.6),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE0D9FF).withOpacity(0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC427FB), // Solid 3
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1C1B33).withOpacity(0.5), // Linear 1 End
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải dài ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ── Nút Demo Account ────────────────────────
                          GestureDetector(
                            onTap: (_isLoading || _isDemoLoading) ? null : _useDemoAccount,
                            child: Container(
                              width: double.infinity,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF42A5F5).withOpacity(0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: _isDemoLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.flash_on_rounded,
                                            color: Color(0xFF42A5F5),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Dùng tài khoản Demo',
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF42A5F5),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          // ── Divider ─────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'hoặc',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                            ]),
                          ),

                          // ── Nút Đăng Nhập chính ─────────────────────
                          GestureDetector(
                            onTap: _isLoading ? null : _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: _isLoading
                                    ? null
                                    : const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF48319D), // Solid 1
                                          Color(0xFFC427FB), // Solid 3
                                        ],
                                      ),
                                color: _isLoading ? Colors.grey.shade800 : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: _isLoading
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFFC427FB).withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'ĐĂNG NHẬP',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Navigate to Register Screen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chưa có tài khoản?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFFEBEBF5).withOpacity(0.6), // Secondary Text Dark
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFE0D9FF), // Solid 4
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  'Đăng ký ngay',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFC427FB), // Solid 3
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Footer info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_rounded, size: 16, color: Color(0xFFEBEBF5)),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.university,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFEBEBF5).withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phiên bản ${AppConstants.appVersion}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFFEBEBF5).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}