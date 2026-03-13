import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/room.dart';
import 'room_list_screen.dart';
import 'room_detail_screen.dart';
import 'profile_screen.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../models/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == 'admin';

    final List<Widget> pages = [
      const _HomeContent(),
      isAdmin ? const AdminDashboard() : const ProfileScreen(),
    ];

    final showBottomBar = !(selectedIndex == 1 && !auth.isLoggedIn && !isAdmin);

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: showBottomBar 
        ? BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => setState(() => selectedIndex = index),
            selectedItemColor: const Color(0xFFD4AF37),
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
              BottomNavigationBarItem(
                icon: Icon(isAdmin ? Icons.dashboard : Icons.person),
                label: isAdmin ? 'Dashboard' : 'Cá nhân',
              ),
            ],
          )
        : null,
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          actions: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.role == 'admin') {
                  return IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                    tooltip: 'Admin Dashboard',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboard()),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('G-Hotel', style: TextStyle(color: Colors.white)),
            background: ExcludeSemantics(
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb',
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(76),
                colorBlendMode: BlendMode.darken,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng bạn đến với G-Hotel',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trải nghiệm kỳ nghỉ tuyệt vời của bạn',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                _buildSectionHeader(context, 'Loại phòng', () {}),
                const SizedBox(height: 15),
                _buildRoomTypes(context),
                const SizedBox(height: 30),
                _buildSectionHeader(context, 'Dịch vụ Thượng lưu', () {}),
                const SizedBox(height: 15),
                _buildLuxuryServices(context),
                const SizedBox(height: 30),
                _buildSectionHeader(context, 'Phòng nổi bật', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomListScreen()),
                  );
                }),
                const SizedBox(height: 15),
                _buildFeaturedRooms(context),
                const SizedBox(height: 30),
                _buildSectionHeader(context, 'Vị trí khách sạn', () {}),
                const SizedBox(height: 15),
                _buildLocationCard(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    const String address = '60 Mậu Lương, Kiến Hưng, Hà Đông';
    const String mapUrl = 'https://www.google.com/maps/search/?api=1&query=60+Mậu+Lương+Kiến+Hưng+Hà+Đông';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white, height: 180),
                  ),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[300], height: 180),
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withAlpha(100)],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 15,
                  left: 15,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFD4AF37), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'G-Hotel Hà Đông',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào mừng bạn đến với G-Hotel',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(mapUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('XEM TRÊN BẢN ĐỒ', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text('Xem tất cả'),
        ),
      ],
    );
  }

  Widget _buildRoomTypes(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: RoomType.values.length,
        itemBuilder: (context, index) {
          final type = RoomType.values[index];
          return _buildTypeItem(context, type);
        },
      ),
    );
  }

  Widget _buildTypeItem(BuildContext context, RoomType type) {
    final isRomantic = type == RoomType.romantic;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RoomListScreen(selectedType: type)),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 15, bottom: 10), // Thêm bottom margin để bóng không bị cắt
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 26)), // Tăng size icon nhẹ
            const SizedBox(height: 10),
            Text(
              type.label, 
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold, // Đậm hơn cho rõ ràng
                color: isRomantic ? const Color(0xFFD02090) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedRooms(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final rooms = hotelProvider.rooms.take(5).toList();

    return Column(
      children: rooms.map((room) => _buildRoomCard(context, room)).toList(),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    final isRomantic = room.roomType == RoomType.romantic;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  ExcludeSemantics(
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: room.images.isNotEmpty ? room.images[0] : 'https://via.placeholder.com/600x400',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white, height: 220),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          height: 220,
                          child: const Icon(Icons.error_outline, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (isRomantic)
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1493).withAlpha(204),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'ROMANTIC',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Phòng ${room.roomNumber} - ${room.roomTypeString}',
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        '${room.price.toInt()}đ',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    room.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildMiniAmenity(Icons.wifi, 'Wi-Fi'),
                      _buildMiniAmenity(Icons.ac_unit, 'AC'),
                      _buildMiniAmenity(Icons.tv, 'Smart TV'),
                      if (room.roomType == RoomType.vip) _buildMiniAmenity(Icons.pool, 'Bể bơi'),
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

  Widget _buildMiniAmenity(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLuxuryServices(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);
    final services = provider.services;

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceItem(context, service);
        },
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, HotelService service) {
    IconData icon;
    Color color;

    // Assign icons based on service ID or name keywords
    if (service.name.contains('Ăn sáng') || service.name.contains('Bữa tối')) {
      icon = Icons.restaurant;
      color = Colors.orange;
    } else if (service.name.contains('Trà chiều')) {
      icon = Icons.coffee;
      color = Colors.brown;
    } else if (service.name.contains('Spa')) {
      icon = Icons.spa;
      color = Colors.teal;
    } else if (service.name.contains('Limousine')) {
      icon = Icons.directions_car;
      color = Colors.black;
    } else {
      icon = Icons.stars;
      color = const Color(0xFFD4AF37);
    }

    return InkWell(
      onTap: () => _showServiceDetails(context, service, icon, color),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              service.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat('#,###').format(service.price) + '₫',
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, HotelService service, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat('#,###').format(service.price) + '₫',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Chi tiết dịch vụ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              service.description,
              style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Đóng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
