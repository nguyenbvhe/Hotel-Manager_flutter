import 'package:flutter/material.dart';

class HotelService {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final String duration;
  final String category;

  HotelService({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.duration,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'duration': duration,
      'category': category,
    };
  }

  factory HotelService.fromMap(Map<String, dynamic>? map, String id) {
    try {
      return HotelService(
        id: id,
        name: map?['name']?.toString() ?? '',
        price: (map?['price'] as num? ?? 0.0).toDouble(),
        description: map?['description']?.toString() ?? '',
        image: map?['image']?.toString() ?? 'https://images.unsplash.com/photo-1544148103-0773bf10d330',
        duration: map?['duration']?.toString() ?? 'Liên hệ',
        category: map?['category']?.toString() ?? 'Dịch vụ',
      );
    } catch (e) {
      debugPrint('Error parsing HotelService (ID: $id): $e');
      return HotelService(
        id: id,
        name: 'Dịch vụ lỗi',
        price: 0,
        description: '',
        image: 'https://images.unsplash.com/photo-1544148103-0773bf10d330',
        duration: '',
        category: 'Lỗi',
      );
    }
  }
}
