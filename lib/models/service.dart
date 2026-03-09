class HotelService {
  final String id;
  final String name;
  final double price;
  final String description;

  HotelService({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }

  factory HotelService.fromMap(Map<String, dynamic> map, String id) {
    return HotelService(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
    );
  }
}
