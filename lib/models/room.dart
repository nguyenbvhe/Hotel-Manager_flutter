enum RoomType { standard, deluxe, vip }
enum RoomStatus { available, booked, cleaning }

class Room {
  final String id;
  final String roomNumber;
  final RoomType roomType;
  final double price;
  final RoomStatus status;
  final String description;
  final List<String> images;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.price,
    required this.status,
    required this.description,
    required this.images,
  });

  String get roomTypeString {
    switch (roomType) {
      case RoomType.standard: return 'Standard';
      case RoomType.deluxe: return 'Deluxe';
      case RoomType.vip: return 'VIP';
    }
  }

  String get statusString {
    switch (status) {
      case RoomStatus.available: return 'Trống';
      case RoomStatus.booked: return 'Đã đặt';
      case RoomStatus.cleaning: return 'Đang vệ sinh';
    }
  }
}
