import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final hotelProvider = context.watch<HotelProvider>();
    
    // Filter bookings for current user that have at least reached processing status (deposit paid)
    final myPayments = hotelProvider.bookings.where((b) => 
      b.userId == auth.user?.uid && 
      (b.status != BookingStatus.pending && b.status != BookingStatus.cancelled)
    ).toList();
    
    // Sort by check-in date (newest first)
    myPayments.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: myPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Bạn chưa có giao dịch nào',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myPayments.length,
              itemBuilder: (context, index) {
                final booking = myPayments[index];
                final room = hotelProvider.rooms.firstWhere(
                  (r) => r.id == booking.roomId,
                  orElse: () => hotelProvider.rooms.first,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thanh toán cọc phòng ${room.roomNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), // Simplification: using now as mock payment time
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Thành công',
                                style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Số tiền:',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const Text(
                              '5.000 ₫',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Phương thức:',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const Text(
                              'Chuyển khoản (PayOS)',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
}
