enum PaymentStatus { pending, paid }

class Invoice {
  final String id;
  final String bookingId;
  final double roomPrice;
  final double servicePrice;
  final double total;
  final PaymentStatus paymentStatus;

  Invoice({
    required this.id,
    required this.bookingId,
    required this.roomPrice,
    required this.servicePrice,
    required this.total,
    required this.paymentStatus,
  });
}
