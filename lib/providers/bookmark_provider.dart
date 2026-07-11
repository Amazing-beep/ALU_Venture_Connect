import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  final Set<String> _bookmarkedOpportunityIds = {};
  SharedPreferences? _prefs;

  Set<String> get bookmarkedOpportunityIds => _bookmarkedOpportunityIds;

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs?.getStringList('bookmarked_opportunities') ?? [];
    _bookmarkedOpportunityIds.addAll(list);
    notifyListeners();
  }

  bool isBookmarked(String opportunityId) {
    return _bookmarkedOpportunityIds.contains(opportunityId);
  }

  Future<void> toggleBookmark(String opportunityId) async {
    if (_bookmarkedOpportunityIds.contains(opportunityId)) {
      _bookmarkedOpportunityIds.remove(opportunityId);
    } else {
      _bookmarkedOpportunityIds.add(opportunityId);
    }
    notifyListeners();
    if (_prefs != null) {
      await _prefs!.setStringList('bookmarked_opportunities', _bookmarkedOpportunityIds.toList());
    }
  }
}
