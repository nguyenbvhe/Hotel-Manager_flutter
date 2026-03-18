import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String address;
  final String identityCard;

  final bool isBlocked;
  
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar = '',
    this.address = '',
    required this.identityCard,
    this.isBlocked = false,
  });

  factory Customer.fromMap(Map<String, dynamic>? map, String id) {
    try {
      if (map == null) throw Exception('Data is null');
      return Customer(
        id: id,
        name: map['displayName']?.toString() ?? map['name']?.toString() ?? 'Khách hàng ẩn danh',
        email: map['email']?.toString() ?? '',
        phone: map['phoneNumber']?.toString() ?? map['phone']?.toString() ?? '',
        avatar: map['avatar']?.toString() ?? '',
        address: map['address']?.toString() ?? '',
        identityCard: map['identityCard']?.toString() ?? '',
        isBlocked: map['isBlocked'] == true, // Explicitly check for true to avoid Null errors
      );
    } catch (e) {
      debugPrint('Error mapping Customer (ID: $id): $e');
      return Customer(
        id: id,
        name: 'Lỗi đồng bộ',
        email: 'N/A',
        phone: '',
        identityCard: '',
        isBlocked: false,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': name,
      'email': email,
      'phoneNumber': phone,
      'avatar': avatar,
      'address': address,
      'identityCard': identityCard,
      'isBlocked': isBlocked,
    };
  }
}
