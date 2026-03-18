import 'dart:async';
import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../services/mock_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _statusCheckTimer;

  List<Room> _rooms = [];
  List<Booking> _bookings = [];
  bool _isLoadingRooms = true;
  bool _isLoadingBookings = true;
  bool _isLoadingServices = true;

  List<Customer> _customers = [];
  bool _isLoadingCustomers = true;
  List<HotelService> _services = [];

  HotelProvider() {
    _initRoomsStream();
    _initBookingsStream();
    _initServicesStream();
    _initCustomersStream();
    _startStatusAutoChecker();
  }

  void _startStatusAutoChecker() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkExpiredStatuses();
    });
  }

  Future<void> _checkExpiredStatuses() async {
    final now = DateTime.now();
    for (var room in _rooms) {
      if ((room.status == RoomStatus.cleaning || room.status == RoomStatus.maintenance) &&
          room.statusUntil != null &&
          now.isAfter(room.statusUntil!)) {
        debugPrint('Room ${room.roomNumber} status expired. Reverting to available.');
        try {
          await _firestore.collection('rooms').doc(room.id).update({
            'status': RoomStatus.available.name,
            'statusUntil': null,
            'statusStartedAt': null,
          });
        } catch (e) {
          debugPrint('Error auto-reverting room status: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  bool get isLoadingServices => _isLoadingServices;

  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingBookings => _isLoadingBookings;
  bool get isLoadingCustomers => _isLoadingCustomers;
  List<Room> get rooms => [..._rooms];
  List<Booking> get bookings => [..._bookings];
  List<Customer> get customers => [..._customers];
  List<HotelService> get services => [..._services];

  void _initRoomsStream() {
    _firestore.collection('rooms').snapshots().listen(
      (snapshot) {
        List<Room> newRooms;
        if (snapshot.docs.isEmpty) {
          newRooms = MockData.rooms;
        } else {
          try {
            newRooms = snapshot.docs.map((doc) {
              try {
                return Room.fromMap(doc.data(), doc.id);
              } catch (e) {
                debugPrint('Individual Room mapping error (ID: ${doc.id}): $e');
                rethrow;
              }
            }).toList();
          } catch (e) {
            debugPrint('Error mapping rooms collection: $e');
            newRooms = MockData.rooms;
          }
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
        try {
          _bookings = snapshot.docs.map((doc) {
            try {
              return Booking.fromMap(doc.data(), doc.id);
            } catch (e) {
              debugPrint('Individual Booking mapping error (ID: ${doc.id}): $e');
              rethrow;
            }
          }).toList();
        } catch (e) {
          debugPrint('Error mapping bookings collection: $e');
          _bookings = [];
        }
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

  void _initServicesStream() {
    _firestore.collection('services').snapshots().listen(
      (snapshot) {
        List<HotelService> newServices;
        if (snapshot.docs.isEmpty) {
          newServices = MockData.services;
        } else {
          try {
            newServices = snapshot.docs.map((doc) {
              try {
                debugPrint('DEBUG: Processing service doc: ${doc.id} - name: ${doc.data()?['name']}');
                return HotelService.fromMap(doc.data(), doc.id);
              } catch (e) {
                debugPrint('Individual Service mapping error (ID: ${doc.id}): $e');
                rethrow;
              }
            }).toList();
          } catch (e) {
            debugPrint('Error mapping services collection: $e');
            newServices = MockData.services;
          }
        }
        _services = newServices;
        _isLoadingServices = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
      onError: (error) {
        debugPrint('Firestore Services Stream Error: $error');
        _services = MockData.services;
        _isLoadingServices = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
    );
  }

  void _initCustomersStream() {
    _firestore.collection('users').snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          _customers = MockData.customers;
        } else {
          _customers = snapshot.docs.map((doc) {
            return Customer.fromMap(doc.data(), doc.id);
          }).toList();
        }
        _isLoadingCustomers = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
      onError: (error) {
        debugPrint('Firestore Customers Stream Error: $error');
        _customers = MockData.customers;
        _isLoadingCustomers = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      },
    );
  }

  void toggleCustomerBlockStatus(String customerId) async {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final customer = _customers[index];
      final newStatus = !customer.isBlocked;
      
      try {
        await _firestore.collection('users').doc(customerId).update({
          'isBlocked': newStatus,
        });
      } catch (e) {
        debugPrint('Error toggling customer block status: $e');
      }
    }
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

  // Service Admin Actions
  Future<void> addService(HotelService service) async {
    await _firestore.collection('services').doc(service.id).set(service.toMap());
  }

  Future<void> updateService(HotelService updatedService) async {
    await _firestore.collection('services').doc(updatedService.id).update(updatedService.toMap());
  }

  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).delete();
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

  Future<void> syncStayHubData() async {
    // Import new StayHub data (Upsert). We won't clear existing user-made rooms.
    await importMockRoomsToFirestore();
    await importMockServicesToFirestore();
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

  Future<void> addBooking(Booking booking) async {
    try {
      if (booking.id.isEmpty) {
        final docRef = _firestore.collection('bookings').doc();
        await docRef.set(booking.toMap());
      } else {
        await _firestore.collection('bookings').doc(booking.id).set(booking.toMap());
      }
    } catch (e) {
      debugPrint('Add Booking Error: $e');
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus, {String? roomId}) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus.name,
      });

      // If cancelled, free up the room
      if (newStatus == BookingStatus.cancelled && roomId != null) {
        await _firestore.collection('rooms').doc(roomId).update({
          'status': RoomStatus.available.name,
        });
      }
    } catch (e) {
      debugPrint('Update Booking Status Error: $e');
      rethrow;
    }
  }

  // Statistics for Dashboard
  int get totalRooms => _rooms.length;
  int get bookedRooms => _rooms.where((r) => r.status == RoomStatus.booked).length;
  int get availableRooms => _rooms.where((r) => r.status == RoomStatus.available).length;
  
  double get totalRevenue {
    return _bookings
        .where((b) => b.status == BookingStatus.confirmed)
        .fold(0.0, (total, item) => total + item.totalPrice);
  }

  double get monthlyRevenue {
    final now = DateTime.now();
    return _bookings
        .where((b) => 
            b.status == BookingStatus.confirmed && 
            b.checkInDate.year == now.year && 
            b.checkInDate.month == now.month)
        .fold(0.0, (total, item) => total + item.totalPrice);
  }

  double get yearlyRevenue {
    final now = DateTime.now();
    return _bookings
        .where((b) => 
            b.status == BookingStatus.confirmed && 
            b.checkInDate.year == now.year)
        .fold(0.0, (total, item) => total + item.totalPrice);
  }

  double get dailyRevenue {
    final now = DateTime.now();
    return _bookings
        .where((b) => 
            b.status == BookingStatus.confirmed && 
            b.checkInDate.year == now.year && 
            b.checkInDate.month == now.month &&
            b.checkInDate.day == now.day)
        .fold(0.0, (total, item) => total + item.totalPrice);
  }

  // Chart Data Gatherers
  Map<int, double> getDailyRevenueData() {
    final now = DateTime.now();
    final Map<int, double> data = {};
    // Get last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final revenue = _bookings
          .where((b) => 
              b.status == BookingStatus.confirmed && 
              b.checkInDate.year == date.year && 
              b.checkInDate.month == date.month &&
              b.checkInDate.day == date.day)
          .fold(0.0, (total, item) => total + item.totalPrice);
      // Key is the day of month for display
      data[date.day] = revenue;
    }
    return data;
  }

  Map<int, double> getMonthlyRevenueData() {
    final now = DateTime.now();
    final Map<int, double> data = {};
    // Last 6 months
    for (int i = 0; i < 6; i++) {
        // Correctly handle month subtraction
      int targetMonth = now.month - i;
      int targetYear = now.year;
      while (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }
      
      final revenue = _bookings
          .where((b) => 
              b.status == BookingStatus.confirmed && 
              b.checkInDate.year == targetYear && 
              b.checkInDate.month == targetMonth)
          .fold(0.0, (total, item) => total + item.totalPrice);
      // Key is month (1-12)
      data[targetMonth] = revenue;
    }
    return data;
  }

  Map<int, double> getYearlyRevenueData() {
    final now = DateTime.now();
    final Map<int, double> data = {};
    // Last 3 years
    for (int i = 0; i < 3; i++) {
      final year = now.year - i;
      final revenue = _bookings
          .where((b) => 
              b.status == BookingStatus.confirmed && 
              b.checkInDate.year == year)
          .fold(0.0, (total, item) => total + item.totalPrice);
      data[i] = revenue;
    }
    return data;
  }
}
