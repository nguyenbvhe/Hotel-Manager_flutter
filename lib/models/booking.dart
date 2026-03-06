enum BookingStatus { pending, checkedIn, checkedOut, cancelled }

class Booking {
  final String id;
  final String userId;
  final String roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.status,
  });
}
