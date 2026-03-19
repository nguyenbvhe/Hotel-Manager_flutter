import 'dart:async';
import '../models/service.dart';
import '../models/room.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Simulates an AI response based on the user's message and real hotel data.
  Future<String> getChatResponse(String message, {List<HotelService>? availableServices, List<Room>? availableRooms}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate thinking

    final msg = message.toLowerCase();

    // 1. Handle "Đẳng cấp / Sang trọng / VIP" queries
    if (msg.contains('đẳng cấp') || msg.contains('sang trọng') || msg.contains('vip') || msg.contains('xịn')) {
      String response = 'StayHub tự hào mang đến những trải nghiệm đẳng cấp nhất dành cho bạn: \n\n';
      
      if (availableRooms != null) {
        final vipRooms = availableRooms.where((r) => r.roomType == RoomType.vip || r.roomType == RoomType.suite).toList();
        if (vipRooms.isNotEmpty) {
          response += '• Về lưu trú: Các hạng phòng ${vipRooms.map((r) => r.roomNumber).take(2).join(', ')} (VIP/Suite) với dịch vụ quản gia riêng.\n';
        }
      }
      
      if (availableServices != null) {
        final premiumServices = availableServices.where((s) => s.price >= 2000000).toList();
        if (premiumServices.isNotEmpty) {
          response += '• Về dịch vụ: ${premiumServices.map((s) => s.name).take(2).join(', ')} đang là những lựa chọn thượng lưu nhất.\n';
        }
      }
      
      response += '\nBạn có muốn tôi tư vấn chi tiết hơn về mục nào không ạ?';
      return response;
    }

    // 2. Handle Membership / Loyalty queries
    if (msg.contains('thành viên') || msg.contains('club') || msg.contains('quyền lợi') || msg.contains('hạng')) {
      return 'StayHub Club có 3 hạng thành viên: Silver, Gold và Diamond. Ở hạng Diamond, bạn sẽ được giảm 25% dịch vụ, có quản gia riêng và đưa đón Limousine miễn phí. Bạn có thể xem chi tiết tại mục "StayHub Club" trong trang Cá nhân nhé!';
    }

    // 3. Handle Contact / Support queries
    if (msg.contains('liên hệ') || msg.contains('số điện thoại') || msg.contains('hotline') || msg.contains('hỗ trợ')) {
      return 'Bạn có thể liên hệ Hotline Concierge 24/7 của StayHub tại số: +84 (0) 24 1234 5678 hoặc vào mục "Liên hệ hỗ trợ 24/7" trong trang Cá nhân để được trợ giúp ngay lập tức ạ.';
    }

    // 4. Handle Room Availability specific queries
    if (msg.contains('phòng') && (msg.contains('trống') || msg.contains('có'))) {
      RoomType? targetType;
      if (msg.contains('vip')) targetType = RoomType.vip;
      else if (msg.contains('romantic')) targetType = RoomType.romantic;
      else if (msg.contains('suite')) targetType = RoomType.suite;
      else if (msg.contains('deluxe')) targetType = RoomType.deluxe;
      else if (msg.contains('standard')) targetType = RoomType.standard;

      if (availableRooms != null) {
        final filteredRooms = availableRooms.where((r) => 
          (targetType == null || r.roomType == targetType) && 
          r.status == RoomStatus.available
        ).toList();

        if (filteredRooms.isEmpty) {
          return 'Dạ, hiện tại StayHub rất tiếc là loại phòng bạn hỏi đã hết phòng trống ạ. Bạn có muốn xem các hạng phòng khác không?';
        }

        final typeStr = targetType?.label ?? 'các hạng';
        return 'Hiện tại StayHub đang còn ${filteredRooms.length} phòng $typeStr trống ạ (Phòng: ${filteredRooms.take(3).map((r) => r.roomNumber).join(', ')}...). Bạn có thể đặt ngay ở mục "Phòng nổi bật" nhé!';
      }
    }

    // 5. Handle Service specific queries
    if (msg.contains('dịch vụ') || msg.contains('spa') || msg.contains('massage') || msg.contains('ăn')) {
      if (availableServices != null) {
        HotelService? match;
        if (msg.contains('spa') || msg.contains('massage')) {
          match = availableServices.firstWhere((s) => s.name.toLowerCase().contains('spa') || s.name.toLowerCase().contains('massage'), orElse: () => availableServices[0]);
        } else if (msg.contains('ăn') || msg.contains('buffet')) {
          match = availableServices.firstWhere((s) => s.name.toLowerCase().contains('ăn') || s.name.toLowerCase().contains('buffet'), orElse: () => availableServices[0]);
        }

        if (match != null && (msg.contains('spa') || msg.contains('buffet') || msg.contains('massage'))) {
          return 'StayHub đang phục vụ dịch vụ "${match.name}" với giá cực ưu đãi chỉ ${match.price}₫. ${match.description.take(50)}... Bạn có muốn trải nghiệm không?';
        }
      }
    }

    // 6. Fallback to general info
    if (msg.contains('wifi') || msg.contains('mạng')) {
      return 'Chào bạn! Wifi tại StayHub Hotel là "StayHub_Guest" và mật khẩu là "stayhub2024". Chúc bạn có trải diện mượt mà!';
    }

    if (msg.contains('ăn sáng') || msg.contains('bữa sáng')) {
      return 'Bữa sáng Buffet được phục vụ tại nhà hàng StayHub Café (Tầng 1) từ 6:30 đến 10:00 hàng ngày bạn nhé.';
    }

    if (msg.contains('check-in') || msg.contains('nhận phòng')) {
      return 'Giờ nhận phòng tiêu chuẩn tại StayHub là 14:00. Nếu bạn đến sớm hơn, chúng tôi sẽ hỗ trợ nhận phòng sớm tùy vào tình trạng phòng trống ạ.';
    }

    if (msg.contains('check-out') || msg.contains('trả phòng')) {
      return 'Giờ trả phòng tiêu chuẩn là 12:00 trưa. Bạn có thể liên hệ lễ tân nếu muốn trả phòng muộn nhé.';
    }

    if (msg.contains('địa chỉ') || msg.contains('ở đâu')) {
      return 'StayHub Hotel tọa lạc tại số 60 Mậu Lương, Kiến Hưng, Hà Đông, Hà Nội. StayHub rất hân hạnh được đón tiếp bạn!';
    }

    return 'Chào bạn! Tôi có thể giúp gì được cho bạn? Bạn có thể hỏi về các hạng phòng (VIP, Suite...), quyền lợi thành viên Club, hoặc các dịch vụ đẳng cấp (Spa, Fine Dining) của StayHub nhé!';
  }

  /// Suggests services based on room type.
  List<String> getRecommendations(RoomType roomType) {
    switch (roomType) {
      case RoomType.romantic:
        return ['Dịch vụ trang trí phòng lãng mạn', 'Spa thư giãn'];
      case RoomType.vip:
      case RoomType.suite:
        return ['Xe đưa đón sân bay', 'Ăn sáng Buffet'];
      default:
        return ['Ăn sáng Buffet', 'Spa thư giãn'];
    }
  }

  /// Upsell message based on room type.
  String getUpsellMessage(RoomType roomType) {
    switch (roomType) {
      case RoomType.romantic:
        return 'Chuyến đi lãng mạn sẽ hoàn hảo hơn với liệu trình Spa đôi hoặc bữa tối nến hoa tại phòng. Bạn có muốn đặt thêm không?';
      case RoomType.vip:
      case RoomType.suite:
        return 'Hạng phòng thượng lưu của bạn đi kèm với ưu đãi giảm 20% dịch vụ đưa đón sân bay bằng Xe Limousine. Đừng bỏ lỡ nhé!';
      default:
        return 'Khởi đầu ngày mới tràn đầy năng lượng với bữa sáng Buffet tại StayHub Café. Chỉ thêm một bước để hoàn tất kỳ nghỉ!';
    }
  }
}

extension StringExtension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
