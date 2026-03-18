import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/customer.dart';

class ManageCustomersScreen extends StatelessWidget {
  const ManageCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final customers = provider.customers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khách hàng'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: provider.isLoadingCustomers
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? const Center(child: Text('Chưa có khách hàng nào'))
              : ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _buildCustomerItem(context, provider, customer);
                  },
                ),
    );
  }

  Widget _buildCustomerItem(BuildContext context, HotelProvider provider, Customer customer) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[200],
        backgroundImage: customer.avatar.isNotEmpty 
            ? NetworkImage(customer.avatar) 
            : const NetworkImage('https://img.freepik.com/premium-vector/school-boy-vector-illustration_38694-902.jpg?semt=ais_rp_progressive&w=740&q=80'),
      ),
      title: Text(
        customer.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(customer.phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: customer.isBlocked ? Colors.red.withAlpha(25) : Colors.green.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton.icon(
          onPressed: () {
            _showToggleConfirmDialog(context, provider, customer);
          },
          icon: Icon(
            customer.isBlocked ? Icons.lock_open : Icons.block,
            color: customer.isBlocked ? Colors.green : Colors.red,
            size: 20,
          ),
          label: Text(
            customer.isBlocked ? 'MỞ' : 'CHẶN',
            style: TextStyle(
              color: customer.isBlocked ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
