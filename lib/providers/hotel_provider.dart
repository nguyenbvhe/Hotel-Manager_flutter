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
  List<Booking> _bookings = [];
  bool _isLoadingRooms = true;
  bool _isLoadingBookings = true;

  final List<Customer> _customers = MockData.customers;
  final List<HotelService> _services = MockData.services;

  HotelProvider() {
    _initRoomsStream();
    _initBookingsStream();
  }

  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingBookings => _isLoadingBookings;
  List<Room> get rooms => [..._rooms];
  List<Booking> get bookings => [..._bookings];
  List<Customer> get customers => [..._customers];
  List<HotelService> get services => [..._services];

  void _initRoomsStream() {
    _firestore.collection('rooms').snapshots().listen(
      (snapshot) {
        final List<Room> newRooms;
        if (snapshot.docs.isEmpty) {
          newRooms = MockData.rooms;
        } else {
          newRooms = snapshot.docs.map((doc) => Room.fromMap(doc.data(), doc.id)).toList();
        }
        _rooms = newRooms;
        _isLoadingRooms = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
      onError: (error) {
        debugPrint('Firestore Rooms Stream Error: $error');
        _rooms = MockData.rooms;
        _isLoadingRooms = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
    );
  }

  void _initBookingsStream() {
    _firestore.collection('bookings').snapshots().listen(
      (snapshot) {
        _bookings = snapshot.docs.map((doc) => Booking.fromMap(doc.data(), doc.id)).toList();
        _isLoadingBookings = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
      onError: (error) {
        debugPrint('Firestore Bookings Stream Error: $error');
        _isLoadingBookings = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
    );
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

  Future<void> importMockServicesToFirestore() async {
    final batch = _firestore.batch();
    for (var service in MockData.services) {
      final docRef = _firestore.collection('services').doc(service.id);
      batch.set(docRef, service.toMap());
    }
    await batch.commit();
  }

  // Booking Actions
  Future<void> createBooking(Booking booking, Room room) async {
    try {
      // 1. Create booking document
      await _firestore.collection('bookings').doc(booking.id).set(booking.toMap());
      
      // 2. Write full room data with booked status to Firestore
      // This ensures MockData rooms get fully persisted, not just status field
      final bookedRoomMap = room.toMap();
      bookedRoomMap['status'] = RoomStatus.booked.name;
      await _firestore.collection('rooms').doc(booking.roomId).set(bookedRoomMap);
    } catch (e) {
      debugPrint('Create Booking Error: $e');
      rethrow;
    }
  }

  // Statistics for Dashboard
  int get totalRooms => _rooms.length;
  int get bookedRooms => _rooms.where((r) => r.status == RoomStatus.booked).length;
  int get availableRooms => _rooms.where((r) => r.status == RoomStatus.available).length;
  
  double get totalRevenue {
    return _bookings.fold(0.0, (total, item) => total + item.totalPrice);
  }
}
