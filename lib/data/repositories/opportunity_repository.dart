import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> getOpportunities();
  Stream<List<Opportunity>> streamOpportunities();
  Future<Opportunity> createOpportunity(Opportunity opportunity);
  Future<void> deleteOpportunity(String opportunityId);
  Future<Opportunity?> getOpportunityById(String opportunityId);
}

class FirebaseOpportunityRepository implements OpportunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Opportunity>> getOpportunities() async {
    final querySnapshot = await _firestore
        .collection('opportunities')
        .orderBy('postedDate', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => Opportunity.fromMap(doc.data()))
        .toList();
  }

  @override
  Stream<List<Opportunity>> streamOpportunities() {
    return _firestore
        .collection('opportunities')
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Opportunity.fromMap(doc.data()))
            .toList());
  }

  @override
  Future<Opportunity> createOpportunity(Opportunity opportunity) async {
    final ref = _firestore.collection('opportunities').doc(opportunity.id.isEmpty ? null : opportunity.id);
    final finalOpp = Opportunity(
      id: ref.id,
      title: opportunity.title,
      company: opportunity.company,
      companyLogoUrl: opportunity.companyLogoUrl,
      location: opportunity.location,
      hoursPerWeek: opportunity.hoursPerWeek,
      postedDate: opportunity.postedDate,
      category: opportunity.category,
      description: opportunity.description,
      skills: opportunity.skills,
      tags: opportunity.tags,
      postedBy: opportunity.postedBy,
    );
    await ref.set(finalOpp.toMap());
    return finalOpp;
  }

  @override
  Future<void> deleteOpportunity(String opportunityId) async {
    await _firestore.collection('opportunities').doc(opportunityId).delete();
  }

  @override
  Future<Opportunity?> getOpportunityById(String opportunityId) async {
    final doc = await _firestore.collection('opportunities').doc(opportunityId).get();
    if (doc.exists && doc.data() != null) {
      return Opportunity.fromMap(doc.data()!);
    }
    return null;
  }
}

class MockOpportunityRepository implements OpportunityRepository {
  final StreamController<List<Opportunity>> _opportunitiesController =
      StreamController<List<Opportunity>>.broadcast();
  final List<Opportunity> _mockOpportunities = [];

  MockOpportunityRepository() {
    // Populate with items matching reference screenshot exactly
    _mockOpportunities.addAll([
      Opportunity(
        id: 'opp_ux_volunteer',
        title: 'UX Research Volunteer',
        company: 'EduBridge',
        companyLogoUrl: '', // Will render custom initials or placeholder logo nicely
        location: 'Remote',
        hoursPerWeek: '4-6 hrs/week',
        postedDate: DateTime.now().subtract(const Duration(days: 2)), // Posted 2d ago
        category: 'Design',
        description: 'Help us design and build a premium learning experience for high school students. You will participate in user interviews, design wireframes in Figma, and build prototypes.',
        skills: ['UX Design', 'Research', 'Figma', 'Problem Solving'],
        tags: ['UX Design', 'Research', 'Remote'],
        postedBy: 'startup_edubridge',
      ),
      Opportunity(
        id: 'opp_flutter_dev',
        title: 'Flutter Developer',
        company: 'Learnify',
        companyLogoUrl: '',
        location: 'On-campus',
        hoursPerWeek: 'Part-time (8-10 hrs/week)',
        postedDate: DateTime.now().subtract(const Duration(days: 3)), // Posted 3 days ago
        category: 'Engineering',
        description: 'Help us build the mobile app for our learning platform. You\'ll work on real features and UI, collaborating with product designers and backend developers.',
        skills: ['Flutter', 'Dart', 'Problem Solving', 'Git'],
        tags: ['Flutter', 'Dart', 'Firebase'],
        postedBy: 'startup_learnify',
      ),
      Opportunity(
        id: 'opp_social_media',
        title: 'Social Media Assistant',
        company: 'GreenLoop',
        companyLogoUrl: '',
        location: 'Kigali',
        hoursPerWeek: 'Part-time',
        postedDate: DateTime.now().subtract(const Duration(days: 14)), // Posted 2 weeks ago
        category: 'Marketing',
        description: 'Support the GreenLoop green marketing campaigns on campus and within Kigali. Manage Instagram/LinkedIn posts and drive student engagements.',
        skills: ['Social Media', 'Content Creation', 'Canva', 'Communication'],
        tags: ['Marketing', 'Social Media', 'Part-time'],
        postedBy: 'startup_greenloop',
      ),
      Opportunity(
        id: 'opp_data_analyst',
        title: 'Data Analyst Intern',
        company: 'VentureConnect',
        companyLogoUrl: '',
        location: 'Remote',
        hoursPerWeek: '10 hrs/week',
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Data',
        description: 'Help analyze user engagement across ALU student platforms and compile weekly usage reports.',
        skills: ['SQL', 'Python', 'Tableau', 'Data Cleaning'],
        tags: ['Data Science', 'SQL', 'Remote'],
        postedBy: 'startup_learnify',
      )
    ]);
    _opportunitiesController.add(_mockOpportunities);
  }

  @override
  Future<List<Opportunity>> getOpportunities() async {
    return _mockOpportunities;
  }

  @override
  Stream<List<Opportunity>> streamOpportunities() {
    // Periodically update to simulate live database changes if needed,
    // or just return the static stream.
    Timer.run(() => _opportunitiesController.add(_mockOpportunities));
    return _opportunitiesController.stream;
  }

  @override
  Future<Opportunity> createOpportunity(Opportunity opportunity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = opportunity.id.isEmpty
        ? 'opp_${DateTime.now().millisecondsSinceEpoch}'
        : opportunity.id;
    final finalOpp = Opportunity(
      id: id,
      title: opportunity.title,
      company: opportunity.company,
      companyLogoUrl: opportunity.companyLogoUrl,
      location: opportunity.location,
      hoursPerWeek: opportunity.hoursPerWeek,
      postedDate: opportunity.postedDate,
      category: opportunity.category,
      description: opportunity.description,
      skills: opportunity.skills,
      tags: opportunity.tags,
      postedBy: opportunity.postedBy,
    );
    _mockOpportunities.insert(0, finalOpp);
    _opportunitiesController.add(_mockOpportunities);
    return finalOpp;
  }

  @override
  Future<void> deleteOpportunity(String opportunityId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockOpportunities.removeWhere((opp) => opp.id == opportunityId);
    _opportunitiesController.add(_mockOpportunities);
  }

  @override
  Future<Opportunity?> getOpportunityById(String opportunityId) async {
    try {
      return _mockOpportunities.firstWhere((opp) => opp.id == opportunityId);
    } catch (_) {
      return null;
    }
  }
}
