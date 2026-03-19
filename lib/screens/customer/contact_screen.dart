import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String primaryColor = '#D4AF37'; // StayHub Gold
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Liên hệ StayHub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image / Map Preview
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withAlpha(150), Colors.transparent],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STAYHUB HOTEL',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      Text(
                        'Dịch vụ 5 sao - Phục vụ 24/7',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin liên hệ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildContactCard(
                    Icons.phone_in_talk_rounded,
                    'Hotline Concierge 24/7',
                    '+84 (0) 24 1234 5678',
                    () => launchUrl(Uri.parse('tel:+842412345678')),
                  ),
                  _buildContactCard(
                    Icons.email_outlined,
                    'Email bộ phận hỗ trợ',
                    'concierge@stayhub.com',
                    () => launchUrl(Uri.parse('mailto:concierge@stayhub.com')),
                  ),
                  _buildContactCard(
                    Icons.location_on_outlined,
                    'Địa chỉ khách sạn',
                    '60 Mậu Lương, Kiến Hưng, Hà Đông, Hà Nội',
                    () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=60+Mậu+Lương+Kiến+Hưng+Hà+Đông')),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Mạng xã hội',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSocialIcon(Icons.facebook, 'Facebook'),
                      _buildSocialIcon(Icons.camera_alt_outlined, 'Instagram'),
                      _buildSocialIcon(Icons.public, 'Website'),
                    ],
                  ),

                  const SizedBox(height: 40),
                  // Luxury Quote
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
                        const SizedBox(height: 8),
                        Text(
                          '"Sự hài lòng của quý khách là ưu tiên số một của chúng tôi"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
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

  Widget _buildContactCard(IconData icon, String title, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(icon, color: Colors.black87),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
