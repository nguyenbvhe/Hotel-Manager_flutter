import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _role;
  bool _isAuthLoading = true;

  bool get isLoggedIn => _user != null;
  User? get user => _user;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isStaff => _role == 'staff';
  bool get isManagement => isAdmin || isStaff;
  bool get isAuthLoading => _isAuthLoading;
  String? get userName => _user?.displayName;
  String? get userEmail => _user?.email;
  String? get userPhotoUrl => _user?.photoURL ?? 'https://img.freepik.com/premium-vector/school-boy-vector-illustration_38694-902.jpg?semt=ais_rp_progressive&w=740&q=80';
  bool get isEmailVerified => _user?.emailVerified ?? false;
  
  bool get isProfileComplete {
    return userName != null && userName!.isNotEmpty &&
           _phoneNumber != null && _phoneNumber!.isNotEmpty &&
           _address != null && _address!.isNotEmpty &&
           _identityCard != null && _identityCard!.isNotEmpty;
  }
  
  String? _address;
  String? _identityCard;
  String? _phoneNumber;

  String? get address => _address;
  String? get identityCard => _identityCard;
  String? get phoneNumber => _phoneNumber;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _isAuthLoading = true;
        _loadUserRole(user.uid);
      } else {
        _role = null;
        _isAuthLoading = false;
      }
      notifyListeners();
    });

    _auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        _user = _auth.currentUser;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserRole(String uid) async {
    _isAuthLoading = true;
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _role = data['role'] as String? ?? 'customer';
        _address = data['address'] as String?;
        _identityCard = data['identityCard'] as String?;
        _phoneNumber = data['phoneNumber'] as String?;
      } else {
        _role = 'customer';
        await _firestore.collection('users').doc(uid).set({
          'role': 'customer',
          'email': _user?.email,
          'displayName': _user?.displayName,
          'address': '',
          'identityCard': '',
          'phoneNumber': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
      _role = 'customer';
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        await _loadUserRole(cred.user!.uid);
      }
    } catch (e) {
      debugPrint('Email Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      if (credential.user != null) {
        await _loadUserRole(credential.user!.uid);
      }
    } catch (e) {
      debugPrint('Email Registration Error: $e');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _user?.sendEmailVerification();
    } catch (e) {
      debugPrint('Send Verification Error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      await _user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Reload User Error: $e');
    }
  }

  Future<void> updateUserProfile({String? displayName, String? phoneNumber, String? address, String? identityCard}) async {
    if (_user == null) return;
    try {
      if (displayName != null) {
        await _user!.updateDisplayName(displayName);
      }
      
      final Map<String, dynamic> updates = {};
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
        _phoneNumber = phoneNumber;
      }
      if (address != null) {
        updates['address'] = address;
        _address = address;
      }
      if (identityCard != null) {
        updates['identityCard'] = identityCard;
        _identityCard = identityCard;
      }
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(_user!.uid).update(updates);
      
      await _user!.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      rethrow;
    }
  }

  Future<void> uploadAvatar(XFile imageFile) async {
    if (_user == null) return;
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final avatarRef = storageRef.child('avatars/${_user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await avatarRef.putFile(File(imageFile.path));
      final downloadUrl = await avatarRef.getDownloadURL();
      
      await _user!.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(_user!.uid).update({'avatar': downloadUrl});
      
      await _user!.reload();
      _user = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Avatar Upload Error: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await _user?.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Change Password Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
