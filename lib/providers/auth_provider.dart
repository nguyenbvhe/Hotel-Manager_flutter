import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _role;

  bool get isLoggedIn => _user != null;
  User? get user => _user;
  String? get role => _role;
  String? get userName => _user?.displayName;
  String? get userEmail => _user?.email;
  String? get userPhotoUrl => _user?.photoURL;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  
  // Detailed profile info
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
        _loadUserRole(user.uid);
      } else {
        _role = null;
        notifyListeners();
      }
    });
    // Listen for token refresh events (fires when email is verified in another tab)
    _auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        _user = _auth.currentUser;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _role = doc.get('role') as String?;
        _address = doc.data().toString().contains('address') ? doc.get('address') as String? : null;
        _identityCard = doc.data().toString().contains('identityCard') ? doc.get('identityCard') as String? : null;
        _phoneNumber = doc.data().toString().contains('phoneNumber') ? doc.get('phoneNumber') as String? : null;
      } else {
        // Default role for new users
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user role: $e');
      _role = 'customer'; // Fallback
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
      // Send verification email
      await credential.user?.sendEmailVerification();
      // Role is set automatically in _loadUserRole listener
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

  Future<void> reloadUser() async {
    try {
      await _user?.reload();
      _user = _auth.currentUser;
      notifyListeners(); // Safe to call directly from a timer callback
    } catch (e) {
      debugPrint('Reload User Error: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({String? displayName, String? phoneNumber, String? address, String? identityCard}) async {
    if (_user == null) return;
    try {
      // Update Firebase Auth profile
      if (displayName != null) {
        await _user!.updateDisplayName(displayName);
      }
      
      // Update Firestore user document
      final Map<String, dynamic> updates = {};
      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
        _phoneNumber = phoneNumber;
      }
      if (address != null) {
        updates['address'] = address;
        _address = address;
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
