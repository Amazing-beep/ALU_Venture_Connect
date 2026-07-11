import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  StreamSubscription<UserProfile?>? _authSubscription;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userProfile != null;
  bool get isStudent => _userProfile?.role == UserRole.student;
  bool get isStartup => _userProfile?.role == UserRole.startup;

  AuthProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();
    
    // Subscribe to auth state changes from the active repository
    _authSubscription = FirebaseService.authRepository.onAuthStateChanged.listen(
      (profile) {
        _userProfile = profile;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _userProfile = await FirebaseService.authRepository.login(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? startupName,
    String? registrationNumber,
    String? location,
    List<String>? skills,
    String? bio,
  }) async {
    _setLoading(true);
    try {
      final profile = UserProfile(
        id: '',
        email: email,
        name: name,
        role: role,
        startupName: startupName,
        registrationNumber: registrationNumber,
        isVerified: role == UserRole.student ? false : false, // Startup needs verification
        location: location ?? 'Kigali, Rwanda',
        skills: skills ?? [],
        bio: bio ?? '',
      );
      _userProfile = await FirebaseService.authRepository.register(profile, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await FirebaseService.authRepository.logout();
      _userProfile = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    try {
      _userProfile = await FirebaseService.authRepository.updateProfile(updatedProfile);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyStartup(String userId) async {
    await FirebaseService.authRepository.verifyStartup(userId);
    if (_userProfile?.id == userId) {
      _userProfile = _userProfile?.copyWith(isVerified: true);
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await FirebaseService.authRepository.sendPasswordReset(email);
  }

  Future<void> sendEmailVerification() async {
    await FirebaseService.authRepository.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    return await FirebaseService.authRepository.isEmailVerified();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
