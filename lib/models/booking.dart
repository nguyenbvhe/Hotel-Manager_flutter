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

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      roomId: map['roomId'] ?? '',
      checkInDate: DateTime.parse(map['checkInDate']),
      checkOutDate: DateTime.parse(map['checkOutDate']),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
    );
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
