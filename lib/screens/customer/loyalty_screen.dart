import 'package:flutter/material.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data for now
    final int currentPoints = 1250;
    final int nextTierPoints = 2000;
    final double progress = currentPoints / nextTierPoints;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('StayHub Club', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header: Tier Status
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37), size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Hạng Vàng (Gold)',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đang có $currentPoints điểm tích lũy',
                    style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Silver', style: TextStyle(color: Colors.grey)),
                          const Text('Diamond', style: TextStyle(color: Color(0xFFB9F2FF))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Còn ${nextTierPoints - currentPoints} điểm nữa để lên hạng Diamond',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tier Eligibility Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Làm thế nào để nhận thẻ?',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _buildTierRow('Silver', '50 pts', 'Chi tiêu tối thiểu 5tr VNĐ', Colors.grey),
                    _buildTierRow('Gold', '250 pts', 'Chi tiêu tối thiểu 25tr VNĐ', const Color(0xFFD4AF37)),
                    _buildTierRow('Diamond', '500 pts', 'Chi tiêu tối thiểu 50tr VNĐ', const Color(0xFFB9F2FF)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.white12),

            // Benefits Section with Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'Đặc quyền các cấp bậc',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const TabBar(
                    indicatorColor: Color(0xFFD4AF37),
                    labelColor: Color(0xFFD4AF37),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Silver'),
                      Tab(text: 'Gold'),
                      Tab(text: 'Diamond'),
                    ],
                  ),
                  SizedBox(
                    height: 280,
                    child: TabBarView(
                      children: [
                        _buildTierBenefits([
                          'Giảm 10% các dịch vụ tại StayHub (Nâng cấp)',
                          'Wi-Fi tốc độ cao miễn phí (StayHub_Gold)',
                          'Ưu tiên làm thủ tục tại quầy dành riêng',
                          'Tặng 1 chai vang khi đặt hạng phòng Deluxe trở lên',
                        ], Colors.grey),
                        _buildTierBenefits([
                          'Giảm 15% tất cả dịch vụ tại khách sạn',
                          'Ưu tiên làm thủ tục nhận phòng nhanh (Check-in sớm)',
                          'Tặng đồ uống chào mừng đặc biệt',
                          'Cơ hội nâng hạng phòng miễn phí (tùy tình trạng)',
                        ], const Color(0xFFD4AF37)),
                        _buildTierBenefits([
                          'Giảm 25% toàn bộ chi phí lưu trú & dịch vụ',
                          'Miễn phí trả phòng muộn đến 16:00',
                          'Quản gia (Butler) riêng phục vụ suốt kỳ nghỉ',
                          'Đưa đón sân bay bằng xe Limousine miễn phí',
                          'Quyền truy cập khu vực StayHub Executive Lounge',
                        ], const Color(0xFFB9F2FF)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // How to earn points
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white.withAlpha(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cách thức tích điểm',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildEarnItem('Đặt phòng', 'Mỗi 100,000đ chi tiêu = 1 điểm'),
                  _buildEarnItem('Sử dụng dịch vụ', 'Tích điểm cho mỗi lần sử dụng Spa, Nhà hàng'),
                  _buildEarnItem('Giới thiệu bạn bè', 'Nhận ngay 100 điểm khi bạn bè đặt phòng thành công'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTierRow(String name, String points, String condition, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(100)),
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(points, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(condition, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBenefits(List<String> benefits, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: benefits.map((b) => _buildBenefitItem(Icons.check_circle_outline, b, themeColor)).toList(),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: themeColor, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEarnItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14)),
        ],
      ),
    );
  }
}
