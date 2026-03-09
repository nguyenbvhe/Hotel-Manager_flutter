import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final hotelProvider = context.watch<HotelProvider>();
    
    // Filter bookings for current user
    final myBookings = hotelProvider.bookings.where((b) => b.userId == auth.user?.uid).toList();
    // Sort by check-in date (newest first)
    myBookings.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đặt phòng'),
      ),
      body: myBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Bạn chưa có đơn đặt phòng nào',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: myBookings.length,
              itemBuilder: (context, index) {
                final booking = myBookings[index];
                final room = hotelProvider.rooms.firstWhere(
                  (r) => r.id == booking.roomId,
                  orElse: () => hotelProvider.rooms.first, // Fallback
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phòng ${room.roomNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            _buildStatusBadge(booking.status),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(booking.checkInDate)} - ${DateFormat('dd/MM/yyyy').format(booking.checkOutDate)}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng thanh toán:', style: TextStyle(color: Colors.grey)),
                            Text(
                              '${booking.totalPrice.toInt()}đ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String label;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'Chờ xử lý';
        break;
      case BookingStatus.processing:
        color = Colors.blue;
        label = 'Chờ xác nhận';
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        label = 'Đã xác nhận';
        break;
      case BookingStatus.checkedIn:
        color = Colors.green;
        label = 'Đã nhận phòng';
        break;
      case BookingStatus.checkedOut:
        color = Colors.blue;
        label = 'Đã trả phòng';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
