import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hotel_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'manage_rooms_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_service_bookings_screen.dart';
import 'manage_customers_screen.dart';
import 'manage_services_screen.dart';


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
    final isManagement = auth.isManagement;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Bảng điều khiển', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
            _buildStatsGrid(provider, isAdmin, isManagement),
            
            if (isAdmin) ...[
              const SizedBox(height: 30),
              _buildRevenueChartSection(provider),
            ],

            if (isManagement) ...[
              const SizedBox(height: 30),
              const Text(
                'Trạng thái phòng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildRoomStatusChart(provider),
            ],

            if (isStaff) ...[
              const SizedBox(height: 30),
              _buildManagementMenu(context),
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

    final sortedEntries = data.entries.toList().reversed.toList();
    final List<BarChartGroupData> barGroups = [];
    
    // Normalize data for combined chart
    double maxRevenue = 0;
    for (var entry in sortedEntries) {
      if (entry.value > maxRevenue) maxRevenue = entry.value;
    }
    if (maxRevenue == 0) maxRevenue = 1000000;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      // Bar Data
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: const Color(0xFF003D82), // Dark blue like in image
              width: 25,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              alignment: BarChartAlignment.spaceAround,
              maxY: maxRevenue * 1.2,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      _formatCurrency(rod.toY),
                      const TextStyle(
                        color: Color(0xFF003D82),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < 0 || value.toInt() >= sortedEntries.length) return const SizedBox.shrink();
                      final entry = sortedEntries[value.toInt()];
                      String text = '';
                      if (_chartType == 'day') {
                        text = '${entry.key}';
                      } else if (_chartType == 'month') {
                        text = 'T.${entry.key}';
                      } else {
                        text = '${2026 - entry.key}';
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Doanh thu thực tế (VNĐ)', const Color(0xFF003D82), isBar: true),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isBar}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: isBar ? 12 : 2,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }

  Widget _buildStatsGrid(HotelProvider provider, bool isAdmin, bool isManagement) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        if (isManagement) ...[
          _buildStatCard('Tổng số phòng', provider.totalRooms.toString(), Icons.meeting_room, const [Color(0xFF2196F3), Color(0xFF1976D2)]),
          _buildStatCard('Phòng đang thuê', provider.bookedRooms.toString(), Icons.check_circle, const [Color(0xFF4CAF50), Color(0xFF388E3C)]),
          _buildStatCard('Phòng trống', provider.availableRooms.toString(), Icons.king_bed, const [Color(0xFFF2994A), Color(0xFFF2C94C)]),
        ],
        if (isAdmin) ...[
          _buildStatCard('Doanh thu ngày', '${_formatCurrency(provider.dailyRevenue)}đ', Icons.today, const [Color(0xFFD4AF37), Color(0xFFB8860B)]),
          _buildStatCard('Doanh thu tháng', '${_formatCurrency(provider.monthlyRevenue)}đ', Icons.calendar_month, const [Color(0xFF00B4DB), Color(0xFF0083B0)]),
          _buildStatCard('Doanh thu năm', '${_formatCurrency(provider.yearlyRevenue)}đ', Icons.analytics, const [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
          _buildStatCard('Tổng doanh thu', '${_formatCurrency(provider.totalRevenue)}đ', Icons.account_balance, const [Color(0xFF373B44), Color(0xFF4286f4)]),
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

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withAlpha(25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomStatusChart(HotelProvider provider) {
    final int cleaning = (provider.totalRooms - provider.bookedRooms - provider.availableRooms);
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: provider.bookedRooms.toDouble(),
                    title: '',
                    color: const Color(0xFF4CAF50),
                    radius: 18,
                  ),
                  PieChartSectionData(
                    value: provider.availableRooms.toDouble(),
                    title: '',
                    color: const Color(0xFFF2994A),
                    radius: 18,
                  ),
                  PieChartSectionData(
                    value: cleaning.toDouble(),
                    title: '',
                    color: const Color(0xFF2196F3),
                    radius: 18,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChartLegend('Đã đặt', provider.bookedRooms.toString(), const Color(0xFF4CAF50)),
                const SizedBox(height: 12),
                _buildChartLegend('Phòng trống', provider.availableRooms.toString(), const Color(0xFFF2994A)),
                const SizedBox(height: 12),
                _buildChartLegend('Đang vệ sinh', cleaning.toString(), const Color(0xFF2196F3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildManagementMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý hệ thống',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 2.2,
          children: [
            _buildGridMenuItem(context, 'Phòng', Icons.room_preferences, const Color(0xFF6C63FF), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsScreen()));
            }),
            _buildGridMenuItem(context, 'Đặt phòng', Icons.book_online, const Color(0xFF4CAF50), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBookingsScreen()));
            }),
            _buildGridMenuItem(context, 'Dịch vụ TL', Icons.auto_awesome, const Color(0xFFD4AF37), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageServicesScreen()));
            }),
            _buildGridMenuItem(context, 'Lịch đặt DV', Icons.receipt_long, const Color(0xFFFFA000), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageServiceBookingsScreen()));
            }),
            _buildGridMenuItem(context, 'Khách hàng', Icons.people, const Color(0xFFE91E63), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCustomersScreen()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildGridMenuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                navigator.pop(); // Close dialog
                try {
                  await context.read<AuthProvider>().signOut();
                  
                  // Since AdminDashboard can be pushed as a separate route, 
                  // we should pop it to return to the home screen after logout.
                  if (mounted && navigator.canPop()) {
                    navigator.pop();
                  }
                  
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Đã đăng xuất thành công')),
                  );
                } catch (e) {
                  debugPrint('Logout error caught: $e');
                  String errorMsg = 'Lỗi khi đăng xuất: $e';
                  if (e.toString().contains('keychain-error')) {
                    errorMsg = 'Lỗi Keychain iOS: Vui lòng bật "Keychain Sharing" trong Xcode > Signing & Capabilities.';
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
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
