import 'package:flutter/material.dart';
import '../../widgets/custom_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  const BookingScreen({super.key, required this.room});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkInDate;
  TimeOfDay? _checkInTime;
  DateTime? _checkOutDate;
  TimeOfDay? _checkOutTime;
  List<String> _selectedServiceIds = [];
  bool _isLoading = false;

  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (datePicked != null) {
      if (!context.mounted) return;
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 14, minute: 0),
        helpText: 'Chọn giờ nhận phòng',
      );

      if (timePicked != null) {
        setState(() {
          _checkInDate = datePicked;
          _checkInTime = timePicked;
          // Validate checkout date/time
          _validateDates();
        });
      }
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày nhận phòng trước')));
      return;
    }
    
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (datePicked != null) {
      if (!context.mounted) return;
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 12, minute: 0),
        helpText: 'Chọn giờ trả phòng',
      );

      if (timePicked != null) {
        setState(() {
          _checkOutDate = datePicked;
          _checkOutTime = timePicked;
        });
      }
    }
  }

  void _validateDates() {
    if (_checkInDate == null || _checkOutDate == null) return;
    
    final checkIn = DateTime(_checkInDate!.year, _checkInDate!.month, _checkInDate!.day, _checkInTime?.hour ?? 0, _checkInTime?.minute ?? 0);
    final checkOut = DateTime(_checkOutDate!.year, _checkOutDate!.month, _checkOutDate!.day, _checkOutTime?.hour ?? 0, _checkOutTime?.minute ?? 0);

    if (checkOut.isBefore(checkIn.add(const Duration(hours: 1)))) {
      _checkOutDate = null;
      _checkOutTime = null;
    }
  }

  int get _nightsCount {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get _totalPrice {
    double basePrice = _nightsCount * widget.room.price;
    final services = context.read<HotelProvider>().services;
    double servicesPrice = 0;
    for (var id in _selectedServiceIds) {
      final service = services.firstWhere((s) => s.id == id);
      servicesPrice += service.price;
    }
    return basePrice + servicesPrice;
  }

  void _handleBooking() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn đầy đủ ngày nhận/trả phòng!')));
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để đặt phòng!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final checkIn = DateTime(
        _checkInDate!.year,
        _checkInDate!.month,
        _checkInDate!.day,
        _checkInTime!.hour,
        _checkInTime!.minute,
      );
      final checkOut = DateTime(
        _checkOutDate!.year,
        _checkOutDate!.month,
        _checkOutDate!.day,
        _checkOutTime!.hour,
        _checkOutTime!.minute,
      );

      final booking = Booking(
        id: const Uuid().v4(),
        userId: auth.user!.uid,
        roomId: widget.room.id,
        checkInDate: checkIn,
        checkOutDate: checkOut,
        totalPrice: _totalPrice,
        status: BookingStatus.pending,
        serviceIds: _selectedServiceIds,
      );

      // Save booking to Firestore (pending payment), also persist full room data
      await context.read<HotelProvider>().createBooking(booking, widget.room);

      if (mounted) {
        // Navigate to payment screen with QR
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              room: widget.room,
              booking: booking,
              totalPrice: _totalPrice,
              nights: _nightsCount,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đặt phòng: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Xác nhận đặt phòng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomSummaryCard(),
              const SizedBox(height: 30),
              const Text('Thông tin lưu trú', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildDateSelector('Nhận phòng', _checkInDate, _checkInTime, () => _selectCheckInDate(context))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDateSelector('Trả phòng', _checkOutDate, _checkOutTime, () => _selectCheckOutDate(context))),
                ],
              ),
              const SizedBox(height: 30),
              _buildFreeIncludedServices(),
              const SizedBox(height: 30),
              _buildServiceSelection(),
              const SizedBox(height: 30),
              if (_nightsCount > 0)
                _buildPriceDetailsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nightsCount > 0 ? _buildBottomSubmitBar() : null,
    );
  }

  Widget _buildRoomSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: widget.room.images.isNotEmpty ? widget.room.images[0] : 'https://via.placeholder.com/150',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white, width: 80, height: 80),
              ),
              errorWidget: (context, url, stack) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phòng ${widget.room.roomNumber}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(widget.room.roomTypeString, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 5),
                Text('${_currencyFormat.format(widget.room.price)}₫ / đêm', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Chọn ngày',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: date != null ? Colors.black : Colors.grey[400]),
                ),
              ],
            ),
            if (date != null && time != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 8),
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha(100)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Giá phòng x $_nightsCount đêm'),
              Text('${_currencyFormat.format(_nightsCount * widget.room.price)}₫', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (_selectedServiceIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            ..._selectedServiceIds.map((id) {
              final service = context.read<HotelProvider>().services.firstWhere((s) => s.id == id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('+ ${service.name}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text('${_currencyFormat.format(service.price)}₫', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ],
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng tiền', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '${_currencyFormat.format(_totalPrice)}₫', 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSubmitBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('XÁC NHẬN & THANH TOÁN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildFreeIncludedServices() {
    final freeServices = [
      {'icon': Icons.local_drink, 'name': 'Nước uống chào mừng', 'desc': 'Trà thảo mộc khi nhận phòng'},
      {'icon': Icons.wifi, 'name': 'Wi-Fi tốc độ cao', 'desc': 'Truy cập không giới hạn 24/7'},
      {'icon': Icons.cleaning_services, 'name': 'Dọn phòng dọn dẹp', 'desc': 'Làm mới phòng mỗi ngày'},
      {'icon': Icons.pool, 'name': 'Hồ bơi & Gym', 'desc': 'Sử dụng miễn phí tiện ích chung'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dịch vụ miễn phí đi kèm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Tiện ích tiêu chuẩn dành riêng cho khách hàng', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green.withAlpha(50), width: 1),
            boxShadow: [BoxShadow(color: Colors.green.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: freeServices.map((service) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(service['icon'] as IconData, color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            service['desc'] as String,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Miễn phí', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSelection() {
    final services = context.watch<HotelProvider>().services;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nâng tầm trải nghiệm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Tận hưởng kỳ nghỉ trọn vẹn hơn với các dịch vụ cao cấp', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 15),
        ...services.map((service) {
          final isSelected = _selectedServiceIds.contains(service.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedServiceIds.add(service.id);
                  } else {
                    _selectedServiceIds.remove(service.id);
                  }
                });
              },
              title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${_currencyFormat.format(service.price)}₫ • ${service.description}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              activeColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
        }).toList(),
      ],
    );
  }
}
