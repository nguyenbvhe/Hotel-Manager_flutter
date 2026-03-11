import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import 'package:intl/intl.dart';
import '../../providers/hotel_provider.dart' as hotel_provider;
import '../../services/payos_service.dart';
import 'package:provider/provider.dart';
import 'booking_history_screen.dart';

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
  
  // PayOS State
  int? _orderCode;
  String? _qrData;
  String? _accountNo;
  String? _accountName;
  String? _bin;
  bool _isLoadingQR = true;
  bool _paymentConfirmed = false;
  Timer? _pollingTimer;

  // Tiền cọc cố định
  final double depositAmount = 5000;

  @override
  void initState() {
    super.initState();
    _initPayosPayment();
  }

  Future<void> _initPayosPayment() async {
    // Generate a unique 8 digit integer for PayOS orderCode
    final codeStr = DateTime.now().millisecondsSinceEpoch.toString();
    final code = int.parse(codeStr.substring(codeStr.length - 8));
    
    // Create the payment link
    final data = await PayOSService.createPaymentLink(
      orderCode: code,
      amount: depositAmount.toInt(),
      description: 'DATPHONG $code',
      cancelUrl: 'https://example.com/cancel',
      returnUrl: 'https://example.com/success',
    );

    if (data != null && mounted) {
      setState(() {
        _orderCode = code;
        _qrData = data['qrCode'];
        _accountNo = data['accountNumber'];
        _accountName = data['accountName'];
        _bin = data['bin'];
        _isLoadingQR = false;
      });
      _startPolling(code);
    } else if (mounted) {
      setState(() => _isLoadingQR = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo mã thanh toán PayOS')),
      );
    }
  }

  void _startPolling(int orderCode) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final status = await PayOSService.getPaymentStatus(orderCode);
      if (status == 'PAID' && !_paymentConfirmed) {
        timer.cancel();
        if (mounted) {
          setState(() => _paymentConfirmed = true);
          _handlePaymentSuccess();
        }
      }
    });
  }

  Future<void> _handlePaymentSuccess() async {
    try {
      await context.read<hotel_provider.HotelProvider>().updateBookingStatus(
        widget.booking.id, 
        BookingStatus.processing
      );
      if (mounted) _showConfirmationDialog();
    } catch (e) {
      debugPrint('Auto confirm error: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentConfirmed) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 16),
              Text('Thanh toán thành công!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Đang chuyển hướng...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Thanh toán cọc'),
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
                        child: Text(_bin != null ? _bin! : 'BANK', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      const Text('Mã QR tự động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      CachedNetworkImage(
                        imageUrl: 'https://vietqr.io/img/VIETQR.svg',
                        height: 20,
                        placeholder: (context, url) => const SizedBox(width: 40, height: 20),
                        errorWidget: (context, url, stack) => const SizedBox(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // QR Code Graphic
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _isLoadingQR 
                      ? const SizedBox(
                          width: 200, height: 200, 
                          child: Center(child: CircularProgressIndicator())
                        )
                      : _qrData != null 
                        ? CustomPaint(
                            size: const Size.square(200),
                            painter: QrPainter(
                              data: _qrData!,
                              version: QrVersions.auto,
                              errorCorrectionLevel: QrErrorCorrectLevel.L,
                            ),
                          )
                        : const SizedBox(
                            width: 200, height: 200, 
                            child: Center(child: Icon(Icons.error_outline, size: 50, color: Colors.red))
                          ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isLoadingQR) 
                    const Text('Đang tạo mã QR PayOS...', style: TextStyle(color: Colors.grey))
                  else if (_accountName != null) ...[
                    Text(_accountName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(_accountNo!, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Transfer info
            if (!_isLoadingQR && _orderCode != null)
              Container(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin chuyển khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _infoRow('Số tài khoản', _accountNo ?? '', copyable: true),
                    const Divider(height: 20),
                    _infoRow('Nội dung CK', 'DATPHONG $_orderCode', copyable: true, highlight: true),
                    const Divider(height: 20),
                    _infoRow('Số tiền', '${_fmt.format(depositAmount)} ₫', copyable: true),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Warning
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.autorenew, color: Colors.green[700], size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hệ thống đang tự động kiểm tra giao dịch liên tục. Bạn KHÔNG CẦN bấm nút xác nhận nào cả.',
                      style: TextStyle(color: Colors.green[800], fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
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
                  Clipboard.setData(ClipboardData(text: value.replaceAll(' ₫', '').replaceAll('.', '').trim()));
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
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Phòng ${widget.room.roomNumber} đã được đặt.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hệ thống PayOS đã tự động ghi nhận giao dịch của bạn. Phòng đã được chuyển vào hàng đợi để Quản trị viên duyệt cọc.',
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  elevation: 0,
                ),
                child: const Text('Xem lịch sử đặt phòng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Về trang chủ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
