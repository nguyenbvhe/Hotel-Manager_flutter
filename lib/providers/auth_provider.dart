import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _role;
  bool isTestMode = false; // Set to true for internal testing without Firebase/eSMS config
  String? _mockOtp;
  String? get mockOtp => _mockOtp;

  // eSMS Config
  String _eSmsApiKey = '491D7831E8A87616CB358CE9D022220'; 
  String _eSmsSecretKey = '31C0D1BBC3E947683006D6BAA4F88C';
  
  void setESmsConfig(String apiKey, String secretKey) {
    _eSmsApiKey = apiKey;
    _eSmsSecretKey = secretKey;
  }

  bool get isLoggedIn => _user != null;
  User? get user => _user;
  String? get role => _role;
  String? get userName => _user?.displayName;
  String? get userEmail => _user?.email;
  String? get userPhotoUrl => _user?.photoURL ?? 'https://img.freepik.com/premium-vector/school-boy-vector-illustration_38694-902.jpg?semt=ais_rp_progressive&w=740&q=80';
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
      // Notify immediately so UI can show loading state/switch home
      notifyListeners();
      
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        _role = null;
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
        final data = doc.data() as Map<String, dynamic>;
        _role = data['role'] as String? ?? 'customer';
        _address = data['address'] as String?;
        _identityCard = data['identityCard'] as String?;
        _phoneNumber = data['phoneNumber'] as String?;
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

  // --- Phone + Password Auth Methods ---

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String code, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
  }) async {
    if (isTestMode) {
      // Simulate SMS send delay
      await Future.delayed(const Duration(seconds: 1));
      _mockOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      debugPrint('--- [MOCK SMS] Mã OTP cho số $phoneNumber là: $_mockOtp ---');
      codeSent('mock-verification-id-$phoneNumber', null);
      return;
    }

    if (_eSmsApiKey.isNotEmpty && _eSmsSecretKey.isNotEmpty) {
      // --- LOGIC GỬI QUA eSMS.vn ---
      try {
        _mockOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
        final content = "G-Hotel: Ma OTP cua ban la $_mockOtp. Vui long khong chia se ma nay.";
        
        final url = Uri.parse('http://rest.esms.vn/MainService.svc/json/SendMultipleMessage_V4_get'
            '?Phone=$phoneNumber'
            '&Content=$content'
            '&ApiKey=$_eSmsApiKey'
            '&SecretKey=$_eSmsSecretKey'
            '&SmsType=2' // 2 là tin nhắn CSKH/OTP
            '&Brandname=Verify'); // Thay "Verify" bằng Brandname nếu có

        final response = await http.get(url);
        final data = json.decode(response.body);

        if (data['CodeResult'] == '100') {
          debugPrint('--- [eSMS] Đã gửi OTP $_mockOtp đến $phoneNumber ---');
          codeSent('esms-session-$phoneNumber', null);
        } else {
          debugPrint('--- [eSMS] Lỗi: ${data['ErrorMessage']} ---');
          verificationFailed(FirebaseAuthException(
            code: 'esms-failed',
            message: data['ErrorMessage'] ?? 'Lỗi gửi tin nhắn qua eSMS',
          ));
        }
      } catch (e) {
        verificationFailed(FirebaseAuthException(code: 'error', message: e.toString()));
      }
      return;
    }
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This only happens on Android usually (auto-verification)
          // For simplicity in this flow, we'll mostly rely on codeSent
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint('Verify Phone Error: $e');
      rethrow;
    }
  }

  Future<void> verifyOTPAndRegister({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String password,
    required String displayName,
  }) async {
    // Logic cho Test Mode hoặc eSMS
    if (isTestMode || (_eSmsApiKey.isNotEmpty && _eSmsSecretKey.isNotEmpty)) {
      if (smsCode != _mockOtp) {
        throw Exception('Mã OTP không chính xác');
      }
      
      // Đăng ký user vào Firestore
      String uid = 'user-${phoneNumber.replaceAll('+', '')}';
      
      await _firestore.collection('users').doc(uid).set({
        'role': 'customer',
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'address': '',
        'identityCard': '',
        'photoUrl': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=random',
      });
      
      _role = 'customer';
      _phoneNumber = phoneNumber;
      notifyListeners();
      return;
    }
    try {
      // 1. Verify SMS Code
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      // We sign in temporarily to link/ensure it's valid
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Save user data to Firestore (including password hash - though in real apps, use a backend)
        // Since we don't have a custom backend, we'll store it in Firestore for the demo
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'role': 'customer',
          'displayName': displayName,
          'phoneNumber': phoneNumber,
          'password': password, // WARNING: Storing plain text password for this demo requested logic
          'createdAt': FieldValue.serverTimestamp(),
          'address': '',
          'identityCard': '',
        });
        
        await firebaseUser.updateDisplayName(displayName);
        _user = firebaseUser;
        _role = 'customer';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('OTP Registration Error: $e');
      rethrow;
    }
  }

  Future<void> signInWithPhoneAndPassword(String phoneNumber, String password) async {
    try {
      // 1. Find user in Firestore by phone number
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Số điện thoại hoặc mật khẩu không chính xác');
      }

      // 2. Since Firebase Auth doesn't handle this custom flow directly for 'signing in', 
      // we need to maintain a session. 
      // Option A: Use a custom token (requires backend).
      // Option B: Just verify the phone via SMS every time? No, user wants Phone+Pass.
      // Option C: Re-authenticate the firebase user if they are already known.
      
      // For this specific 'Phone + Pass' logic without a backend, 
      // we'll simulate the persistence by just setting the user if found.
      // However, FirebaseAuth actually needs a valid token.
      
      // A common workaround for local testing: Use an email linked to the phone
      // but for this task, I'll stick to the Firestore lookup and then 
      // perform a 'silent' login if possible or just rely on Firestore state for this demo.
      
      // BEST APPROACH for this request: Use the standard FirebaseAuth anonymous or email 
      // if we must have a User object, OR just use the found doc.
      _user = _auth.currentUser; // Placeholder if already cached
      final data = query.docs.first.data() as Map<String, dynamic>;
      _role = data['role'] ?? 'customer';
      _phoneNumber = phoneNumber;
      _address = data['address'];
      
      // Note: In a real app, you'd use Firebase Custom Auth with a server-side token.
      notifyListeners();
    } catch (e) {
      debugPrint('Phone Sign-In Error: $e');
      rethrow;
    }
  }

  // --- Legacy Email/Google Methods (Keeping for compatibility but minimizing) ---

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
