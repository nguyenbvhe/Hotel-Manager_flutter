import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/room.dart';
import 'add_edit_room_screen.dart';

class ManageRoomsScreen extends StatelessWidget {
  const ManageRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final rooms = provider.rooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý phòng'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: rooms.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(room.status).withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  room.roomNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(room.status),
                  ),
                ),
              ),
            ),
            title: Text(
              'Phòng ${room.roomNumber} - ${room.roomTypeString}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${room.price.toInt()}đ / đêm'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(room.status).withAlpha(40),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    room.statusString,
                    style: TextStyle(fontSize: 12, color: _getStatusColor(room.status)),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditRoomScreen(room: room)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, provider, room),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditRoomScreen()),
        ),
        label: const Text('Thêm phòng'),
        icon: const Icon(Icons.add),
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

  void _confirmDelete(BuildContext context, HotelProvider provider, Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phòng ${room.roomNumber} không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteRoom(room.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa phòng ${room.roomNumber}')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
