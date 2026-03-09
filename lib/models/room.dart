import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime? statusUntil;
  final DateTime? statusStartedAt;

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
    this.statusUntil,
    this.statusStartedAt,
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
      statusUntil: map['statusUntil'] != null ? (map['statusUntil'] as Timestamp).toDate() : null,
      statusStartedAt: map['statusStartedAt'] != null ? (map['statusStartedAt'] as Timestamp).toDate() : null,
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
      'statusUntil': statusUntil,
      'statusStartedAt': statusStartedAt,
    };
  }

  bool get isStatusExpired {
    if (statusUntil == null) return false;
    return DateTime.now().isAfter(statusUntil!);
  }

  Duration? get statusTimeRemaining {
    if (statusUntil == null) return null;
    final diff = statusUntil!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get statusTimeRemainingString {
    final duration = statusTimeRemaining;
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes phút';
    final hours = duration.inHours;
    final remainingMins = minutes % 60;
    return '$hours giờ $remainingMins phút';
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
