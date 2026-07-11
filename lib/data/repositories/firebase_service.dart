import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'auth_repository.dart';
import 'opportunity_repository.dart';
import 'application_repository.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _useMock = true;

  static bool get useMock => _useMock;

  static Future<void> initialize() async {
    try {
      // Trying to initialize Firebase with configured platform options.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Extra validation: check if project keys are placeholders. If so, fail back to Mock mode.
      if (DefaultFirebaseOptions.currentPlatform.apiKey.contains('REPLACE_WITH')) {
        throw Exception("Firebase credentials are placeholders. Please configure real keys.");
      }
      _useMock = false;
      if (kDebugMode) {
        print("Firebase successfully initialized. Using Firestore backend.");
      }
    } catch (e) {
      _useMock = true;
      if (kDebugMode) {
        print("Firebase initialization failed ($e). Falling back to local Mock database.");
      }
    }
  }

  // Registry of Repositories based on Firebase toggle
  static late final AuthRepository authRepository;
  static late final OpportunityRepository opportunityRepository;
  static late final ApplicationRepository applicationRepository;

  static void setupRepositories() {
    if (_useMock) {
      authRepository = MockAuthRepository();
      opportunityRepository = MockOpportunityRepository();
      applicationRepository = MockApplicationRepository();
    } else {
      authRepository = FirebaseAuthRepository();
      opportunityRepository = FirebaseOpportunityRepository();
      applicationRepository = FirebaseApplicationRepository();
    }
  }
}
