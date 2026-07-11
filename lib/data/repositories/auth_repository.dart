import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> login(String email, String password);
  Future<UserProfile?> register(UserProfile profile, String password);
  Future<void> logout();
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile?> updateProfile(UserProfile profile);
  Future<void> verifyStartup(String userId);
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  Stream<UserProfile?> get onAuthStateChanged;
}

class FirebaseAuthRepository implements AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<UserProfile?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await getUserProfile(fbUser.uid);
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (e) {
      // Log or handle
    }
    return null;
  }

  @override
  Future<UserProfile?> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      return await getUserProfile(credential.user!.uid);
    }
    return null;
  }

  @override
  Future<UserProfile?> register(UserProfile profile, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: profile.email,
      password: password,
    );
    if (credential.user != null) {
      final updatedProfile = profile.copyWith(id: credential.user!.uid);
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(updatedProfile.toMap());
      // Automatically send verification email
      await credential.user!.sendEmailVerification();
      return updatedProfile;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      return await getUserProfile(fbUser.uid);
    }
    return null;
  }

  @override
  Future<UserProfile?> updateProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.id).update(profile.toMap());
    return profile;
  }

  @override
  Future<void> verifyStartup(String userId) async {
    await _firestore.collection('users').doc(userId).update({'isVerified': true});
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      return _firebaseAuth.currentUser!.emailVerified;
    }
    return true; // Fallback
  }
}

class MockAuthRepository implements AuthRepository {
  final StreamController<UserProfile?> _authStateController = StreamController<UserProfile?>.broadcast();
  UserProfile? _currentUser;

  // Initial mock data matching reference image exactly
  final Map<String, UserProfile> _mockUsers = {
    'student_amina': UserProfile(
      id: 'student_amina',
      email: 'amina@alu.edu',
      name: 'Amazing Mkhonta',
      role: UserRole.student,
      location: 'Kigali, Rwanda',
      profilePictureUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
      skills: ['Flutter', 'Dart', 'UX Design', 'Problem Solving', 'Research'],
      bio: 'ALU student passionate about UX research and Flutter mobile development.',
    ),
    'startup_learnify': UserProfile(
      id: 'startup_learnify',
      email: 'learnify@alu.edu',
      name: 'Learnify Team',
      role: UserRole.startup,
      startupName: 'Learnify',
      registrationNumber: 'ALU-V-2026-004',
      isVerified: true,
      startupDescription: 'Building modern mobile and web learning platforms for African students.',
    ),
    'startup_edubridge': UserProfile(
      id: 'startup_edubridge',
      email: 'edubridge@alu.edu',
      name: 'EduBridge Founder',
      role: UserRole.startup,
      startupName: 'EduBridge',
      registrationNumber: 'ALU-V-2026-012',
      isVerified: true,
      startupDescription: 'Bridging education resources and career skills for secondary school students.',
    ),
    'startup_greenloop': UserProfile(
      id: 'startup_greenloop',
      email: 'greenloop@alu.edu',
      name: 'GreenLoop Org',
      role: UserRole.startup,
      startupName: 'GreenLoop',
      registrationNumber: 'ALU-V-2026-088',
      isVerified: true,
      startupDescription: 'Eco-tech solutions for recycling and community awareness.',
    ),
  };

  MockAuthRepository() {
    // Start with Amazing logged in to match reference image UI immediately
    _currentUser = _mockUsers['student_amina'];
    _authStateController.add(_currentUser);
  }

  @override
  Stream<UserProfile?> get onAuthStateChanged => _authStateController.stream;

  @override
  Future<UserProfile?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var user in _mockUsers.values) {
      if (user.email == email) {
        _currentUser = user;
        _authStateController.add(_currentUser);
        return _currentUser;
      }
    }
    throw Exception('User not found. Try logging in as "amina@alu.edu".');
  }

  @override
  Future<UserProfile?> register(UserProfile profile, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = profile.id.isEmpty ? 'user_${DateTime.now().millisecondsSinceEpoch}' : profile.id;
    final updatedProfile = profile.copyWith(id: id);
    _mockUsers[id] = updatedProfile;
    _currentUser = updatedProfile;
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserProfile?> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockUsers[profile.id] = profile;
    _currentUser = profile;
    return profile;
  }

  @override
  Future<void> verifyStartup(String userId) async {
    final user = _mockUsers[userId];
    if (user != null) {
      _mockUsers[userId] = user.copyWith(isVerified: true);
      if (_currentUser?.id == userId) {
        _currentUser = _mockUsers[userId];
      }
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<bool> isEmailVerified() async {
    return true; // Mock users are always verified
  }
}
