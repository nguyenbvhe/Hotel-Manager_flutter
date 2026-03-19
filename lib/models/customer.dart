import 'package:flutter/material.dart';

enum MembershipTier { silver, gold, diamond }

extension MembershipTierExtension on MembershipTier {
  String get label {
    switch (this) {
      case MembershipTier.silver: return 'Silver';
      case MembershipTier.gold: return 'Gold';
      case MembershipTier.diamond: return 'Diamond';
    }
  }

  Color get color {
    switch (this) {
      case MembershipTier.silver: return Colors.grey;
      case MembershipTier.gold: return const Color(0xFFD4AF37);
      case MembershipTier.diamond: return const Color(0xFFB9F2FF);
    }
  }
}

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String address;
  final String identityCard;
  final bool isBlocked;
  
  // Loyalty Program fields
  final int points;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar = '',
    this.address = '',
    required this.identityCard,
    this.isBlocked = false,
    this.points = 0,
  });

  MembershipTier get tier {
    if (points >= 2000) return MembershipTier.diamond;
    if (points >= 500) return MembershipTier.gold;
    return MembershipTier.silver;
  }

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
        isBlocked: map['isBlocked'] == true,
        points: map['points'] as int? ?? 0,
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
        points: 0,
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
      'points': points,
    };
  }
}
