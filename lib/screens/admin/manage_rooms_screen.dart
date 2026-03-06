import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/room.dart';

class ManageRoomsScreen extends StatelessWidget {
  const ManageRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final rooms = provider.rooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRoomDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(room.status).withOpacity(0.2),
              child: Text(room.roomNumber, style: TextStyle(color: _getStatusColor(room.status))),
            ),
            title: Text('Phòng ${room.roomNumber} - ${room.roomTypeString}'),
            subtitle: Text('${room.price.toInt()}đ - ${room.statusString}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showRoomDialog(context, room: room),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteRoom(room.id),
                ),
              ],
            ),
          );
        },
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

  void _showRoomDialog(BuildContext context, {Room? room}) {
    // Basic dialog for add/edit room
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(room == null ? 'Thêm phòng mới' : 'Sửa thông tin phòng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Số phòng')),
            TextField(decoration: InputDecoration(labelText: 'Giá')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Lưu')),
        ],
      ),
    );
  }
}
