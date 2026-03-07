import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../services/mock_data.dart';

class HotelProvider with ChangeNotifier {
  final List<Room> _rooms = MockData.rooms;
  final List<Booking> _bookings = MockData.bookings;
  final List<Customer> _customers = MockData.customers;
  final List<HotelService> _services = MockData.services;

  List<Room> get rooms => [..._rooms];
  List<Booking> get bookings => [..._bookings];
  List<Customer> get customers => [..._customers];
  List<HotelService> get services => [..._services];

  // Admin Actions
  void addRoom(Room room) {
    _rooms.add(room);
    notifyListeners();
  }

  void updateRoom(Room updatedRoom) {
    final index = _rooms.indexWhere((r) => r.id == updatedRoom.id);
    if (index >= 0) {
      _rooms[index] = updatedRoom;
      notifyListeners();
    }
  }

  void deleteRoom(String id) {
    _rooms.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Booking Actions
  void createBooking(Booking booking) {
    _bookings.add(booking);
    // Update room status
    final roomIndex = _rooms.indexWhere((r) => r.id == booking.roomId);
    if (roomIndex >= 0) {
      _rooms[roomIndex] = Room(
        id: _rooms[roomIndex].id,
        roomNumber: _rooms[roomIndex].roomNumber,
        roomType: _rooms[roomIndex].roomType,
        price: _rooms[roomIndex].price,
        status: RoomStatus.booked,
        description: _rooms[roomIndex].description,
        images: _rooms[roomIndex].images,
      );
    }
    notifyListeners();
  }

  // Statistics for Dashboard
  int get totalRooms => _rooms.length;
  int get bookedRooms => _rooms.where((r) => r.status == RoomStatus.booked).length;
  int get availableRooms => _rooms.where((r) => r.status == RoomStatus.available).length;
  
  double get totalRevenue {
    return _bookings.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
