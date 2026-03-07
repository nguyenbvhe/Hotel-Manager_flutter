import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _role = doc.get('role') as String?;
      } else {
        // Default role for new users
        _role = 'customer';
        await _firestore.collection('users').doc(uid).set({
          'role': 'customer',
          'email': _user?.email,
          'displayName': _user?.displayName,
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
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Role is set automatically in _loadUserRole listener
    } catch (e) {
      debugPrint('Email Registration Error: $e');
      rethrow;
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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
