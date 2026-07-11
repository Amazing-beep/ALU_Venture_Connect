import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/application.dart';
import '../data/repositories/firebase_service.dart';

class ApplicationProvider extends ChangeNotifier {
  List<Application> _applications = [];
  bool _isLoading = false;
  StreamSubscription<List<Application>>? _appSubscription;
  String? _currentUserId;
  bool _isStartup = false;

  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;

  // Filter categories for student "My Applications" screen
  List<Application> getApplicationsByStatus(ApplicationStatus status) {
    return _applications.where((app) => app.status == status).toList();
  }

  // Set context for the current user and start streaming
  void setUserContext(String userId, bool isStartup) {
    if (_currentUserId == userId && _isStartup == isStartup) return;
    
    _currentUserId = userId;
    _isStartup = isStartup;
    
    _appSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _appSubscription = FirebaseService.applicationRepository
        .streamApplications(userId, isStartup)
        .listen(
      (appList) {
        _applications = appList;
        // In Mock mode, we filter student apps manually to match current user
        if (FirebaseService.useMock && !isStartup) {
          _applications = appList.where((app) => app.studentId == userId).toList();
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> submitApplication({
    required String opportunityId,
    required String opportunityTitle,
    required String companyName,
    required String studentId,
    required String studentName,
    String? coverLetter,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final app = Application(
        id: '',
        opportunityId: opportunityId,
        opportunityTitle: opportunityTitle,
        companyName: companyName,
        studentId: studentId,
        studentName: studentName,
        appliedDate: DateTime.now(),
        status: ApplicationStatus.applied,
        coverLetter: coverLetter,
      );
      await FirebaseService.applicationRepository.submitApplication(app);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseService.applicationRepository.updateApplicationStatus(applicationId, status);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasApplied(String opportunityId, String studentId) {
    return _applications.any((app) =>
        app.opportunityId == opportunityId && app.studentId == studentId);
  }

  @override
  void dispose() {
    _appSubscription?.cancel();
    super.dispose();
  }
}
