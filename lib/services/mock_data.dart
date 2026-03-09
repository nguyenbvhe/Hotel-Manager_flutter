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
      amenities: ['Wi-Fi tốc độ cao', 'TV 55 inch Smart TV', 'Bồn tắm đá cẩm thạch', 'Máy pha cà phê Nespresso', 'Hệ thống lọc không khí', 'Sàn gỗ cao cấp'],
      size: 48,
      maxGuests: 2,
      bedType: 'King Size / Twin',
    ),
    Room(
      id: '2',
      roomNumber: '103',
      roomType: RoomType.deluxe,
      price: 5200000,
      status: RoomStatus.available,
      description: 'Thoát khỏi sự ồn ào của phố thị tại phòng Deluxe Lake View. Tận hưởng khung cảnh hồ nước thơ mộng ngay từ chiếc giường êm ái, một không gian hoàn hảo để thư giãn và tái tạo năng lượng.',
      images: ['https://images.unsplash.com/photo-1618773928121-c32242e63f39'],
      amenities: ['View hồ nước toàn cảnh', 'Wi-Fi miễn phí', 'Điều hòa trung tâm', 'Bồn tắm nằm & Vòi sen', 'Mini Bar phong phú', 'Menu gối tự chọn'],
      size: 48,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '3',
      roomNumber: '201',
      roomType: RoomType.suite,
      price: 7800000,
      status: RoomStatus.available,
      description: 'Nâng tầm trải nghiệm với phòng Suite City View, bao gồm quyền vào Executive Lounge với các đặc quyền như ăn sáng buffet, trà chiều và cocktail tối. Phù hợp cho khách hàng đi công tác và du lịch cao cấp.',
      images: ['https://images.unsplash.com/photo-1590490360182-c33d57733427'],
      amenities: ['Quyền vào Executive Lounge', 'Ăn sáng buffet JW Café', 'Trà chiều và Cocktail tối', 'Dịch vụ giặt là ưu tiên', 'Phòng tắm Master rộng rãi'],
      size: 65,
      maxGuests: 2,
      bedType: 'King Size',
    ),
    Room(
      id: '4',
      roomNumber: '301',
      roomType: RoomType.vip,
      price: 18000000,
      status: RoomStatus.available,
      description: 'Chairman Suite là định nghĩa của sự xa hoa với phòng khách riêng biệt, khu vực ăn uống và tầm nhìn bao quát toàn bộ khuôn viên khách sạn. Không gian lý tưởng cho các cuộc họp quan trọng hoặc nghỉ dưỡng gia đình.',
      images: ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
      amenities: ['Phòng khách và Bàn ăn riêng', 'Khu vực bếp tiện nghi', 'Bồn tắm Jacuzzi', 'Loa Bose cao cấp', 'Trái cây chào mừng hàng ngày'],
      size: 150,
      maxGuests: 4,
      bedType: 'Super King Size',
    ),
    Room(
      id: '5',
      roomNumber: '502',
      roomType: RoomType.romantic,
      price: 3800000, // Roughly $150
      status: RoomStatus.available,
      description: 'Romantic Package: Trải nghiệm không gian tình yêu nồng cháy với nến, hoa hồng và rượu vang. Phòng được trang trí tinh xảo với giường tròn và bồn tắm đôi, mang lại kỉ niệm khó quên cho đôi lứa.',
      images: ['https://reviewvilla.vn/wp-content/uploads/2022/06/Khach-san-tinh-yeu-Ha-Noi-7.jpg'],
      amenities: ['Giường tròn cao cấp', 'Bồn tắm đôi Jacuzzi', 'Đèn Romantic lãng mạn', 'Nến & Hoa hồng trang trí', 'Ghế tình yêu cao cấp', 'Rượu vang thượng hạng'],
      size: 55,
      maxGuests: 2,
      bedType: 'Round King Bed',
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
    HotelService(id: 's1', name: 'Ăn sáng Buffet - JW Café', price: 850000, description: 'Trải nghiệm ẩm thực quốc tế 5 sao với các trạm nấu trực tiếp: Phở bò, Dimsum, Sushi và hải sản tươi sống.'),
    HotelService(id: 's2', name: 'Trà chiều Crystal Lounge', price: 650000, description: 'Thưởng thức các loại trà thượng hạng cùng bánh ngọt thủ công trong không gian kiến trúc độc bản hướng hồ.'),
    HotelService(id: 's3', name: 'Spa by JW (90 phút)', price: 2500000, description: 'Liệu trình massage đặc trưng giúp tái tạo năng lượng (Revitalizing) hoặc thư giãn sâu (Immersed) tại tầng 8.'),
    HotelService(id: 's4', name: 'Đưa đón Limousine BMW/Mercedes', price: 1200000, description: 'Dịch vụ đưa đón sân bay riêng tư bằng dòng xe cao cấp với tài xế chuyên nghiệp và Wi-Fi trên xe.'),
    HotelService(id: 's5', name: 'Bữa tối Fine Dining - French Grill', price: 3500000, description: 'Thưởng thức ẩm thực Pháp tinh tế với những lát bít tết thượng hạng và rượu vang tuyển chọn.'),
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
