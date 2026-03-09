enum RoomType { standard, deluxe, suite, vip, romantic }

extension RoomTypeExtension on RoomType {
  String get label {
    switch (this) {
      case RoomType.standard: return 'Standard';
      case RoomType.deluxe: return 'Deluxe';
      case RoomType.suite: return 'Suite';
      case RoomType.vip: return 'VIP';
      case RoomType.romantic: return 'Romantic';
    }
  }

  String get icon {
    switch (this) {
      case RoomType.standard: return '🛏';
      case RoomType.deluxe: return '🛏🛏';
      case RoomType.suite: return '🏢';
      case RoomType.vip: return '⭐';
      case RoomType.romantic: return '❤️';
    }
  }
}

enum RoomStatus { available, booked, cleaning, maintenance }

class Room {
  final String id;
  final String roomNumber;
  final RoomType roomType;
  final double price;
  final RoomStatus status;
  final String description;
  final List<String> images;
  final List<String> amenities;
  final double size;
  final int maxGuests;
  final String bedType;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.price,
    required this.status,
    required this.description,
    required this.images,
    required this.amenities,
    required this.size,
    required this.maxGuests,
    required this.bedType,
  });

  factory Room.fromMap(Map<String, dynamic> map, String docId) {
    return Room(
      id: docId,
      roomNumber: map['roomNumber'] ?? '',
      roomType: RoomType.values.firstWhere(
        (e) => e.name == map['roomType'], 
        orElse: () => RoomType.standard
      ),
      price: (map['price'] ?? 0).toDouble(),
      status: RoomStatus.values.firstWhere(
        (e) => e.name == map['status'], 
        orElse: () => RoomStatus.available
      ),
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      size: (map['size'] ?? 0).toDouble(),
      maxGuests: map['maxGuests'] ?? 2,
      bedType: map['bedType'] ?? 'King Size',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'roomType': roomType.name,
      'price': price,
      'status': status.name,
      'description': description,
      'images': images,
      'amenities': amenities,
      'size': size,
      'maxGuests': maxGuests,
      'bedType': bedType,
    };
  }

  String get roomTypeString => roomType.label;
  String get roomTypeIcon => roomType.icon;

  String get statusString {
    switch (status) {
      case RoomStatus.available: return 'Trống';
      case RoomStatus.booked: return 'Đã đặt';
      case RoomStatus.cleaning: return 'Đang vệ sinh';
      case RoomStatus.maintenance: return 'Bảo trì';
    }
  }
}
