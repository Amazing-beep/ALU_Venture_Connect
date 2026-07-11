import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6C5CE7); // Deep premium purple
  static const Color primaryLight = Color(0xFFE8E5FF); // Accent light purple
  static const Color background = Color(0xFFF8F9FD); // Clean off-white background
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF2D3436); // Dark slate grey for primary text
  static const Color textSecondary = Color(0xFF636E72); // Slate grey for secondary text
  static const Color textLight = Color(0xFFB2BEC3); // Light grey for disabled/muted text

  // Badges & Status colors
  static const Color appliedBadge = Color(0xFF6C5CE7); // Purple for Applied tab/pill
  static const Color underReviewBadge = Color(0xFFFFAD36); // Soft orange/yellow
  static const Color shortlistedBadge = Color(0xFF00B894); // Teal/emerald green
  static const Color closedBadge = Color(0xFF95A5A6); // Neutral grey
  static const Color interviewBadge = Color(0xFF0984E3); // Bright blue
  static const Color acceptedBadge = Color(0xFF2ECC71); // Soft green

  // Functional colors
  static const Color bookmarkActive = Color(0xFF6C5CE7);
  static const Color error = Color(0xFFD63031);
  static const Color border = Color(0xFFDFE6E9);

  // Gradient definitions (Matching the premium card style)
  static const List<Color> recommendedCardGradient = [
    Color(0xFF6C5CE7), // Deep purple
    Color(0xFFA55EEA), // Medium purple-pink
    Color(0xFFFF7675), // Peach-orange
  ];

  static const List<Color> welcomeGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF8E2DE2),
  ];
}
