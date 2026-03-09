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
      price: 4500000,
      status: RoomStatus.available,
      description: 'Phòng Deluxe City View mang đến không gian nghỉ ngơi sang trọng với cửa sổ kính từ trần đến sàn, tầm nhìn hướng ra thành phố sôi động. Nội thất hiện đại kết hợp tinh tế giữa sự tiện nghi và đẳng cấp của JW Marriott.',
      images: ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304'],
      amenities: ['Wifi tốc độ cao', 'TV 55 inch', 'Bồn tắm đá cẩm thạch', 'Máy pha trà & Cà phê cao cấp', 'Dịch vụ trà chiều tại phòng'],
      size: 48,
      maxGuests: 2,
      bedType: 'King Size / Twin',
    ),
    Room(
      id: '2',
      roomNumber: '103',
      roomType: RoomType.standard,
      price: 5200000,
      status: RoomStatus.available,
      description: 'Thoát khỏi sự ồn ào của phố thị tại phòng Deluxe Lake View. Tận hưởng khung cảnh hồ nước thơ mộng ngay từ chiếc giường êm ái, một không gian hoàn hảo để thư giãn và tái tạo năng lượng.',
      images: ['https://images.unsplash.com/photo-1618773928121-c32242e63f39'],
      amenities: ['View hồ nước', 'Wifi miễn phí', 'Điều hòa trung tâm', 'Bồn tắm nằm', 'Mini Bar'],
      size: 48,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '3',
      roomNumber: '201',
      roomType: RoomType.deluxe,
      price: 7800000,
      status: RoomStatus.available,
      description: 'Nâng tầm trải nghiệm với phòng Executive City View, bao gồm quyền vào Executive Lounge với các đặc quyền như ăn sáng buffet, trà chiều và cocktail tối. Phù hợp cho khách hàng đi công tác và du lịch cao cấp.',
      images: ['https://images.unsplash.com/photo-1590490360182-c33d57733427'],
      amenities: ['Quyền vào Executive Lounge', 'Ăn sáng miễn phí', 'Dịch vụ giặt là ưu tiên', 'Smart TV 65 inch', 'Bàn làm việc tiện nghi'],
      size: 65,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '4',
      roomNumber: '202',
      roomType: RoomType.deluxe,
      price: 8500000,
      status: RoomStatus.booked,
      description: 'Phòng Executive Lake View kết hợp giữa không gian làm việc chuyên nghiệp và view hồ tuyệt mỹ. Trải nghiệm dịch vụ cá nhân hóa đỉnh cao tại một trong những phòng được yêu thích nhất khách sạn.',
      images: ['https://images.unsplash.com/photo-1566665797739-1674de7a421a'],
      amenities: ['View hồ toàn cảnh', 'Quyền vào Executive Lounge', 'Cocktail tối', 'Trà chiều đặc biệt', 'Dịch vụ quản gia'],
      size: 65,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '5',
      roomNumber: '301',
      roomType: RoomType.vip,
      price: 18000000,
      status: RoomStatus.available,
      description: 'Chairman Suite là định nghĩa của sự xa hoa với phòng khách riêng biệt, khu vực ăn uống và tầm nhìn bao quát toàn bộ khuôn viên khách sạn. Không gian lý tưởng cho các cuộc họp quan trọng hoặc nghỉ dưỡng gia đình.',
      images: ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
      amenities: ['Phòng khách riêng', 'Khu vực bếp', 'Bàn ăn 6 người', 'Hệ thống âm thanh cao cấp', 'Phòng tắm Master cực lớn'],
      size: 150,
      maxGuests: 4,
      bedType: 'Super King Size',
    ),
    Room(
      id: '6',
      roomNumber: '400',
      roomType: RoomType.vip,
      price: 55000000,
      status: RoomStatus.available,
      description: 'Presidential Suite mang đẳng cấp thế giới, từng đón tiếp các nguyên thủ quốc gia. Với thiết kế độc bản, an ninh tối mật và dịch vụ quản gia 24/7, đây là không gian nghỉ dưỡng tối thượng tại Hà Nội.',
      images: ['https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd'],
      amenities: ['Quản gia riêng 24/7', 'Lối đi riêng an mật', 'Bàn làm việc gỗ quý', 'Phòng xông hơi riêng', 'Phòng họp nội bộ'],
      size: 320,
      maxGuests: 4,
      bedType: 'Grand Super King',
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
