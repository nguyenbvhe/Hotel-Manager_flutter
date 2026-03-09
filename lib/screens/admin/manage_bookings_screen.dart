import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import 'package:intl/intl.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final NumberFormat currencyFmt = NumberFormat('#,###', 'vi_VN');
    final DateFormat dateFmt = DateFormat('dd/MM/yyyy');

    // Mặc định hiển thị danh sách mới nhất ở trên
    final sortedBookings = List<Booking>.from(provider.bookings)
      ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đặt phòng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: sortedBookings.isEmpty
          ? const Center(
              child: Text(
                'Chưa có đơn đặt phòng nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedBookings.length,
              itemBuilder: (context, index) {
                final booking = sortedBookings[index];
                
                // Cố gắng lấy data phòng tương ứng với booking
                final room = provider.rooms.firstWhere(
                  (r) => r.id == booking.roomId, 
                  orElse: () => Room(
                    id: '', roomNumber: 'N/A', roomType: RoomType.standard, 
                    price: 0, status: RoomStatus.maintenance, 
                    description: '', images: [], amenities: [], 
                    size: 0, maxGuests: 0, bedType: ''
                  )
                );

                return _buildBookingCard(context, booking, room, currencyFmt, dateFmt, provider);
              },
            ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context, 
    Booking booking, 
    Room room, 
    NumberFormat currencyFmt, 
    DateFormat dateFmt,
    HotelProvider provider,
  ) {
    final bool isProcessing = booking.status == BookingStatus.processing;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  'Phòng ${room.roomNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    booking.statusString,
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _infoRow('Khách hàng ID:', booking.userId.substring(0, 8)), // Rút gọn ID cho UI
            const SizedBox(height: 8),
            _infoRow('Nhận phòng:', dateFmt.format(booking.checkInDate)),
            const SizedBox(height: 8),
            _infoRow('Trả phòng:', dateFmt.format(booking.checkOutDate)),
            const SizedBox(height: 8),
            _infoRow('Tổng tiền:', '${currencyFmt.format(booking.totalPrice)} ₫', isBold: true),
            
            if (isProcessing) ...[
              const SizedBox(height: 16),
              // Nút chức năng cho phần duyệt đơn
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleCancel(context, provider, booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleConfirm(context, provider, booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Xác nhận Cọc'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            color: isBold ? const Color(0xFFD4AF37) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.processing: return Colors.blue;
      case BookingStatus.confirmed: return Colors.green;
      case BookingStatus.checkedIn: return Colors.teal;
      case BookingStatus.checkedOut: return Colors.grey;
      case BookingStatus.cancelled: return Colors.red;
    }
  }

  Future<void> _handleConfirm(BuildContext context, HotelProvider provider, Booking booking) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt phòng?'),
        content: const Text('Bạn có chắc chắn đã nhận được tiền cọc và muốn phê duyệt đơn này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.updateBookingStatus(booking.id, BookingStatus.confirmed);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xác nhận thành công!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, HotelProvider provider, Booking booking) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối đặt phòng?'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn này không? Phòng sẽ được trả về trạng thái trống.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Quay lại')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.updateBookingStatus(booking.id, BookingStatus.cancelled, roomId: booking.roomId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã từ chối đơn đặt phòng!'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
