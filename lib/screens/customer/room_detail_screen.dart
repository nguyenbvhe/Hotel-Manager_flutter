import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/room.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'booking_screen.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Premium Collapsing App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(
                    child: CachedNetworkImage(
                      imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://via.placeholder.com/600',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, stack) => Container(color: Colors.grey[300]),
                    ),
                  ),
                  // Gradient overlay at bottom for readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withAlpha(140), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Status badge on image
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _getStatusColor(room.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room.statusString,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Phòng ${room.roomNumber}',
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                    if (room.roomType == RoomType.romantic) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.favorite, color: Color(0xFFFF1493), size: 24),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      room.roomTypeIcon,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      room.roomTypeString,
                                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                if ((room.status == RoomStatus.cleaning || room.status == RoomStatus.maintenance) && room.statusUntil != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withAlpha(25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 16, color: Colors.blue),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Hoàn thành sau: ${room.statusTimeRemainingString}',
                                          style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Giá/đêm', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                '${NumberFormat('#,###', 'vi_VN').format(room.price)} ₫',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Specs Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSpec(Icons.square_foot_rounded, '${room.size.toInt()} m²', 'Diện tích'),
                      _buildDivider(),
                      _buildSpec(Icons.people_outline, '${room.maxGuests} người', 'Sức chứa'),
                      _buildDivider(),
                      _buildSpec(Icons.bed_outlined, room.bedType, 'Loại giường'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Description Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mô tả phòng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        room.description,
                        style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Amenities Card
                if (room.amenities.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tiện ích đi kèm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: room.amenities.map((a) => _buildAmenityChip(a)).toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 100), // Bottom padding for button
              ],
            ),
          ),
        ],
      ),

      // Sticky Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 15, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Giá mỗi đêm', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        '${NumberFormat('#,###', 'vi_VN').format(room.price)} ₫',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: room.status == RoomStatus.available
                        ? () {
                            final auth = context.read<AuthProvider>();
                            if (!auth.isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng đăng nhập để đặt phòng!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(room: room)));
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: room.roomType == RoomType.romantic ? const Color(0xFFFF1493) : const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                    ),
                    child: Text(
                      room.status == RoomStatus.available ? (room.roomType == RoomType.romantic ? '💖 Đặt phòng tình yêu' : '🏨 Đặt phòng ngay') : '⛔ ${room.statusString}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 26),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[200]);
  }

  Widget _buildAmenityChip(String label) {
    final isRomantic = room.roomType == RoomType.romantic;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isRomantic ? const Color(0xFFFFF0F5) : const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isRomantic ? const Color(0xFFFF69B4).withAlpha(100) : const Color(0xFFD4AF37).withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isRomantic ? const Color(0xFFC71585) : const Color(0xFF8B6914),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
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
