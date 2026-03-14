import 'package:flutter/material.dart';

enum BookingStatus { pending, processing, confirmed, checkedIn, checkedOut, cancelled }

class Booking {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final BookingStatus status;
  final List<String> serviceIds;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.status,
    this.serviceIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'roomId': roomId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.name,
      'serviceIds': serviceIds,
    };
  }

  factory Booking.fromMap(Map<String, dynamic>? map, String id) {
    try {
      return Booking(
        id: id,
        userId: map?['userId']?.toString() ?? '',
        roomId: map?['roomId']?.toString() ?? '',
        checkInDate: DateTime.tryParse(map?['checkInDate']?.toString() ?? '') ?? DateTime.now(),
        checkOutDate: DateTime.tryParse((map?['checkOutDate'] ?? '').toString()) ?? DateTime.now().add(const Duration(days: 1)),
        totalPrice: (map?['totalPrice'] as num? ?? 0.0).toDouble(),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == map?['status'],
          orElse: () => BookingStatus.pending,
        ),
        serviceIds: (map?['serviceIds'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
      );
    } catch (e) {
      debugPrint('Error parsing Booking (ID: $id): $e');
      return Booking(
        id: id,
        userId: '',
        roomId: '',
        checkInDate: DateTime.now(),
        checkOutDate: DateTime.now(),
        totalPrice: 0,
        status: BookingStatus.pending,
      );
    }
  }

  String get statusString {
    switch (status) {
      case BookingStatus.pending: return 'Chờ thanh toán';
      case BookingStatus.processing: return 'Chờ xác nhận';
      case BookingStatus.confirmed: return 'Đã xác nhận';
      case BookingStatus.checkedIn: return 'Đang ở';
      case BookingStatus.checkedOut: return 'Đã trả phòng';
      case BookingStatus.cancelled: return 'Đã hủy';
    }
  }
}
