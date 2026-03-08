import 'package:flutter/material.dart';
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
  DateTime? _checkOutDate;
  bool _isLoading = false;

  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        // Validate checkout date
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!.add(const Duration(days: 1)))) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày nhận phòng trước')));
      return;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  int get _nightsCount {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double get _totalPrice {
    return _nightsCount * widget.room.price;
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
      final booking = Booking(
        id: const Uuid().v4(),
        userId: auth.user!.uid,
        roomId: widget.room.id,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        totalPrice: _totalPrice,
        status: BookingStatus.pending,
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
                  Expanded(child: _buildDateSelector('Nhận phòng', _checkInDate, () => _selectCheckInDate(context))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDateSelector('Trả phòng', _checkOutDate, () => _selectCheckOutDate(context))),
                ],
              ),
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
            child: Image.network(
              widget.room.images.isNotEmpty ? widget.room.images[0] : 'https://via.placeholder.com/150',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
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

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Chọn ngày',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: date != null ? Colors.black : Colors.grey[400]),
            ),
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
              Text('${_currencyFormat.format(_totalPrice)}₫', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
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
}
