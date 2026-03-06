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
      description: 'Phòng tiêu chuẩn với đầy đủ tiện nghi cơ bản.',
      images: ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304'],
    ),
    Room(
      id: '2',
      roomNumber: '202',
      roomType: RoomType.deluxe,
      price: 800000,
      status: RoomStatus.booked,
      description: 'Phòng Deluxe rộng rãi, view nhìn ra thành phố.',
      images: ['https://images.unsplash.com/photo-1618773928121-c32242e63f39'],
    ),
    Room(
      id: '3',
      roomNumber: '303',
      roomType: RoomType.vip,
      price: 1500000,
      status: RoomStatus.available,
      description: 'Phòng VIP sang trọng với dịch vụ đưa đón sân bay.',
      images: ['https://images.unsplash.com/photo-1590490360182-c33d57733427'],
    ),
    Room(
      id: '4',
      roomNumber: '102',
      roomType: RoomType.standard,
      price: 500000,
      status: RoomStatus.cleaning,
      description: 'Phòng tiêu chuẩn tầng 1.',
      images: ['https://images.unsplash.com/photo-1566665797739-1674de7a421a'],
    ),
  ];

  static List<Customer> customers = [
    Customer(
      id: 'u1',
      name: 'Nguyễn Văn A',
      phone: '0901234567',
      email: 'vana@gmail.com',
      identityCard: '123456789',
    ),
    Customer(
      id: 'u2',
      name: 'Trần Thị B',
      phone: '0907654321',
      email: 'thib@gmail.com',
      identityCard: '987654321',
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
  ];ssss
}
