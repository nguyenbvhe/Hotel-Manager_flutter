import '../models/room.dart';
import '../models/booking.dart';
import '../models/customer.dart';
import '../models/service.dart';


class MockData {
  static List<Room> rooms = [
    Room(
      id: '1',
      roomNumber: '101',
      roomType: RoomType.standard,
      price: 500000,
      status: RoomStatus.available,
      description: 'Phòng tiêu chuẩn ấm cúng với đầy đủ tiện nghi cho kỳ nghỉ ngắn ngày. Không gian được bài trí tinh tế, mang lại cảm giác thoải mái.',
      images: ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304'],
      amenities: ['Wifi miễn phí', 'Điều hòa', 'TV Box', 'Máy pha cà phê'],
      size: 25,
      maxGuests: 2,
      bedType: 'Queen Size',
    ),
    Room(
      id: '2',
      roomNumber: '202',
      roomType: RoomType.deluxe,
      price: 800000,
      status: RoomStatus.booked,
      description: 'Phòng Deluxe rộng rãi với tầm nhìn tuyệt đẹp ra trung tâm thành phố. Trang trí hiện đại, cao cấp phù hợp cho các cặp đôi.',
      images: ['https://images.unsplash.com/photo-1618773928121-c32242e63f39'],
      amenities: ['Wifi miễn phí', 'Điều hòa', 'TV Box', 'Mini Bar', 'Bồn tắm', 'View thành phố'],
      size: 35,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '3',
      roomNumber: '303',
      roomType: RoomType.vip,
      price: 1500000,
      status: RoomStatus.available,
      description: 'Trải nghiệm đẳng cấp thượng lưu tại phòng VIP với các dịch vụ đặc quyền, nội thất gỗ sang trọng và không gian yên tĩnh tuyệt đối.',
      images: ['https://images.unsplash.com/photo-1590490360182-c33d57733427'],
      amenities: ['Dịch vụ 24/7', 'Hồ bơi riêng', 'Wifi 6', 'Mini Bar', 'Bồn tắm massage', 'Smart TV 65 inch'],
      size: 55,
      maxGuests: 3,
      bedType: 'Ultra King Size',
    ),
    Room(
      id: '4',
      roomNumber: '102',
      roomType: RoomType.standard,
      price: 500000,
      status: RoomStatus.cleaning,
      description: 'Phòng tiêu chuẩn tầng trệt, dễ dàng di chuyển, lý tưởng cho những khách hàng yêu thích sự tiện lợi.',
      images: ['https://images.unsplash.com/photo-1566665797739-1674de7a421a'],
      amenities: ['Wifi miễn phí', 'Điều hòa', 'TV Box', 'Vòi hoa sen'],
      size: 22,
      maxGuests: 2,
      bedType: 'Full Size',
    ),
    Room(
      id: '5',
      roomNumber: '205',
      roomType: RoomType.deluxe,
      price: 850000,
      status: RoomStatus.available,
      description: 'Phòng Deluxe tại góc tòa nhà, sở hữu ban công rộng đón nắng tự nhiên và gió trời, mang lại không gian nghỉ dưỡng đích thực.',
      images: ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
      amenities: ['Wifi miễn phí', 'Điều hòa', 'Ban công', 'Bàn làm việc', 'Mini Bar'],
      size: 40,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '6',
      roomNumber: '305',
      roomType: RoomType.vip,
      price: 2000000,
      status: RoomStatus.available,
      description: 'Căn Penthouse cao nhất của khách sạn, mang lại tầm nhìn 360 độ toàn cảnh. Sự kết hợp hoàn hảo giữa công nghệ và nghệ thuật.',
      images: ['https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd'],
      amenities: ['Phòng khách riêng', 'Rạp chiếu phim mini', 'Hầm rượu', 'Hồ bơi vô cực', 'Phòng xông hơi'],
      size: 120,
      maxGuests: 4,
      bedType: 'Super King Size',
    ),
  ];

  static List<Customer> customers = [
    Customer(
      id: 'u1',
      name: 'Nguyễn Văn A',
      phone: '0901234567',
      email: 'vana@gmail.com',
      identityCard: '123456789',
      address: 'Hà Nội',
      avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
    ),
    Customer(
      id: 'u2',
      name: 'Trần Thị B',
      phone: '0907654321',
      email: 'thib@gmail.com',
      identityCard: '987654321',
      address: 'Hồ Chí Minh',
      avatar: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    ),
  ];

  static List<HotelService> services = [
    HotelService(id: 's1', name: 'Ăn sáng', price: 100000, description: 'Buffet sáng phục vụ từ 6h-9h'),
    HotelService(id: 's2', name: 'Giặt là', price: 50000, description: 'Giặt ủi quần áo lấy trong ngày'),
    HotelService(id: 's3', name: 'Spa', price: 500000, description: 'Massage thư giãn 60 phút'),
  ];

  static List<Booking> bookings = [
    Booking(
      id: 'b1',
      userId: 'u1',
      roomId: '2',
      checkInDate: DateTime.now().subtract(const Duration(days: 1)),
      checkOutDate: DateTime.now().add(const Duration(days: 1)),
      totalPrice: 1600000,
      status: BookingStatus.checkedIn,
    ),
  ];
}
