import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/application.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _selectedTab = 'Applied'; // 'Applied', 'Interview', 'Accepted', 'All'

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    
    final user = authProvider.userProfile;

    // Filter applications based on selected tab
    final filteredApps = appProvider.applications.where((app) {
      if (_selectedTab == 'All') return true;
      if (_selectedTab == 'Applied') {
        return app.status == ApplicationStatus.applied || 
               app.status == ApplicationStatus.underReview;
      }
      if (_selectedTab == 'Interview') {
        return app.status == ApplicationStatus.interview;
      }
      if (_selectedTab == 'Accepted') {
        return app.status == ApplicationStatus.accepted;
      }
      return true;
    }).toList();

    final tabs = ['Applied', 'Interview', 'Accepted', 'All'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            authProvider.isStartup ? 'Incoming Applicants' : 'My Applications',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          
          // Tab bar (horizontal pill tags)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: tabs.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = _selectedTab == tab;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFF1F2F6),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Applications List
          Expanded(
            child: filteredApps.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      final isBookmarked = bookmarkProvider.isBookmarked(app.opportunityId);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F2F6), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Company Icon, Title/Subtitle, and Bookmark
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _getBadgeColor(app.status).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      app.companyName.isNotEmpty ? app.companyName[0].toUpperCase() : 'V',
                                      style: TextStyle(
                                        color: _getBadgeColor(app.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.opportunityTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          app.companyName,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Saved Opportunity Bookmark
                                  if (!authProvider.isStartup)
                                    GestureDetector(
                                      onTap: () => bookmarkProvider.toggleBookmark(app.opportunityId),
                                      child: Icon(
                                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F2F6)),
                              
                              // Bottom Row: Date and Status Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormatter.timeAgo(app.appliedDate, isApplied: true),
                                    style: const TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  
                                  // Dynamic Status Badge
                                  _buildStatusBadge(app.status, context, app, authProvider.isStartup),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.description_outlined, size: 50, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          Text(
            'No applications found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Applications will appear here once submitted.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status, BuildContext context, Application app, bool isStartup) {
    final color = _getBadgeColor(status);
    final label = status.toReadableString();

    if (isStartup) {
      // Startup founders can click to change applicant status! This demonstrates real-time interactive updates.
      return PopupMenuButton<ApplicationStatus>(
        onSelected: (newStatus) {
          Provider.of<ApplicationProvider>(context, listen: false)
              .updateStatus(app.id, newStatus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Applicant status updated to: ${newStatus.toReadableString()}'),
              backgroundColor: _getBadgeColor(newStatus),
            ),
          );
        },
        itemBuilder: (context) => ApplicationStatus.values.map((s) {
          return PopupMenuItem<ApplicationStatus>(
            value: s,
            child: Text(s.toReadableString()),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down_rounded, color: color, size: 14),
            ],
          ),
        ),
      );
    }

    // Standard static badge for student view
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getBadgeColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.appliedBadge;
      case ApplicationStatus.underReview:
        return AppColors.underReviewBadge;
      case ApplicationStatus.shortlisted:
        return AppColors.shortlistedBadge;
      case ApplicationStatus.interview:
        return AppColors.interviewBadge;
      case ApplicationStatus.accepted:
        return AppColors.acceptedBadge;
      case ApplicationStatus.closed:
        return AppColors.closedBadge;
    }
  }
}
