import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'manage_rooms_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              debugPrint('Logout button clicked in Admin Dashboard');
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan khách sạn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatsGrid(provider),
            const SizedBox(height: 30),
            const Text(
              'Trạng thái phòng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildRoomStatusChart(provider),
            const SizedBox(height: 30),
            _buildAdminMenu(context),
            const SizedBox(height: 30),
            _buildSyncDataSection(context, provider),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(HotelProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Tổng số phòng', provider.totalRooms.toString(), Icons.meeting_room, Colors.blue),
        _buildStatCard('Phòng đang thuê', provider.bookedRooms.toString(), Icons.check_circle, Colors.green),
        _buildStatCard('Phòng trống', provider.availableRooms.toString(), Icons.king_bed, Colors.orange),
        _buildStatCard('Doanh thu', '${provider.totalRevenue.toInt()}đ', Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRoomStatusChart(HotelProvider provider) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: provider.bookedRooms.toDouble(),
              title: 'Đã đặt',
              color: Colors.green,
              radius: 50,
              showTitle: false,
            ),
            PieChartSectionData(
              value: provider.availableRooms.toDouble(),
              title: 'Trống',
              color: Colors.orange,
              radius: 50,
              showTitle: false,
            ),
            PieChartSectionData(
              value: (provider.totalRooms - provider.bookedRooms - provider.availableRooms).toDouble(),
              title: 'Vệ sinh',
              color: Colors.blue,
              radius: 50,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý hệ thống',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildMenuItem(context, 'Quản lý phòng', Icons.room_preferences, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsScreen()));
        }),
        _buildMenuItem(context, 'Quản lý đặt phòng', Icons.book_online, () {}),
        _buildMenuItem(context, 'Quản lý khách hàng', Icons.people, () {}),
        _buildMenuItem(context, 'Quản lý dịch vụ', Icons.miscellaneous_services, () {}),
      ],
    );
  }

  Widget _buildSyncDataSection(BuildContext context, HotelProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sync, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                'Cập nhật dữ liệu JW Marriott',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Nhấn nút dưới đây để thay thế toàn bộ dữ liệu hiện tại bằng thông tin và hình ảnh của JW Marriott Hanoi.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                );
                try {
                  await provider.clearAndSyncJWMarriott();
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật dữ liệu JW Marriott thành công!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('CẬP NHẬT NGAY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    debugPrint('Showing logout dialog in Admin Dashboard');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi quyền Admin không?'),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('Logout canceled');
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                debugPrint('Logout confirmed');
                Navigator.of(context).pop();
                context.read<AuthProvider>().signOut();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}
