import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/customer.dart';

import 'package:intl/intl.dart';
import '../../models/booking.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Tất cả', 'Thường', 'VIP'];

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
    
    // Process customers and their spending
    final List<Map<String, dynamic>> processedCustomers = provider.customers.map((customer) {
      final customerBookings = provider.bookings.where((b) => 
        b.userId == customer.id && 
        (b.status == BookingStatus.confirmed || 
         b.status == BookingStatus.checkedIn || 
         b.status == BookingStatus.checkedOut)
      );
      
      double totalSpent = customerBookings.fold(0.0, (sum, b) => sum + b.totalPrice);
      bool isVip = totalSpent >= 5000000;
      
      return {
        'customer': customer,
        'totalSpent': totalSpent,
        'isVip': isVip,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khách hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: provider.isLoadingCustomers
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                final filteredList = processedCustomers.where((item) {
                  if (tab == 'Tất cả') return true;
                  if (tab == 'VIP') return item['isVip'] == true;
                  if (tab == 'Thường') return item['isVip'] == false;
                  return true;
                }).toList()..sort((a, b) => (b['totalSpent'] as double).compareTo(a['totalSpent'] as double));

                if (filteredList.isEmpty) {
                  return Center(child: Text('Không có khách hàng nào trong mục $tab.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    final Customer customer = item['customer'];
                    final double totalSpent = item['totalSpent'];
                    final bool isVip = item['isVip'];
                    
                    return _buildCustomerItem(context, provider, customer, totalSpent, isVip, currencyFmt);
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget _buildCustomerItem(
    BuildContext context, 
    HotelProvider provider, 
    Customer customer, 
    double totalSpent, 
    bool isVip,
    NumberFormat currencyFmt,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: customer.avatar.isNotEmpty 
                ? NetworkImage(customer.avatar) 
                : const NetworkImage('https://img.freepik.com/premium-vector/school-boy-vector-illustration_38694-902.jpg?semt=ais_rp_progressive&w=740&q=80'),
          ),
          if (isVip)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVip) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withAlpha(40),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIP',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(customer.phone.isNotEmpty ? customer.phone : customer.email, 
               style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            'Đã chi: ${currencyFmt.format(totalSpent)}đ',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'block') {
            _showToggleConfirmDialog(context, provider, customer);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'block',
            child: Row(
              children: [
                Icon(customer.isBlocked ? Icons.lock_open : Icons.block, 
                     color: customer.isBlocked ? Colors.green : Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(customer.isBlocked ? 'Mở chặn' : 'Chặn khách'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToggleConfirmDialog(BuildContext context, HotelProvider provider, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(customer.isBlocked ? 'Mở chặn khách hàng?' : 'Chặn khách hàng?'),
        content: Text('Bạn có chắc chắn muốn ${customer.isBlocked ? "mở chặn" : "chặn"} ${customer.name} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              provider.toggleCustomerBlockStatus(customer.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${customer.isBlocked ? "Đã mở chặn" : "Đã chặn"} ${customer.name}'),
                  backgroundColor: customer.isBlocked ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text(
              customer.isBlocked ? 'Mở' : 'Chặn',
              style: TextStyle(color: customer.isBlocked ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
