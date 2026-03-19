import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/room.dart';
import 'room_detail_screen.dart';

class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  RoomType? _filterType;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final rooms = provider.rooms;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Sơ đồ tầng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Legend & Filter
          _buildHeader(rooms),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Elevator & Stairs (Decoration)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIconAesthetic(Icons.elevator, 'Thang máy'),
                      const SizedBox(width: 50),
                      _buildIconAesthetic(Icons.stairs, 'Lối thoát hiểm'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // The Floor Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      // Apply filter if selected
                      bool isDimmed = _filterType != null && room.roomType != _filterType;
                      
                      return _buildRoomNode(context, room, isDimmed);
                    },
                  ),

                  const SizedBox(height: 50),
                  const Text(
                    'Hướng nhìn ra Khu vực Công viên / Biển',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<Room> rooms) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Tất cả'),
                ...RoomType.values.map((type) => _buildFilterChip(type, type.label)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendPair(Colors.green, 'Trống'),
              const SizedBox(width: 15),
              _buildLegendPair(const Color(0xFFD4AF37), 'Bận'),
              const SizedBox(width: 15),
              _buildLegendPair(Colors.red[300]!, 'Sửa chữa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(RoomType? type, String label) {
    bool isSelected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        selectedColor: const Color(0xFFD4AF37),
        onSelected: (val) => setState(() => _filterType = val ? type : null),
      ),
    );
  }

  Widget _buildLegendPair(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildIconAesthetic(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 30),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
      ],
    );
  }

  Widget _buildRoomNode(BuildContext context, Room room, bool isDimmed) {
    Color statusColor;
    switch (room.status) {
      case RoomStatus.available: statusColor = Colors.green; break;
      case RoomStatus.booked: statusColor = const Color(0xFFD4AF37); break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isDimmed ? 0.3 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: statusColor.withAlpha(100), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                room.status == RoomStatus.available ? Icons.meeting_room : Icons.no_meeting_room_outlined,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                room.roomNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                room.roomType.label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
