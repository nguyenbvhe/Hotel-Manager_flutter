import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().signInWithGoogle();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlpha(200),
              const Color(0xFFD4AF37).withAlpha(100),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // App Logo or Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: const Icon(
                      Icons.hotel,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'G-Hotel Guest',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email', Icons.email),
                    validator: (v) => v == null || !v.contains('@') ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 15),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Mật khẩu', Icons.lock),
                    validator: (v) => v == null || v.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                  ),
                  const SizedBox(height: 25),
                  // Login/Register Button
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: _handleEmailAuth,
                          style: _buttonStyle(Colors.white, Colors.black87),
                          child: Text(
                            _isRegistering ? 'Đăng ký tài khoản' : 'Đăng nhập',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 15),
                  // Toggle Login/Register
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    child: Text(
                      _isRegistering ? 'Đã có tài khoản? Đăng nhập' : 'Chưa có tài khoản? Đăng ký ngay',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white54)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('HOẶC', style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                      ),
                      const Expanded(child: Divider(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Google Sign-In
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: _buttonStyle(Colors.white.withAlpha(40), Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          imageUrl: 'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                          height: 24,
                          placeholder: (context, url) => const SizedBox(width: 24, height: 24),
                          errorWidget: (context, url, stackTrace) => const Icon(Icons.login, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 15),
                        const Flexible(
                          child: Text(
                            'Tiếp tục với Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Bằng cách đăng nhập, bạn đồng ý với Điều khoản & Chính sách của chúng tôi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(150),
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

  ButtonStyle _buttonStyle(Color bg, Color fg) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
    );
  }
}
