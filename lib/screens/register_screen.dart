import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';
import '../widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUp(
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đăng ký tài khoản thành công! Đang đăng nhập...',
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
        
        // Remove all routes and go to MainShell
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đăng ký thất bại. Vui lòng thử lại!';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Địa chỉ email này đã được đăng ký bởi tài khoản khác.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Địa chỉ email không hợp lệ.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu. Vui lòng nhập mật khẩu mạnh hơn.';
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
                  // App Brand Logo & Name
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1D47).withValues(alpha: 0.5), // Solid 2
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE0D9FF).withValues(alpha: 0.3), // Solid 4
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF48319D).withValues(alpha: 0.3), // Solid 1
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'TẠO TÀI KHOẢN',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Tham gia với Weather App',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFFE0D9FF), // Solid 4
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Registration Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1D47).withValues(alpha: 0.7), // Solid 2 Glassmorphic
                      borderRadius: BorderRadius.circular(28.0),
                      border: Border.all(
                        color: const Color(0xFFE0D9FF).withValues(alpha: 0.2), // Solid 4 Border
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: const Color(0xFF48319D).withValues(alpha: 0.25), // Solid 1 purple glow
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
                            'Đăng Ký',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Primary Text Dark
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hãy nhập đầy đủ thông tin bên dưới',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFEBEBF5).withValues(alpha: 0.6), // Secondary Text Dark
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ Email',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFEBEBF5).withValues(alpha: 0.6),
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
                                  color: const Color(0xFFE0D9FF).withValues(alpha: 0.15),
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
                              fillColor: const Color(0xFF1C1B33).withValues(alpha: 0.5), // Linear 1 End
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
                          const SizedBox(height: 16),

                          // Username Input
                          TextFormField(
                            controller: _usernameController,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Tên người dùng (Username)',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFEBEBF5).withValues(alpha: 0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFFE0D9FF), // Solid 4
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE0D9FF).withValues(alpha: 0.15),
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
                              fillColor: const Color(0xFF1C1B33).withValues(alpha: 0.5), // Linear 1 End
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên người dùng';
                              }
                              if (value.trim().length < 3) {
                                return 'Tên người dùng phải có ít nhất 3 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFEBEBF5).withValues(alpha: 0.6),
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
                                  color: const Color(0xFFEBEBF5).withValues(alpha: 0.6),
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
                                  color: const Color(0xFFE0D9FF).withValues(alpha: 0.15),
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
                              fillColor: const Color(0xFF1C1B33).withValues(alpha: 0.5), // Linear 1 End
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

                          // Confirm Password Input
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Xác nhận mật khẩu',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFEBEBF5).withValues(alpha: 0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_clock_outlined,
                                color: Color(0xFFE0D9FF), // Solid 4
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFFEBEBF5).withValues(alpha: 0.6),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE0D9FF).withValues(alpha: 0.15),
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
                              fillColor: const Color(0xFF1C1B33).withValues(alpha: 0.5), // Linear 1 End
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập lại mật khẩu';
                              }
                              if (value != _passwordController.text) {
                                return 'Mật khẩu xác nhận không trùng khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          GestureDetector(
                            onTap: _isLoading ? null : _handleRegister,
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
                                          color: const Color(0xFFC427FB).withValues(alpha: 0.4),
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
                                        'ĐĂNG KÝ NGAY',
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
                          const SizedBox(height: 16),

                          // Navigate back to Login Screen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã có tài khoản?',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFFEBEBF5).withValues(alpha: 0.6), // Secondary Text Dark
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFE0D9FF), // Solid 4
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: Text(
                                  'Đăng nhập',
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

                  const SizedBox(height: 24),
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
                          color: const Color(0xFFEBEBF5).withValues(alpha: 0.7),
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
                      color: const Color(0xFFEBEBF5).withValues(alpha: 0.5),
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
