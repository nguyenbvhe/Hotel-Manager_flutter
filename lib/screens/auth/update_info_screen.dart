import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';

class UpdateInfoScreen extends StatefulWidget {
  const UpdateInfoScreen({super.key});

  @override
  State<UpdateInfoScreen> createState() => _UpdateInfoScreenState();
}

class _UpdateInfoScreenState extends State<UpdateInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cccdController = TextEditingController();
  
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _nameController.text = auth.userName ?? '';
      _phoneController.text = auth.phoneNumber ?? '';
      _cccdController.text = auth.identityCard ?? '';
      
      // Try to parse existing address if available
      final existingAddress = auth.address ?? '';
      if (existingAddress.contains(', ')) {
        final parts = existingAddress.split(', ');
        if (parts.length >= 3) {
          setState(() {
            _selectedProvince = parts.last;
            _selectedDistrict = parts[parts.length - 2];
            _selectedWard = parts[parts.length - 3];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  void _handleSave() async {
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
      // Navigation is handled automatically by main.dart routing 
      // when Consumer<AuthProvider> detects isProfileComplete == true
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent skipping this screen
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withAlpha(200),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_pin_circle, size: 60, color: Color(0xFFD4AF37)),
                        const SizedBox(height: 16),
                        const Text(
                          'Bổ sung thông tin cá nhân',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mời bạn hoàn tất hồ sơ để trải nghiệm đặt phòng dễ dàng hơn.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ và tên',
                          icon: Icons.person,
                          validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _cccdController,
                          label: 'Thẻ Căn cước công dân',
                          icon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Vui lòng nhập số CCCD';
                            if (v.length != 12) return 'Số CCCD phải bao gồm 12 chữ số';
                            if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Số CCCD chỉ được chứa chữ số';
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  child: const Text('Cập nhật thông tin cá nhân khách hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
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
        prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
