import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/service.dart';
import 'package:intl/intl.dart';
import 'service_booking_screen.dart';
import '../../providers/auth_provider.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);
    final services = hotelProvider.services;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Dịch vụ Thượng lưu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.room_service_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Không có dịch vụ nào', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) => _buildServiceCard(context, services[index]),
            ),
    );
  }

  Widget _buildServiceCard(BuildContext context, HotelService service) {
    return GestureDetector(
      onTap: () => _showServiceDetails(context, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Service image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 110,
                height: 120, // Taller for service to fit content
                child: CachedNetworkImage(
                  imageUrl: (service.image ?? '').toString().isNotEmpty 
                      ? service.image.toString() 
                      : 'https://images.unsplash.com/photo-1544148103-0773bf10d330',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, stack) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Service info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.name ?? 'Chưa có tên',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.category ?? 'Dịch vụ',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          service.duration ?? 'Liên hệ',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat('#,###', 'vi_VN').format(service.price ?? 0)} ₫',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, HotelService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Top Image with Swipe Indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: CachedNetworkImage(
                    imageUrl: (service.image ?? '').toString().isNotEmpty 
                        ? service.image.toString() 
                        : 'https://images.unsplash.com/photo-1544148103-0773bf10d330',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(150),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      (service.category ?? 'Dịch vụ').toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (service.name ?? 'Chưa có tên').toString(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Thời gian: ${(service.duration ?? 'Liên hệ').toString()}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          '${NumberFormat('#,###', 'vi_VN').format(service.price ?? 0)}₫',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37), 
                            fontWeight: FontWeight.bold, 
                            fontSize: 20
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),
                    
                    const Text(
                      'Giới thiệu dịch vụ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (service.description ?? '').toString(),
                      style: TextStyle(
                        color: Colors.grey[700], 
                        fontSize: 15, 
                        height: 1.6,
                        letterSpacing: 0.3
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        'Đóng', 
                        style: TextStyle(
                          color: Color(0xFFD4AF37), 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (context.read<AuthProvider>().isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceBookingScreen(service: service),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng đăng nhập để đặt dịch vụ')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: const Color(0xFFD4AF37).withAlpha(100),
                      ),
                      child: const Text(
                        'Đặt dịch vụ', 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
