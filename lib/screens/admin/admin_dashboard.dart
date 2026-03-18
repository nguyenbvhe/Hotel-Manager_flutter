import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'manage_rooms_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_service_bookings_screen.dart';
import 'manage_customers_screen.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _chartType = 'day'; // 'day', 'month', 'year'
  bool _isCustomerInfoLocked = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final isStaff = auth.isStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              debugPrint('Logout button clicked');
              _showLogoutDialog(context, isAdmin);
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
            _buildStatsGrid(provider, isAdmin, isStaff),
            
            if (isAdmin) ...[
              const SizedBox(height: 30),
              _buildRevenueChartSection(provider),
            ],

            if (isStaff) ...[
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
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartSection(HotelProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Biểu đồ doanh thu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _chartType,
              items: const [
                DropdownMenuItem(value: 'day', child: Text('Ngày')),
                DropdownMenuItem(value: 'month', child: Text('Tháng')),
                DropdownMenuItem(value: 'year', child: Text('Năm')),
              ],
              onChanged: (val) => setState(() => _chartType = val!),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)],
          ),
          child: _buildRevenueChart(provider),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(HotelProvider provider) {
    Map<int, double> data;
    if (_chartType == 'day') {
      data = provider.getDailyRevenueData();
    } else if (_chartType == 'month') {
      data = provider.getMonthlyRevenueData();
    } else {
      data = provider.getYearlyRevenueData();
    }

    final List<BarChartGroupData> barGroups = data.entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: const Color(0xFFD4AF37),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups.reversed.toList(),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('0');
                return Text(_formatCurrency(value));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (_chartType == 'day') {
                  text = '${value.toInt()}';
                } else if (_chartType == 'month') {
                  text = 'T.${value.toInt()}';
                } else {
                  text = '${2026 - value.toInt()}';
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(HotelProvider provider, bool isAdmin, bool isStaff) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        if (isStaff) ...[
          _buildStatCard('Tổng số phòng', provider.totalRooms.toString(), Icons.meeting_room, Colors.blue),
          _buildStatCard('Phòng đang thuê', provider.bookedRooms.toString(), Icons.check_circle, Colors.green),
          _buildStatCard('Phòng trống', provider.availableRooms.toString(), Icons.king_bed, Colors.orange),
        ],
        if (isAdmin) ...[
          _buildStatCard('Doanh thu ngày', '${_formatCurrency(provider.dailyRevenue)}đ', Icons.today, Colors.orange),
          _buildStatCard('Doanh thu tháng', '${_formatCurrency(provider.monthlyRevenue)}đ', Icons.calendar_month, Colors.teal),
          _buildStatCard('Doanh thu năm', '${_formatCurrency(provider.yearlyRevenue)}đ', Icons.analytics, Colors.indigo),
          _buildStatCard('Tổng doanh thu', '${_formatCurrency(provider.totalRevenue)}đ', Icons.account_balance, Colors.purple),
        ],
      ],
    );
  }

  String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
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
        _buildMenuItem(context, 'Quản lý đặt phòng', Icons.book_online, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBookingsScreen()));
        }),
        _buildMenuItem(context, 'Quản lý đơn dịch vụ', Icons.receipt_long, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageServiceBookingsScreen()));
        }),
        _buildMenuItem(
          context, 
          'Quản lý khách hàng', 
          Icons.people, 
          () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const ManageCustomersScreen())
            );
          },
        ),
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
                'Cập nhật dữ liệu StayHub',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Nhấn nút dưới đây để nạp thêm hoặc cập nhật các phòng/dịch vụ chuẩn của StayHub. Các phòng bạn đã tự thêm sẽ không bị mất.',
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
                  await provider.syncStayHubData();
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật dữ liệu StayHub thành công!')),
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

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, bool isAdmin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất khỏi quyền ${isAdmin ? "Admin" : "Nhân viên"} không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
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
