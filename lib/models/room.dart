import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  factory Room.fromMap(Map<String, dynamic>? map, String docId) {
    try {
      return Room(
        id: docId,
        roomNumber: (map?['roomNumber'] ?? '').toString(),
        roomType: RoomType.values.firstWhere(
          (e) => e.name == map?['roomType'], 
          orElse: () => RoomType.standard
        ),
        price: (map?['price'] as num? ?? 0.0).toDouble(),
        status: RoomStatus.values.firstWhere(
          (e) => e.name == map?['status'], 
          orElse: () => RoomStatus.available
        ),
        description: (map?['description'] ?? '').toString(),
        images: (map?['images'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
        amenities: (map?['amenities'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
        size: (map?['size'] as num? ?? 0).toDouble(),
        maxGuests: (map?['maxGuests'] as num? ?? 2).toInt(),
        bedType: (map?['bedType'] ?? 'King Size').toString(),
        statusUntil: map?['statusUntil'] != null && map?['statusUntil'] is Timestamp ? (map!['statusUntil'] as Timestamp).toDate() : null,
        statusStartedAt: map?['statusStartedAt'] != null && map?['statusStartedAt'] is Timestamp ? (map!['statusStartedAt'] as Timestamp).toDate() : null,
      );
    } catch (e) {
      debugPrint('Error parsing Room (ID: $docId): $e');
      return Room(
        id: docId,
        roomNumber: 'ERR',
        roomType: RoomType.standard,
        price: 0,
        status: RoomStatus.available,
        description: '',
        images: [],
        amenities: [],
        size: 0,
        maxGuests: 0,
        bedType: '',
      );
    }
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
