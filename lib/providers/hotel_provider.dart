import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../services/mock_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Room> _rooms = [];
  bool _isLoadingRooms = true;

  final List<Booking> _bookings = MockData.bookings;
  final List<Customer> _customers = MockData.customers;
  final List<HotelService> _services = MockData.services;

  HotelProvider() {
    _initRoomsStream();
  }

  bool get isLoadingRooms => _isLoadingRooms;
  List<Room> get rooms => [..._rooms];
  List<Booking> get bookings => [..._bookings];
  List<Customer> get customers => [..._customers];
  List<HotelService> get services => [..._services];

  void _initRoomsStream() {
    _firestore.collection('rooms').snapshots().listen((snapshot) {
      _rooms = snapshot.docs.map((doc) => Room.fromMap(doc.data(), doc.id)).toList();
      _isLoadingRooms = false;
      notifyListeners();
    });
  }

  // Admin Actions
  Future<void> addRoom(Room room) async {
    await _firestore.collection('rooms').doc(room.id).set(room.toMap());
  }

  Future<void> updateRoom(Room updatedRoom) async {
    await _firestore.collection('rooms').doc(updatedRoom.id).update(updatedRoom.toMap());
  }

  Future<void> deleteRoom(String id) async {
    await _firestore.collection('rooms').doc(id).delete();
  }

  Future<void> importMockRoomsToFirestore() async {
    final batch = _firestore.batch();
    for (var room in MockData.rooms) {
      final docRef = _firestore.collection('rooms').doc(room.id);
      batch.set(docRef, room.toMap());
    }
    await batch.commit();
  }

  // Booking Actions
  void createBooking(Booking booking) {
    _bookings.add(booking);
    _firestore.collection('rooms').doc(booking.roomId).update({'status': RoomStatus.booked.name});
    notifyListeners();
  }

  // Statistics for Dashboard
  int get totalRooms => _rooms.length;
  int get bookedRooms => _rooms.where((r) => r.status == RoomStatus.booked).length;
  int get availableRooms => _rooms.where((r) => r.status == RoomStatus.available).length;
  
  double get totalRevenue {
    return _bookings.fold(0, (total, item) => total + item.totalPrice);
  }
}
