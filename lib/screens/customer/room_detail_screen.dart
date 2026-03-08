import 'package:flutter/material.dart';
import '../../models/room.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'booking_screen.dart';
import '../auth/login_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Phòng ${room.roomNumber}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard Image Loading with fixed height to prevent layout jumps
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: ExcludeSemantics(
                child: Image.network(
                  room.images.isNotEmpty ? room.images[0] : 'https://via.placeholder.com/600',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, size: 50)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Mô tả'),
                  const SizedBox(height: 10),
                  Text(
                    room.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Tiện ích phòng'),
                  const SizedBox(height: 15),
                  _buildAmenities(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomBar(context)),
    );
  }

  Widget _buildHeaderInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phòng ${room.roomNumber}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                room.roomTypeString,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(room.status).withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            room.statusString,
            style: TextStyle(color: _getStatusColor(room.status), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAmenities() {
    return const Wrap(
      spacing: 15,
      runSpacing: 15,
      children: [
        _AmenityItem(icon: Icons.wifi, label: 'Free WiFi'),
        _AmenityItem(icon: Icons.ac_unit, label: 'Điều hòa'),
        _AmenityItem(icon: Icons.tv, label: 'TV Box'),
        _AmenityItem(icon: Icons.room_service, label: 'Dịch vụ phòng'),
        _AmenityItem(icon: Icons.coffee_maker, label: 'Cà phê & Trà'),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giá mỗi đêm', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                '${room.price.toInt()} VNĐ',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: room.status == RoomStatus.available 
              ? () {
                  final auth = context.read<AuthProvider>();
                  if (!auth.isLoggedIn) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để đặt phòng!'), backgroundColor: Colors.orange));
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  } else {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(room: room)));
                  }
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text('Đặt ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available: return Colors.green;
      case RoomStatus.booked: return Colors.red;
      case RoomStatus.cleaning: return Colors.blue;
      case RoomStatus.maintenance: return Colors.orange;
    }
  }
}

class _AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 70) / 2, // 2 columns
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }
}
