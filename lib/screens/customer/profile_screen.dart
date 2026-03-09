import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_history_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'booking_history_screen.dart';
import 'change_password_screen.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.userName ?? '');
    _phoneController = TextEditingController(text: auth.phoneNumber ?? '');
    _addressController = TextEditingController(text: auth.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().updateUserProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (!auth.isLoggedIn) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern or soft image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_outline, size: 80, color: Color(0xFFD4AF37)),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Chào mừng đến với G-Hotel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đăng nhập để xem lịch sử đặt phòng, quản lý hồ sơ và nhận các ưu đãi hấp dẫn dành riêng cho bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                          child: const Text(
                            'ĐĂNG NHẬP / ĐĂNG KÝ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // This screen is usually inside a BottomNavigationBar tab
                          // We need to tell the parent (HomeScreen) to switch to index 0
                          // A simple way without complex state management in this specific fix:
                          final homeState = context.findAncestorStateOfType<HomeScreenState>();
                          if (homeState != null) {
                            homeState.setState(() {
                              homeState.selectedIndex = 0;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Quay lại khám phá phòng',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, auth),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: CachedNetworkImageProvider(auth.userPhotoUrl!),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        auth.userName ?? 'Chưa đặt tên',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        auth.userEmail ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      if (!_isEditing)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFC5A028)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _isEditing = true),
                            icon: const Icon(Icons.edit_calendar_rounded, size: 20),
                            label: const Text('Cập nhật thông tin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                
                if (_isEditing)
                  _buildEditForm()
                else
                  _buildMenuOptions(context),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CHỈNH SỬA THÔNG TIN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildTextField('Họ và tên', _nameController, Icons.person),
            const SizedBox(height: 15),
            _buildTextField('Số điện thoại', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField('Địa chỉ', _addressController, Icons.location_on),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditing = false),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(Icons.history, 'Lịch sử đặt phòng', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen()));
          }),
          _buildMenuItem(Icons.payment, 'Lịch sử thanh toán', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()));
          }),
          _buildMenuItem(Icons.lock_outline, 'Đổi mật khẩu', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
