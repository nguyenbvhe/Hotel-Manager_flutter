import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../customer/home_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _isCaptchaChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handlePhoneAuth() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isCaptchaChecked) {
      _showError('Vui lòng xác nhận Captcha "Check Boss"');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      if (_isRegistering) {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Mật khẩu xác nhận không khớp');
        }

        // Start SMS Verification
        await auth.verifyPhoneNumber(
          phoneNumber: _phoneController.text.trim(),
          codeSent: (verificationId, resendToken) {
            setState(() => _isLoading = false);
            
            // If in test mode, show a simulation dialog
            if (auth.isTestMode) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.sim_card, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Mô phỏng SMS'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hệ thống đang ở chế độ Test Mode.'),
                      const SizedBox(height: 10),
                      const Text('Tin nhắn giả lập gửi đến:'),
                      Text(_phoneController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Mã OTP: ', style: TextStyle(fontSize: 16)),
                            Text(
                              auth.mockOtp ?? '------',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OTPVerificationScreen(
                              verificationId: verificationId,
                              phoneNumber: _phoneController.text.trim(),
                              password: _passwordController.text.trim(),
                              displayName: _nameController.text.trim(),
                            ),
                          ),
                        );
                      },
                      child: const Text('NHẬP MÃ NGAY'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OTPVerificationScreen(
                    verificationId: verificationId,
                    phoneNumber: _phoneController.text.trim(),
                    password: _passwordController.text.trim(),
                    displayName: _nameController.text.trim(),
                  ),
                ),
              );
            }
          },
          verificationFailed: (e) {
            setState(() => _isLoading = false);
            _showError('Xác thực thất bại: ${e.message}');
          },
        );
      } else {
        // Login with Phone + Pass
        await auth.signInWithPhoneAndPassword(
          _phoneController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted && !_isRegistering) setState(() => _isLoading = false);
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
                  // Form Fields
                  if (_isRegistering) ...[
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Họ và tên', Icons.person),
                      validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),
                    const SizedBox(height: 15),
                  ],
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Số điện thoại', Icons.phone),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Mật khẩu', Icons.lock),
                    validator: (v) => v == null || v.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                  ),
                  if (_isRegistering) ...[
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Xác nhận mật khẩu', Icons.lock_outline),
                      validator: (v) => v != _passwordController.text ? 'Mật khẩu không khớp' : null,
                    ),
                  ],
                  const SizedBox(height: 25),
                  
                  // "Check Boss" Captcha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isCaptchaChecked,
                          onChanged: (v) => setState(() => _isCaptchaChecked = v ?? false),
                          checkColor: Colors.black,
                          activeColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        const Text(
                          'Tôi không phải là máy (Check Boss)',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const Spacer(),
                        const Icon(Icons.security, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Login/Register Button
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: _handlePhoneAuth,
                          style: _buttonStyle(Colors.white, Colors.black87),
                          child: Text(
                            _isRegistering ? 'Đăng ký & Gửi OTP' : 'Đăng nhập',
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
                  const SizedBox(height: 30),
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
