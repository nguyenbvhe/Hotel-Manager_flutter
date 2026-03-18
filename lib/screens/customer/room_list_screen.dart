import 'package:flutter/material.dart';
import '../../widgets/custom_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/room.dart';
import 'room_detail_screen.dart';
import 'package:intl/intl.dart';

class RoomListScreen extends StatelessWidget {
  final RoomType? selectedType;
  const RoomListScreen({super.key, this.selectedType});

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final allRooms = hotelProvider.rooms;
    final rooms = selectedType == null
        ? allRooms
        : allRooms.where((r) => r.roomType == selectedType).toList();

    String title = 'Tất cả phòng';
    if (selectedType == RoomType.standard) title = 'Phòng Standard';
    if (selectedType == RoomType.deluxe) title = 'Phòng Deluxe';
    if (selectedType == RoomType.vip) title = 'Phòng VIP';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: rooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Không có phòng nào', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) => _buildRoomCard(context, rooms[index]),
            ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Room image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 110,
                height: 110,
                child: CachedNetworkImage(
                  imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://via.placeholder.com/400',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, stack) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Room info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Phòng ${room.roomNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusColor(room.status).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.statusString,
                            style: TextStyle(
                              color: _getStatusColor(room.status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.roomTypeString,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if ((room.status == RoomStatus.cleaning || room.status == RoomStatus.maintenance) && room.statusUntil != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Còn lại: ${room.statusTimeRemainingString}',
                            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.square_foot, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text('${room.size.toInt()}m²', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(width: 10),
                        Icon(Icons.people_outline, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text('${room.maxGuests} khách', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat('#,###', 'vi_VN').format(room.price)} ₫/đêm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          ],
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
