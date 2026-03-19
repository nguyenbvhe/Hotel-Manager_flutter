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

    // 1. Handle Room Availability specific queries
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

    // 2. Handle Service specific queries
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

    // 3. Fallback to general info
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

    return 'Xin lỗi, tôi chưa hiểu ý bạn lắm. Bạn có thể hỏi về các hạng phòng (VIP, Suite, Romantic...) hoặc dịch vụ (Spa, Buffet...) cụ thể để StayHub hỗ trợ tốt nhất ạ!';
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
