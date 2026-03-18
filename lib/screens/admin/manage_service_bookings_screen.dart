import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/hotel_provider.dart';
import '../../models/booking.dart';
import '../../models/service.dart';
import '../../models/customer.dart';

class ManageServiceBookingsScreen extends StatefulWidget {
  const ManageServiceBookingsScreen({super.key});

  @override
  State<ManageServiceBookingsScreen> createState() => _ManageServiceBookingsScreenState();
}

class _ManageServiceBookingsScreenState extends State<ManageServiceBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Tất cả', 'Chờ xử lý', 'Đã xác nhận', 'Lịch sử'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final currencyFmt = NumberFormat('#,###', 'vi_VN');
    final dateFmt = DateFormat('HH:mm - dd/MM/yyyy');

    // Filter for standalone service bookings (roomId is empty)
    final allServiceBookings = provider.bookings
        .where((b) => b.roomId.isEmpty && b.serviceIds.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn dịch vụ'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final filteredBookings = allServiceBookings.where((b) {
            if (tab == 'Tất cả') return true;
            if (tab == 'Chờ xử lý') return b.status == BookingStatus.pending;
            if (tab == 'Đã xác nhận') return b.status == BookingStatus.confirmed;
            if (tab == 'Lịch sử') {
              return b.status == BookingStatus.cancelled || 
                     b.status == BookingStatus.checkedOut || 
                     b.status == BookingStatus.checkedIn;
            }
            return true;
          }).toList()..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

          if (filteredBookings.isEmpty) {
            return Center(child: Text('Không có đơn dịch vụ nào trong mục $tab.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
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
                            'Đơn #${booking.id.length > 5 ? booking.id.substring(0, 5).toUpperCase() : booking.id.toUpperCase()}',
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
          );
        }).toList(),
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
      case BookingStatus.processing:
        color = Colors.blue;
        label = 'Đang xử lý';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Đã hủy';
        break;
      case BookingStatus.checkedOut:
        color = Colors.grey;
        label = 'Đã xong';
        break;
      default:
        color = Colors.blueGrey;
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
