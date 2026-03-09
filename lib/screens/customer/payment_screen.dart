import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import 'package:intl/intl.dart';
import '../../providers/hotel_provider.dart' as hotel_provider;
import 'package:provider/provider.dart';

// Bank info constants - BIDV account
const _bankId = 'BIDV';
const _accountNo = '4270992888';
const _accountName = 'BUI VAN NGUYEN';

class PaymentScreen extends StatefulWidget {
  final Room room;
  final Booking booking;
  final double totalPrice;
  final int nights;

  const PaymentScreen({
    super.key,
    required this.room,
    required this.booking,
    required this.totalPrice,
    required this.nights,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');
  bool _paymentConfirmed = false;

  // Tiền cọc cố định
  final double depositAmount = 5000;

  String get _transferNote => 'Datphong${widget.room.roomNumber}${widget.booking.id.substring(0, 6).toUpperCase()}';

  String get _qrUrl {
    return 'https://img.vietqr.io/image/$_bankId-$_accountNo-compact2.png'
        '?amount=${depositAmount.toInt()}'
        '&addInfo=${Uri.encodeComponent(_transferNote)}'
        '&accountName=${Uri.encodeComponent(_accountName)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header amount
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Text('Tiền cọc giữ phòng (cố định)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${_fmt.format(depositAmount)} ₫',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phòng ${widget.room.roomNumber} (Tổng giá: ${_fmt.format(widget.totalPrice)} ₫)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // QR Code Card
            Container(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003087),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('BIDV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      const Text('VietQR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      Image.network(
                        'https://vietqr.io/img/VIETQR.svg',
                        height: 20,
                        errorBuilder: (context, error, stack) => const SizedBox(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // QR Code
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _qrUrl,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stack) => Container(
                          width: 220,
                          height: 220,
                          color: Colors.grey[100],
                          child: const Center(child: Icon(Icons.qr_code_2, size: 60, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(_accountName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(_accountNo, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('BIDV - CN Quang Minh', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Transfer info
            Container(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin chuyển khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _infoRow('Số tài khoản', _accountNo, copyable: true),
                  const Divider(height: 20),
                  _infoRow('Nội dung CK', _transferNote, copyable: true, highlight: true),
                  const Divider(height: 20),
                  _infoRow('Số tiền', '${_fmt.format(depositAmount)} ₫'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Warning
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vui lòng nhập đúng nội dung chuyển khoản để đặt phòng được xác nhận nhanh nhất.',
                      style: TextStyle(color: Colors.orange[800], fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom confirm button
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 15, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _paymentConfirmed ? null : () async {
                setState(() => _paymentConfirmed = true);
                try {
                  // Cập nhật trạng thái thành processing
                  await context.read<hotel_provider.HotelProvider>().updateBookingStatus(
                    widget.booking.id, 
                    BookingStatus.processing
                  );
                  if (!mounted) return;
                  _showConfirmationDialog();
                } catch (e) {
                  if (!mounted) return;
                  setState(() => _paymentConfirmed = false);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi cập nhật: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                '✅ Tôi đã chuyển khoản xong',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool copyable = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: highlight ? const Color(0xFFD4AF37) : Colors.black,
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép!'), duration: Duration(seconds: 1)),
                  );
                },
                child: Icon(Icons.copy, size: 16, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Đặt phòng thành công!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phòng ${widget.room.roomNumber} đã được đặt.'),
            const SizedBox(height: 8),
            const Text('Chúng tôi sẽ xác nhận thanh toán trong 5-15 phút. Cảm ơn bạn đã đặt phòng!',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Về trang chủ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
