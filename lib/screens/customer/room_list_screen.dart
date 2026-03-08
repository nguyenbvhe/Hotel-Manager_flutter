import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/room.dart';
import 'room_detail_screen.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phòng')),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _buildRoomTile(context, room);
        },
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, Room room) {
    return Card(
      margin: const Duration(milliseconds: 0) == Duration.zero ? const EdgeInsets.only(bottom: 15) : EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.network(
                    room.images.isNotEmpty ? room.images[0] : 'https://via.placeholder.com/400x400',
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phòng ${room.roomNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(room.roomTypeString, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${room.price.toInt()}đ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(room.status).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.statusString,
                            style: TextStyle(color: _getStatusColor(room.status), fontSize: 12),
                          ),
                        ),
                      ],
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

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available: return Colors.green;
      case RoomStatus.booked: return Colors.red;
      case RoomStatus.cleaning: return Colors.blue;
      case RoomStatus.maintenance: return Colors.orange;
    }
  }
}
