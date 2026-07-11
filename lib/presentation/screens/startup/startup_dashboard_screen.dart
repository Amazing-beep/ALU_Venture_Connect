import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

class StartupDashboardScreen extends StatelessWidget {
  const StartupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    
    final user = authProvider.userProfile;
    final startupName = user?.startupName ?? 'ALU Startup';

    // Get opportunities posted by this startup
    final myOpps = oppProvider.allOpportunities
        .where((opp) => opp.postedBy == user?.id || opp.company.toLowerCase() == startupName.toLowerCase())
        .toList();

    final totalPostings = myOpps.length;
    final totalApplicants = appProvider.applications.length; // Simplified for display
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            '$startupName Hub',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // 1. Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.welcomeGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user?.name.split(" ").first ?? "Founder"} 🚀',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your startup listings and connect with ALU student talents.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // 2. Metrics row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context, 
                        totalPostings.toString(), 
                        'Active Roles', 
                        Icons.work_outline_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context, 
                        totalApplicants.toString(), 
                        'Applications', 
                        Icons.people_outline_rounded,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                
                // 3. Opportunities List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Posted Opportunities',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Provider.of<TabNavigationProvider>(context, listen: false).setTab(1);
                      },
                      icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                      label: const Text('Add', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 4. List of listings
                if (myOpps.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myOpps.length,
                    itemBuilder: (context, index) {
                      final opp = myOpps[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F2F6), width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            opp.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${opp.location} • ${opp.hoursPerWeek}\nPosted ${DateFormatter.timeAgo(opp.postedDate)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            onPressed: () {
                              _showDeleteConfirm(context, oppProvider, opp.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F2F6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F2F6)),
      ),
      child: Column(
        children: const [
          Icon(Icons.work_off_outlined, size: 48, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No opportunities posted yet',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 6),
          Text(
            'Tap "Post Role" below to list an internship.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, OpportunityProvider provider, String oppId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Listing?'),
          content: const Text('Are you sure you want to remove this opportunity? All associated application records will remain stored but the posting will be closed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteOpportunity(oppId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted successfully!'), backgroundColor: AppColors.error),
                );
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
