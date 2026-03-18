import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/service.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  String _selectedFilter = 'Tất cả';

  final List<String> _filters = [
    'Tất cả',
    'Chờ thanh toán',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Lịch sử' // include checkedIn, checkedOut, cancelled
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final NumberFormat currencyFmt = NumberFormat('#,###', 'vi_VN');
    final DateFormat dateFmt = DateFormat('HH:mm - dd/MM/yyyy');

    // Lọc ra các đơn đặt phòng (córoomId) và sắp xếp mới nhất lên đầu
    var filteredBookings = provider.bookings
      .where((b) => b.roomId.isNotEmpty)
      .toList();

    // Áp dụng bộ lọc
    if (_selectedFilter != 'Tất cả') {
      filteredBookings = filteredBookings.where((b) {
        if (_selectedFilter == 'Lịch sử') {
          return b.status == BookingStatus.checkedIn || 
                 b.status == BookingStatus.checkedOut || 
                 b.status == BookingStatus.cancelled;
        }
        return b.statusString == _selectedFilter;
      }).toList();
    }

    filteredBookings.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đặt phòng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Filter Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter, style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                    selectedColor: const Color(0xFFD4AF37),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(
                    child: Text(
                      'Không có đơn đặt phòng nào phù hợp',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      
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
          ),
        ],
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(booking.userId).get(),
        builder: (context, snapshot) {
          String customerName = 'Đang tải...';
          String customerPhone = 'Đang tải...';
          
          if (snapshot.hasError) {
            customerName = 'Lỗi dữ liệu';
            customerPhone = 'Lỗi dữ liệu';
          } else if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            customerName = data?['displayName']?.toString() ?? 'Khách';
            customerPhone = data?['phoneNumber']?.toString() ?? 'Không rõ SĐT';
          }

          return Padding(
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
                const SizedBox(height: 16),
                
                Text('Khách: $customerName', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('SĐT: $customerPhone', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                
                Text('Nhận phòng: ${dateFmt.format(booking.checkInDate)}', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                Text('Trả phòng: ${dateFmt.format(booking.checkOutDate)}', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 16),
                
                Text(
                  'Tổng tiền: ${currencyFmt.format(booking.totalPrice)} đ',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                
                if (booking.serviceIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Dịch vụ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: booking.serviceIds.map((id) {
                      final service = provider.services.firstWhere((s) => s.id == id, 
                        orElse: () => HotelService(id: id, name: 'Dịch vụ lạ', price: 0, description: '', image: '', duration: '', category: '')
                      );
                      return Chip(
                        label: Text(service.name, style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFFD4AF37).withAlpha(30),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                if (booking.status == BookingStatus.pending || booking.status == BookingStatus.processing) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleCancel(context, provider, booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (booking.status == BookingStatus.processing) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleConfirm(context, provider, booking),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
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
