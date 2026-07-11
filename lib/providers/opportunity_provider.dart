import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/opportunity.dart';
import '../data/repositories/firebase_service.dart';

class OpportunityProvider extends ChangeNotifier {
  List<Opportunity> _allOpportunities = [];
  List<Opportunity> _filteredOpportunities = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Design', 'Engineering', 'Marketing', 'Data', 'Other'
  StreamSubscription<List<Opportunity>>? _oppSubscription;

  List<Opportunity> get opportunities => _filteredOpportunities;
  List<Opportunity> get allOpportunities => _allOpportunities;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  OpportunityProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _oppSubscription = FirebaseService.opportunityRepository.streamOpportunities().listen(
      (oppList) {
        _allOpportunities = oppList;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredOpportunities = _allOpportunities.where((opp) {
      // Category filter
      final matchesCategory = _selectedCategory == 'All' ||
          opp.category.toLowerCase() == _selectedCategory.toLowerCase();

      // Search query filter
      final matchesSearch = opp.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.skills.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          opp.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> createOpportunity(Opportunity opportunity) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseService.opportunityRepository.createOpportunity(opportunity);
      // Stream will automatically trigger updates, but we force locally just in case
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseService.opportunityRepository.deleteOpportunity(opportunityId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _oppSubscription?.cancel();
    super.dispose();
  }
}
