import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Poll every 3 seconds to detect email verification
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final auth = context.read<AuthProvider>();
      await auth.reloadUser();
      // If verified, main.dart's Consumer will automatically navigate away
    });
  }

  Future<void> _resendEmail() async {
    setState(() => _isSending = true);
    try {
      await context.read<AuthProvider>().sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email xác nhận đã được gửi lại!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi lại thất bại, thử lại sau!'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _checkVerificationManually() async {
    final auth = context.read<AuthProvider>();
    await auth.reloadUser();
    if (mounted && !auth.isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email chưa được xác nhận, vui lòng kiểm tra hộp thư.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFFD4AF37)),
                const SizedBox(height: 40),
                const Text(
                  'Xác thực Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chúng tôi đã gửi một liên kết xác nhận đến email:\n${auth.userEmail}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),
                // Primary: Manual check button
                ElevatedButton.icon(
                  onPressed: _checkVerificationManually,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Tôi đã xác nhận xong', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 16),
                // Secondary: Resend button
                OutlinedButton.icon(
                  onPressed: _isSending ? null : _resendEmail,
                  icon: _isSending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey))
                    : const Icon(Icons.email_outlined, size: 18),
                  label: Text(_isSending ? 'Đang gửi...' : 'Gửi lại email xác nhận'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    side: BorderSide(color: Colors.grey[600]!),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _showLogoutDialog(context, auth),
                  child: const Text('Đăng nhập bằng tài khoản khác', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)),
                    const SizedBox(width: 10),
                    Text('Tự động kiểm tra mỗi 3 giây...', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                auth.signOut();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}
