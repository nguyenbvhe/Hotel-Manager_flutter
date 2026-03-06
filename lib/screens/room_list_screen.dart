import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hotel_provider.dart';
import '../models/room.dart';

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final rooms = hotelProvider.rooms;

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
        onTap: () {},
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                room.images[0],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
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
                            color: _getStatusColor(room.status).withOpacity(0.1),
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
    }
  }
}
