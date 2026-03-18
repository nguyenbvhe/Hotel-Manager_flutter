import '../models/room.dart';
import '../models/booking.dart';
import '../models/customer.dart';
import '../models/service.dart';

class MockData {

  static List<Room> rooms = [
    // STANDARD ROOMS
    Room(
      id: '1',
      roomNumber: '101',
      roomType: RoomType.standard,
      price: 4500000,
      status: RoomStatus.available,
      description: 'Khám phá sự cân bằng hoàn hảo giữa phong cách hiện đại và sự tiện nghi tối ưu tại phòng Standard City View. Với thiết kế mở đón trọn ánh sáng tự nhiên từ cửa sổ kính lớn, căn phòng mang đến tầm nhìn bao quát thành phố sôi động, là chốn dừng chân lý tưởng cho những chuyến công tác hay du lịch khám phá.',
      images: ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304'],
      amenities: ['Wi-Fi 6 tốc độ cao', 'Smart TV 4K 43 inch', 'Điều hòa trung tâm Daikin', 'Mini Bar phong phú', 'Két sắt điện tử an toàn', 'Phòng tắm đứng với vòi sen Rainshower'],
      size: 40,
      maxGuests: 2,
      bedType: 'Queen Size DreamBed',
    ),
    Room(
      id: '2',
      roomNumber: '102',
      roomType: RoomType.standard,
      price: 4400000,
      status: RoomStatus.available,
      description: 'Sự kết hợp tinh tế giữa nội thất gỗ sồi ấm áp và bảng màu trung tính nhã nhặn tạo nên một không gian nghỉ dưỡng thanh bình ngay giữa lòng đô thị. Phòng Standard Cozy Quiet mang đến sự riêng tư tuyệt đối, giúp bạn tận hưởng những giây phút thư giãn sâu sau một ngày dài năng động.',
      images: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2'],
      amenities: ['Cách âm tiêu chuẩn 5 sao', 'Hệ thống đèn thông minh', 'Máy sấy tóc ion', 'Mini Bar tuyển chọn', 'Bàn làm việc ergonomic', 'Phòng tắm hiện đại'],
      size: 38,
      maxGuests: 2,
      bedType: 'Queen Size Premium Silk',
    ),

    // DELUXE ROOMS
    Room(
      id: '3',
      roomNumber: '103',
      roomType: RoomType.deluxe,
      price: 5200000,
      status: RoomStatus.available,
      description: 'Tận hưởng vẻ đẹp thơ mộng của thành phố phản chiếu trên mặt hồ yên ả ngay từ ban công phòng Deluxe Lake View. Với không gian rộng rãi và lối bày trí sang trọng, căn phòng là sự lựa chọn tuyệt vời cho những ai tìm kiếm một không gian sống đẳng cấp và gần gũi với thiên nhiên.',
      images: ['https://images.unsplash.com/photo-1618773928121-c32242e63f39'],
      amenities: ['View hồ nước 180 độ', 'Wi-Fi phủ sóng toàn diện', 'Smart TV 55 inch OLED', 'Mini Bar cao cấp', 'Bồn tắm nằm Gốm sứ', 'Menu gối tự chọn'],
      size: 48,
      maxGuests: 2,
      bedType: 'King Size Luxury Cotton',
    ),
    Room(
      id: '4',
      roomNumber: '104',
      roomType: RoomType.deluxe,
      price: 5300000,
      status: RoomStatus.available,
      description: 'Kiến trúc đương đại hòa quyện cùng sự sang trọng cổ điển tại Deluxe Panorama Suite. Ban công riêng rộng lớn không chỉ mang đến gió trời tự nhiên mà còn là nơi lý tưởng để thưởng thức một tách cà phê buổi sáng giữa không gian mây trời Hà Đông.',
      images: ['https://images.unsplash.com/photo-1598928506311-c55ded91a20c'],
      amenities: ['Ban công Panorama', 'Máy pha cà phê Nespresso', 'Loa Bluetooth Marshall', 'Setup hoa tươi hàng ngày', 'Bồn tắm nằm Jacuzzi', 'Áo choàng tắm lụa cao cấp'],
      size: 50,
      maxGuests: 2,
      bedType: 'Grand King Size',
    ),

    // SUITE ROOMS
    Room(
      id: '5',
      roomNumber: '201',
      roomType: RoomType.suite,
      price: 7800000,
      status: RoomStatus.available,
      description: 'Định nghĩa lại sự xa hoa với Suite Executive City – căn hộ thượng lưu giữa tầng mây. Phòng khách riêng biệt được thiết kế with nội thất nhung cao cấp and các tác phẩm nghệ thuật độc bản, tạo nên không gian làm việc and tiếp khách xứng tầm đẳng cấp doanh nhân.',
      images: ['https://images.unsplash.com/photo-1590490360182-c33d57733427'],
      amenities: ['Phòng khách and phòng ngủ riêng', 'Smart TV 65 inch Home Theater', 'Mini Bar thượng hạng', 'Bồn tắm đá cẩm thạch nguyên khối', 'Bàn làm việc gỗ walnut lớn', 'Đặc quyền ăn sáng G-Café', 'Quầy bar mini pha chế tại phòng'],
      size: 75,
      maxGuests: 3,
      bedType: 'Heritage King Size',
    ),
    Room(
      id: '6',
      roomNumber: '202',
      roomType: RoomType.suite,
      price: 8500000,
      status: RoomStatus.available,
      description: 'Trải nghiệm đỉnh cao nghỉ dưỡng tại Suite Grand Lake View, nơi mọi chi tiết đều được chăm chút tỉ mỉ để chiều lòng những vị khách khó tính nhất. Cửa sổ kính sát trần mang trọn vẻ đẹp lung linh của thành phố về đêm vào không gian nghỉ ngơi của bạn.',
      images: ['https://images.unsplash.com/photo-1584132967334-10e028bd69f7'],
      amenities: ['Toàn cảnh view hồ và thành phố', 'Phòng khách sang trọng', 'Loa soundbar Dolby Atmos', 'Tủ lạnh rượu vang riêng', 'Bồn tắm Jacuzzi cỡ lớn', 'Dịch vụ giặt là ưu tiên', 'Butler phục vụ 24/7'],
      size: 85,
      maxGuests: 4,
      bedType: 'Super King Size Velvet',
    ),

    // VIP ROOMS
    Room(
      id: '8',
      roomNumber: '301',
      roomType: RoomType.vip,
      price: 18000000,
      status: RoomStatus.available,
      description: 'Chairman Presidential Suite – Đỉnh cao của sự quyền quý. Với diện tích lên tới 150m², căn suite sở hữu phòng khách đại sảnh, khu vực dùng bữa riêng tư và quầy bar sang trọng. Nơi đây không chỉ là phòng nghỉ, mà là một biểu tượng của sự thành đạt và xa hoa bậc nhất StayHub.',
      images: ['https://images.unsplash.com/photo-1582719478250-c89cae4dc85b'],
      amenities: ['Sảnh đón tiếp riêng', 'Phòng ăn hoàng gia 8 người', 'Jacuzzi Massage & Sauna', 'TV 75 inch 8K Cinema', 'Hệ thống âm thanh Hi-End Bose', 'Dịch vụ Quản gia (Butler) riêng biệt', 'Xe Limousine đón tiễn sân bay'],
      size: 150,
      maxGuests: 4,
      bedType: 'Imperial Super King',
    ),
    Room(
      id: '9',
      roomNumber: '302',
      roomType: RoomType.vip,
      price: 19500000,
      status: RoomStatus.available,
      description: 'Royal Diamond Suite là sự kết tinh của nghệ thuật và kiến trúc xa xỉ. Mỗi món đồ nội thất đều được tuyển chọn và nhập khẩu trực tiếp từ Ý. Tầm nhìn vô cực hướng thẳng ra trái tim thành phố biến mỗi giây phút tại đây trở thành một trải nghiệm độc bản không thể quên.',
      images: ['https://images.unsplash.com/photo-1591088398332-8a7791972843'],
      amenities: ['Thiết kế Royal Gold', 'Phòng làm việc/Họp riêng', 'Phòng tắm mạ vàng', 'Đặc quyền Club Lounge', 'Menu ẩm thực Chef-at-suite', 'Bể bơi mini trong nhà (tùy căn)', 'Hệ thống điều khiển thông minh iPad'],
      size: 165,
      maxGuests: 4,
      bedType: 'Diamond Super King',
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
  ];

  static List<HotelService> services = [
    HotelService(
      id: 's1',
      name: 'Ăn sáng Buffet - StayHub Café',
      price: 8.50000,
      description: 'Bắt đầu ngày mới đầy năng lượng với tiệc Buffet thượng hạng tại StayHub Café. Từ hương vị truyền thống tinh túy của Phở bò Wagyu đến sự đa dạng của ẩm thực quốc tế với Sushi, Dimsum và quầy bánh ngọt chuẩn Pháp. Không gian bếp mở giúp khách hàng trực tiếp chiêm ngưỡng tài năng của các đầu bếp hàng đầu.',
      image: 'https://images.unsplash.com/photo-1555244162-803834f70033',
      duration: '06:30 - 10:30',
      category: 'Dining',
    ),
    HotelService(
      id: 's2',
      name: 'Trà chiều Crystal Lounge',
      price: 6.50000,
      description: 'Khoảng nghỉ thanh tao giữa ngày tại Crystal Lounge với set trà chiều truyền thống Anh quốc. Tận hưởng các loại trà đặc sản cao cấp cùng khay bánh thủ công tinh xảo, trong một không gian kiến trúc độc bản lấy cảm hứng từ những viên kim cương lấp lánh bên hồ.',
      image: 'https://images.unsplash.com/photo-1544148103-0773bf10d330',
      duration: '14:00 - 17:00',
      category: 'Leisure',
    ),
    HotelService(
      id: 's3',
      name: 'StayHub Spa Special (90 phút)',
      price: 2.500000,
      description: 'Đánh thức mọi giác quan tại StayHub Spa – ốc đảo yên bình trên tầng cao nhất. Sử dụng tinh dầu cao cấp và kỹ thuật massage kết hợp Đông – Tây, liệu trình giúp giải tỏa căng thẳng toàn diện và tái tạo năng lượng từ sâu bên trong cơ thể.',
      image: 'https://vinpearlresortvietnam.com/wp-content/uploads/Akoya-Spa-tai-Vinpearl-Phu-Quoc-resort.jpg',
      duration: '90 Phút',
      category: 'Wellness',
    ),
    HotelService(
      id: 's4',
      name: 'Limousine Executive Class',
      price: 1.500000,
      description: 'Trải nghiệm hành trình di chuyển an toàn và sang trọng bậc nhất với dòng xe Limousine đời mới. Đội ngũ tài xế chuyên nghiệp, chu đáo cùng các tiện nghi trên xe như Wi-Fi, nước khoáng lạnh và khăn thơm, đảm bảo mỗi chuyến đi của bạn đều nhẹ nhàng và êm ái.',
      image: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf',
      duration: 'Theo yêu cầu',
      category: 'Transport',
    ),
    HotelService(
      id: 's5',
      name: 'Bữa tối Fine Dining - French Grill',
      price: 4.500000,
      description: 'Đỉnh cao ẩm thực Pháp ngay tại StayHub. French Grill mang đến thực đơn nghệ thuật với những nguyên liệu xa xỉ nhất như gan ngỗng, nấm Truffle và rượu vang ủ lâu năm. Một không gian lãng mạn dưới ánh nến, dành riêng cho những dịp kỷ niệm quan trọng hay những buổi tối thăng hoa vị giác.',
      image: 'https://lasinfoniavietnam.com/wp-content/uploads/2025/04/Fine-dining-1.jpg',
      duration: '18:00 - 22:30',
      category: 'Dining',
    ),
  ];

  static List<Booking> bookings = [
    Booking(
      id: 'b1',
      userId: 'u1',
      roomId: '3',
      checkInDate: DateTime.now().subtract(const Duration(days: 1)),
      checkOutDate: DateTime.now().add(const Duration(days: 1)),
      totalPrice: 5200000,
      status: BookingStatus.checkedIn,
    ),
  ];
}
