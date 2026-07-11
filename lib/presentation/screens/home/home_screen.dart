import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/opportunity.dart';
import '../../../providers/navigation_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userProfile;
    final userName = user?.name.split(' ').first ?? 'Amazing';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // 1. Header (Greeting, Avatar, Notification Bell)
                _buildHeader(context, userName, user?.profilePictureUrl),
                const SizedBox(height: 24),
                
                // 2. Search & Filter Bar
                _buildSearchAndFilter(context),
                const SizedBox(height: 24),
                
                // 3. Recommended Section
                _buildRecommendedSection(context),
                const SizedBox(height: 24),
                
                // 4. Browse by Category Section
                _buildBrowseByCategory(context),
                const SizedBox(height: 28),
                
                // 5. Recent Opportunities Section
                _buildRecentOpportunities(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String? avatarUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hello, $name',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '👋',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Find meaningful ways to contribute.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            // Notification Bell
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F2F6), width: 1.5),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Avatar Image
            GestureDetector(
              onTap: () {
                Provider.of<TabNavigationProvider>(context, listen: false).setTab(3);
              },
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 21,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: AppColors.primaryLight,
                    )
                  : CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final oppProvider = Provider.of<OpportunityProvider>(context, listen: false);
    return Row(
      children: [
        // Search Input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => oppProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search opportunities...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFF1F2F6), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter Button
        GestureDetector(
          onTap: () {
            Provider.of<TabNavigationProvider>(context, listen: false).setTab(1);
          },
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F2F6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    
    // Pick the first available opportunity as the recommended card.
    // Prefer the UX volunteer role if it exists, else use the first in the list.
    final allOpps = oppProvider.allOpportunities;
    Opportunity? recommendedOpp;
    if (allOpps.isNotEmpty) {
      try {
        recommendedOpp = allOpps.firstWhere((o) => o.id == 'opp_ux_volunteer');
      } catch (_) {
        recommendedOpp = allOpps.first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TabNavigationProvider>(context, listen: false).setTab(1);
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Show loading shimmer while data is coming in
        if (oppProvider.isLoading && allOpps.isEmpty)
          Container(
            height: 195,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (recommendedOpp != null)
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/opportunity_details',
              arguments: recommendedOpp,
            ),
            child: Container(
              height: 195,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.recommendedCardGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => bookmarkProvider.toggleBookmark(recommendedOpp!.id),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              bookmarkProvider.isBookmarked(recommendedOpp.id)
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recommendedOpp.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.home_work_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          recommendedOpp.company,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              recommendedOpp.hoursPerWeek,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          DateFormatter.timeAgo(recommendedOpp.postedDate),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          // No opportunities and not loading — show a friendly empty state
          GestureDetector(
            onTap: () => Provider.of<TabNavigationProvider>(context, listen: false).setTab(1),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F2F6)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_outlined, color: AppColors.textLight, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'No opportunities yet — tap Explore to browse',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBrowseByCategory(BuildContext context) {
    final oppProvider = Provider.of<OpportunityProvider>(context);

    final categories = [
      {'name': 'Design', 'icon': Icons.palette_outlined, 'color': const Color(0xFFF1F0FF)},
      {'name': 'Engineering', 'icon': Icons.code_rounded, 'color': const Color(0xFFE3F2FD)},
      {'name': 'Marketing', 'icon': Icons.campaign_outlined, 'color': const Color(0xFFFFF3E0)},
      {'name': 'Data', 'icon': Icons.analytics_outlined, 'color': const Color(0xFFE8F5E9)},
      {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFFECEFF1)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse by category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final isSelected = oppProvider.selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () {
                  oppProvider.setCategory(
                    isSelected ? 'All' : (cat['name'] as String),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : (cat['color'] as Color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                          ],
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOpportunities(BuildContext context) {
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    
    // Get all opportunities except the recommended card at the top
    final allOpps = oppProvider.allOpportunities;
    final recentOpps = allOpps.where((opp) => opp.id != 'opp_ux_volunteer').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent opportunities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (oppProvider.isLoading && allOpps.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          )
        else if (recentOpps.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F2F6)),
            ),
            child: const Text(
              'No other opportunities yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOpps.length,
            itemBuilder: (context, index) {
              final opp = recentOpps[index];
              final isBookmarked = bookmarkProvider.isBookmarked(opp.id);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F2F6), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(opp.category).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(opp.category),
                      color: _getCategoryColor(opp.category),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    opp.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opp.company,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              opp.hoursPerWeek,
                              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
                            const SizedBox(width: 8),
                            Text(
                              opp.location,
                              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => bookmarkProvider.toggleBookmark(opp.id),
                    child: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/opportunity_details',
                    arguments: opp,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Icons.palette_outlined;
      case 'engineering':
        return Icons.code_rounded;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'data':
        return Icons.analytics_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return const Color(0xFF6C5CE7);
      case 'engineering':
        return const Color(0xFF0984E3);
      case 'marketing':
        return const Color(0xFFE17055);
      case 'data':
        return const Color(0xFF00B894);
      default:
        return const Color(0xFF636E72);
    }
  }
}
