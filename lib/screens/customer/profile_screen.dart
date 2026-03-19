import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_history_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../services/location_service.dart';

import 'booking_history_screen.dart';
import 'change_password_screen.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart';
import 'loyalty_screen.dart';
import 'contact_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cccdController;
  
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.userName ?? '');
    _phoneController = TextEditingController(text: auth.phoneNumber ?? '');
    _cccdController = TextEditingController(text: auth.identityCard ?? '');
    
    // Parse existing address
    final existingAddress = auth.address ?? '';
    if (existingAddress.contains(', ')) {
      final parts = existingAddress.split(', ');
      if (parts.length >= 3) {
        _selectedProvince = parts.last;
        _selectedDistrict = parts[parts.length - 2];
        _selectedWard = parts[parts.length - 3];
      }
    }

    // Auto update points based on booking history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.updatePointsFromBookings();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final fullAddress = '$_selectedWard, $_selectedDistrict, $_selectedProvince';
      
      await context.read<AuthProvider>().updateUserProfile(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: fullAddress,
        identityCard: _cccdController.text.trim(),
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
        backgroundColor: const Color(0xFF000000),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B6B01),
                Color(0xFF5D4801),
                Color(0xFF1E1E1E),
                Color(0xFF000000),
              ],
              stops: [0.0, 0.4, 0.8, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(40),
                          border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_outline_rounded, size: 80, color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Chào mừng đến với StayHub',
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
                          color: Colors.white.withAlpha(200),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB8860B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                            shadowColor: Colors.black.withAlpha(100),
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
                      const SizedBox(height: 25),
                      // Membership Card
                      _buildMembershipCard(context, auth),
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
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
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
            _buildTextField('Số CCCD (12 chữ số)', _cccdController, Icons.credit_card, keyboardType: TextInputType.number),
            const SizedBox(height: 15),
            _buildLocationDropdown(
              label: 'Tỉnh / Thành phố',
              value: _selectedProvince,
              items: LocationService.getProvinces(),
              onChanged: (val) {
                setState(() {
                  _selectedProvince = val;
                  _selectedDistrict = null;
                  _selectedWard = null;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildLocationDropdown(
              label: 'Quận / Huyện',
              value: _selectedDistrict,
              items: _selectedProvince != null ? LocationService.getDistricts(_selectedProvince!) : [],
              onChanged: (val) {
                setState(() {
                  _selectedDistrict = val;
                  _selectedWard = null;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildLocationDropdown(
              label: 'Phường / Xã',
              value: _selectedWard,
              items: (_selectedProvince != null && _selectedDistrict != null) 
                ? LocationService.getWards(_selectedProvince!, _selectedDistrict!) 
                : [],
              onChanged: (val) {
                setState(() {
                  _selectedWard = val;
                });
              },
            ),
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
          _buildMenuItem(Icons.workspace_premium_rounded, 'StayHub Club (Hạng thành viên)', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyScreen()));
          }, isPremium: true),
          _buildMenuItem(Icons.contact_support_rounded, 'Liên hệ hỗ trợ 24/7', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
          }),
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

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isPremium = false}) {
    return ListTile(
      leading: Icon(icon, color: isPremium ? const Color(0xFFD4AF37) : Colors.black87),
      title: Text(
        title, 
        style: TextStyle(
          fontSize: 16, 
          fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
          color: isPremium ? const Color(0xFFD4AF37) : Colors.black87,
        )
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildMembershipCard(BuildContext context, AuthProvider auth) {
    final int points = auth.points; 
    
    // Check points directly for conditional display
    if (points < 50) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withAlpha(10)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, color: Colors.grey, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tham gia StayHub Club', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Chi tiêu trên 5.000.000₫ để nhận thẻ Bạc và ưu đãi 10%.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Determine Tier Aesthetics
    final bool isDiamond = points >= 500;
    final bool isGold = points >= 250 && points < 500;
    final String tierLabel = isDiamond ? 'DIAMOND' : (isGold ? 'GOLD' : 'SILVER');
    
    // Tier-specific Color Palettes
    Color cardMainColor;
    Color accentColor;
    List<Color> gradientColors;
    
    if (isDiamond) {
      cardMainColor = const Color(0xFF000000);
      accentColor = const Color(0xFFB9F2FF); // Brilliant Diamond Blue/White
      gradientColors = [const Color(0xFF1A1A1A), const Color(0xFF000000), const Color(0xFF0A0A0A)];
    } else if (isGold) {
      cardMainColor = const Color(0xFF121212);
      accentColor = const Color(0xFFD4AF37); // Royal Gold
      gradientColors = [const Color(0xFF1F1F1F), const Color(0xFF000000)];
    } else {
      cardMainColor = const Color(0xFF2C3E50);
      accentColor = const Color(0xFFE0E0E0); // Platinum Silver
      gradientColors = [const Color(0xFF7F8C8D), const Color(0xFF2C3E50)];
    }

    final String memberId = 'SH-${auth.user?.uid.substring(0, 6).toUpperCase() ?? '88888'}X';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withAlpha(50), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Texture & Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
            ),
            
            // Subtle Texture Overlay
            Opacity(
              opacity: 0.04,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),

            // Realistic Gloss Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white.withAlpha(20),
                      Colors.transparent,
                      Colors.black.withAlpha(30),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VIP CARD',
                        style: TextStyle(
                          color: accentColor.withAlpha(200),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tierLabel,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Decorative Flourish
                  Column(
                    children: [
                      Text(
                        'STAYHUB',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(color: Colors.black.withAlpha(100), offset: const Offset(2, 2), blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        isDiamond ? Icons.diamond_outlined : (isGold ? Icons.auto_awesome_outlined : Icons.verified_outlined), 
                        color: accentColor, 
                        size: 24
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 0.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, accentColor, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Bottom Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'name',
                            style: TextStyle(color: accentColor.withAlpha(100), fontSize: 9, letterSpacing: 1),
                          ),
                          Text(
                            auth.userName?.toUpperCase() ?? 'GUEST NAME',
                            style: TextStyle(
                              color: accentColor.withAlpha(180),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'code',
                            style: TextStyle(color: accentColor.withAlpha(100), fontSize: 9, letterSpacing: 1),
                          ),
                          Text(
                            memberId,
                            style: TextStyle(
                              color: accentColor.withAlpha(180),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Metallic Shine Chip (Standard for all 5-star cards)
            Positioned(
              top: 24,
              right: 24,
              child: Container(
                width: 35,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withAlpha(100),
                      accentColor.withAlpha(200),
                      accentColor.withAlpha(100),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: ChipPainter(accentColor.withAlpha(50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Vui lòng nhập $label';
        if (label.contains('CCCD')) {
          if (v.length != 12) return 'Số CCCD phải bao gồm 12 chữ số';
          if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Số CCCD chỉ được chứa chữ số';
        }
        return null;
      },
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
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                navigator.pop(); // Close dialog
                try {
                  await auth.signOut();
                  // main.dart Consumer will handle the switch to guest view
                } catch (e) {
                  debugPrint('Logout error caught: $e');
                  String errorMsg = 'Lỗi khi đăng xuất: $e';
                  if (e.toString().contains('keychain-error')) {
                    errorMsg = 'Lỗi Keychain iOS: Vui lòng bật "Keychain Sharing" trong Xcode > Signing & Capabilities.';
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Vui lòng chọn $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on, color: Color(0xFFD4AF37)),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }
}

class ChipPainter extends CustomPainter {
  final Color color;
  ChipPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw chip lines
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
          Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), paint);
      canvas.drawLine(
          Offset(size.width * i / 4, 0), Offset(size.width * i / 4, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
