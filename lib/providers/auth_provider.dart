import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;
  String? _userPhotoUrl;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;

  Future<void> signInWithGoogle() async {
    // Mocking Google Sign-In process
    await Future.delayed(const Duration(seconds: 2));
    _isLoggedIn = true;
    _userName = 'Minh Nguyễn';
    _userEmail = 'minh.nguyen@example.com';
    _userPhotoUrl = 'https://ui-avatars.com/api/?name=Minh+Nguyen&background=random';
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _userPhotoUrl = null;
    notifyListeners();
  }
}
