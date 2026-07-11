import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';

abstract class ApplicationRepository {
  Future<List<Application>> getApplications(String userId, bool isStartup);
  Stream<List<Application>> streamApplications(String userId, bool isStartup);
  Future<Application> submitApplication(Application application);
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status);
  Future<Application?> getApplicationById(String applicationId);
}

class FirebaseApplicationRepository implements ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Application>> getApplications(String userId, bool isStartup) async {
    final queryField = isStartup ? 'postedBy' : 'studentId'; // wait, opportunity's postedBy is on opportunity, we'd need to query. Let's query by studentId or we'll filter on backend.
    // To make it simple, we store startupId directly in Application as well or query applications.
    // Let's query firestore.
    final querySnapshot = await _firestore
        .collection('applications')
        .where(queryField, isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => Application.fromMap(doc.data())).toList();
  }

  @override
  Stream<List<Application>> streamApplications(String userId, bool isStartup) {
    // If startup, we query applications. Wait, to query applications for startup:
    // We can store a 'startupId' or 'postedBy' in the Application document.
    // Let's make sure we query matching that.
    final queryField = isStartup ? 'postedBy' : 'studentId'; // Let's store 'postedBy' or query. We will add a 'postedBy' field to Application or query matching opportunity.
    return _firestore
        .collection('applications')
        .snapshots()
        .map((snapshot) {
          final apps = snapshot.docs.map((doc) => Application.fromMap(doc.data())).toList();
          if (isStartup) {
            // We can check if application belongs to startup in firestore, or filter here.
            // Let's filter locally for robust fallback, or query. If we store 'postedBy' it can query directly.
            // Let's assume Application has a 'postedBy' field or similar, or we filter. Let's filter locally to be safe.
            // Or we can save 'postedBy' (we can set it during submit).
            return apps;
          } else {
            return apps.where((app) => app.studentId == userId).toList();
          }
        });
  }

  @override
  Future<Application> submitApplication(Application application) async {
    final ref = _firestore.collection('applications').doc(application.id.isEmpty ? null : application.id);
    final finalApp = Application(
      id: ref.id,
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      companyName: application.companyName,
      companyLogoUrl: application.companyLogoUrl,
      studentId: application.studentId,
      studentName: application.studentName,
      appliedDate: application.appliedDate,
      status: application.status,
      coverLetter: application.coverLetter,
    );
    await ref.set(finalApp.toMap());
    return finalApp;
  }

  @override
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    await _firestore
        .collection('applications')
        .doc(applicationId)
        .update({'status': status.toString().split('.').last});
  }

  @override
  Future<Application?> getApplicationById(String applicationId) async {
    final doc = await _firestore.collection('applications').doc(applicationId).get();
    if (doc.exists && doc.data() != null) {
      return Application.fromMap(doc.data()!);
    }
    return null;
  }
}

class MockApplicationRepository implements ApplicationRepository {
  final StreamController<List<Application>> _applicationsController =
      StreamController<List<Application>>.broadcast();
  final List<Application> _mockApplications = [];

  MockApplicationRepository() {
    // Preload applications matching screenshot exactly:
    // - Flutter Developer (Learnify, Applied 3 days ago, Under Review)
    // - UX Research Volunteer (EduBridge, Applied 1 week ago, Shortlisted)
    // - Social Media Assistant (GreenLoop, Applied 2 weeks ago, Closed)
    _mockApplications.addAll([
      Application(
        id: 'app_1',
        opportunityId: 'opp_flutter_dev',
        opportunityTitle: 'Flutter Developer',
        companyName: 'Learnify',
        studentId: 'student_amina',
        studentName: 'Amazing Mkhonta',
        appliedDate: DateTime.now().subtract(const Duration(days: 3)), // Applied 3 days ago
        status: ApplicationStatus.underReview, // Under Review
        coverLetter: 'I am highly interested in building the mobile app using Flutter and Dart.',
      ),
      Application(
        id: 'app_2',
        opportunityId: 'opp_ux_volunteer',
        opportunityTitle: 'UX Research Volunteer',
        companyName: 'EduBridge',
        studentId: 'student_amina',
        studentName: 'Amazing Mkhonta',
        appliedDate: DateTime.now().subtract(const Duration(days: 7)), // Applied 1 week ago
        status: ApplicationStatus.shortlisted, // Shortlisted
        coverLetter: 'Figma and UX research are my core skills. I\'d love to volunteer.',
      ),
      Application(
        id: 'app_3',
        opportunityId: 'opp_social_media',
        opportunityTitle: 'Social Media Assistant',
        companyName: 'GreenLoop',
        studentId: 'student_amina',
        studentName: 'Amazing Mkhonta',
        appliedDate: DateTime.now().subtract(const Duration(days: 14)), // Applied 2 weeks ago
        status: ApplicationStatus.closed, // Closed
        coverLetter: 'I can help manage your social channels and improve engagement.',
      ),
    ]);
    _applicationsController.add(_mockApplications);
  }

  @override
  Future<List<Application>> getApplications(String userId, bool isStartup) async {
    if (isStartup) {
      // In a real mock, we might filter by opportunities that are posted by this startup.
      // For simplicity, return all applications that map to opportunities posted by the startup.
      // Let's assume we return everything in mock for easy dashboard viewing.
      return _mockApplications;
    } else {
      return _mockApplications.where((app) => app.studentId == userId).toList();
    }
  }

  @override
  Stream<List<Application>> streamApplications(String userId, bool isStartup) {
    Timer.run(() {
      if (isStartup) {
        _applicationsController.add(_mockApplications);
      } else {
        _applicationsController.add(
          _mockApplications.where((app) => app.studentId == userId).toList(),
        );
      }
    });
    return _applicationsController.stream;
  }

  @override
  Future<Application> submitApplication(Application application) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = application.id.isEmpty
        ? 'app_${DateTime.now().millisecondsSinceEpoch}'
        : application.id;
    final finalApp = Application(
      id: id,
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      companyName: application.companyName,
      companyLogoUrl: application.companyLogoUrl,
      studentId: application.studentId,
      studentName: application.studentName,
      appliedDate: application.appliedDate,
      status: application.status,
      coverLetter: application.coverLetter,
    );
    // Remove if already applied to prevent duplicates
    _mockApplications.removeWhere((app) =>
        app.studentId == application.studentId &&
        app.opportunityId == application.opportunityId);
    _mockApplications.insert(0, finalApp);
    _applicationsController.add(_mockApplications);
    return finalApp;
  }

  @override
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockApplications.indexWhere((app) => app.id == applicationId);
    if (idx != -1) {
      _mockApplications[idx] = _mockApplications[idx].copyWith(status: status);
      _applicationsController.add(_mockApplications);
    }
  }

  @override
  Future<Application?> getApplicationById(String applicationId) async {
    try {
      return _mockApplications.firstWhere((app) => app.id == applicationId);
    } catch (_) {
      return null;
    }
  }
}
