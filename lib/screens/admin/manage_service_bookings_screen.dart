import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/hotel_provider.dart';
import '../../models/booking.dart';
import '../../models/service.dart';
import '../../models/customer.dart';

class ManageServiceBookingsScreen extends StatelessWidget {
  const ManageServiceBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final currencyFmt = NumberFormat('#,###', 'vi_VN');
    final dateFmt = DateFormat('HH:mm - dd/MM/yyyy');

    // Filter for standalone service bookings (roomId is empty)
    final serviceBookings = provider.bookings
        .where((b) => b.roomId.isEmpty && b.serviceIds.isNotEmpty)
        .toList()
      ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn dịch vụ'),
      ),
      body: serviceBookings.isEmpty
          ? const Center(child: Text('Chưa có đơn dịch vụ nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: serviceBookings.length,
              itemBuilder: (context, index) {
                final booking = serviceBookings[index];
                final service = provider.services.firstWhere(
                  (s) => booking.serviceIds.contains(s.id),
                  orElse: () => HotelService(
                    id: '',
                    name: 'Dịch vụ không xác định',
                    price: 0,
                    description: '',
                    image: '',
                    duration: '',
                    category: '',
                  ),
                );

                final customer = provider.customers.firstWhere(
                  (c) => c.id == booking.userId,
                  orElse: () => Customer(
                    id: '', 
                    name: 'Khách hàng', 
                    email: '', 
                    phone: '', 
                    identityCard: '',
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đơn #${booking.id.substring(0, 5).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            _buildStatusBadge(booking.status),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: service.image.isNotEmpty 
                                ? Image.network(service.image, width: 60, height: 60, fit: BoxFit.cover)
                                : Container(color: Colors.grey[200], width: 60, height: 60, child: const Icon(Icons.broken_image)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thời gian: ${dateFmt.format(booking.checkInDate)}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (customer.phone.isNotEmpty)
                                  Text(
                                    customer.phone,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                            Text(
                              '${currencyFmt.format(booking.totalPrice)}đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFD4AF37),
                              ),
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
      case BookingStatus.confirmed:
        color = Colors.green;
        label = 'Đã xác nhận';
        break;
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'Chờ xử lý';
        break;
      default:
        color = Colors.grey;
        label = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
