import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PayOSService {
  static const String _clientId = '473c2c6a-72e8-43bd-99e0-85ea3f00b037';
  static const String _apiKey = '6eae85b1-4d70-41d4-a4cb-be80008096b9';
  static const String _checksumKey = 'ba375ee0bb5cdeda05b29e1e6eb48046a6003947666fa211c18d6d03b9439d74';
  
  static const String _baseUrl = 'https://api-merchant.payos.vn/v2/payment-requests';

  /// Khởi tạo một Payment Link trên PayOS. Trả về đối tượng chứa qrCode và checkoutUrl
  static Future<Map<String, dynamic>?> createPaymentLink({
    required int orderCode,
    required int amount,
    required String description,
    required String cancelUrl,
    required String returnUrl,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'orderCode': orderCode,
        'amount': amount,
        'description': description,
        'cancelUrl': cancelUrl,
        'returnUrl': returnUrl,
      };

      // Tạo chuỗi signature theo chuẩn báo cáo của PayOS:
      // Các trường phải được xếp theo thứ tự alpha: amount, cancelUrl, description, orderCode, returnUrl
      final String rawSignature = 'amount=$amount&cancelUrl=$cancelUrl&description=$description&orderCode=$orderCode&returnUrl=$returnUrl';
      
      final hmac = Hmac(sha256, utf8.encode(_checksumKey));
      final dig = hmac.convert(utf8.encode(rawSignature));
      body['signature'] = dig.toString();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-client-id': _clientId,
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);
      if (decoded['code'] == '00') {
        return decoded['data'];
      } else {
        debugPrint('PayOS Create Error: ${decoded['desc']}');
        return null;
      }
    } catch (e) {
      debugPrint('PayOS Create Exception: $e');
      return null;
    }
  }

  /// Gọi API kiểm tra liên tục xem khách đã quét mã thanh toán 5000đ hay chưa
  static Future<String> getPaymentStatus(int orderCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$orderCode'),
        headers: {
          'x-client-id': _clientId,
          'x-api-key': _apiKey,
        },
      );
      final decoded = jsonDecode(response.body);
      if (decoded['code'] == '00') {
        return decoded['data']['status']; // Thường trả về "PENDING", "PAID", "CANCELLED"
      }
      return 'ERROR';
    } catch (e) {
      debugPrint('PayOS Get Status Exception: $e');
      return 'ERROR';
    }
  }
}
