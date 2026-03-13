import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await context.read<AuthProvider>().registerWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Đang đăng nhập...'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        await context.read<AuthProvider>().signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Auth Error Detail: $e');
      String errorMessage = 'Đã có lỗi xảy ra';
      final errStr = e.toString().toLowerCase();
      
      if (errStr.contains('user-not-found') || 
          errStr.contains('wrong-password') || 
          errStr.contains('invalid-credential')) {
        errorMessage = 'Email hoặc mật khẩu không chính xác';
      } else if (errStr.contains('email-already-in-use')) {
        errorMessage = 'Email đã được sử dụng';
      } else if (errStr.contains('invalid-email')) {
        errorMessage = 'Định dạng email không hợp lệ';
      } else if (errStr.contains('too-many-requests')) {
        errorMessage = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      }
      
      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Base dark to prevent flashes
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4AF37), // Metallic Gold
              Color(0xFFB8860B), // Dark Goldenrod
              Color(0xFF1E1E1E), // Dark
              Color(0xFF000000), // Black
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false, // Ensure gradient flows to bottom
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // App Logo or Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withAlpha(100),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.hotel_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'G-HOTEL LUXURY',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isRegistering ? 'Tham gia trải nghiệm đẳng cấp' : 'Chào mừng quý khách trở lại',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email', Icons.email_outlined),
                    validator: (v) => v == null || !v.contains('@') ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Mật khẩu', Icons.lock_outline_rounded),
                    validator: (v) => v == null || v.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                  ),
                  const SizedBox(height: 35),
                  // Login/Register Button
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _handleEmailAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFB8860B),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: Text(
                              _isRegistering ? 'ĐĂNG KÝ NGAY' : 'ĐĂNG NHẬP',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  // Toggle Login/Register
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        children: [
                          TextSpan(text: _isRegistering ? 'Đã có tài khoản? ' : 'Chưa có tài khoản? '),
                          TextSpan(
                            text: _isRegistering ? 'Đăng nhập' : 'Đăng ký ngay',
                            style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Bằng cách đăng nhập, bạn đồng ý với Điều khoản & Chính sách bảo mật của G-Hotel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(150),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withAlpha(30),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withAlpha(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
  }
}
