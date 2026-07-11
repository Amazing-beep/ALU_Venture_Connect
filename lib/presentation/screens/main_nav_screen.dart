import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import 'home/home_screen.dart';
import 'explore/explore_screen.dart';
import 'applications/applications_screen.dart';
import 'profile/profile_screen.dart';
import 'startup/startup_dashboard_screen.dart';
import 'startup/create_opportunity_screen.dart';
import '../../core/theme/app_colors.dart';

class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final navProvider = Provider.of<TabNavigationProvider>(context);
    final isStartup = authProvider.isStartup;
    final currentIndex = navProvider.currentIndex;

    // Define tabs dynamically based on user role
    final List<Widget> studentScreens = [
      const HomeScreen(),
      const ExploreScreen(),
      const ApplicationsScreen(),
      const ProfileScreen(),
    ];

    final List<Widget> startupScreens = [
      const StartupDashboardScreen(),
      const CreateOpportunityScreen(),
      const ApplicationsScreen(), // Shows applicant lists for startups
      const ProfileScreen(),
    ];

    final List<Widget> activeScreens = isStartup ? startupScreens : studentScreens;

    // Define navigation items dynamically
    final List<NavigationDestination> studentDestinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: AppColors.primary),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.search_rounded),
        selectedIcon: Icon(Icons.search, color: AppColors.primary),
        label: 'Explore',
      ),
      NavigationDestination(
        icon: Icon(Icons.description_outlined),
        selectedIcon: Icon(Icons.description, color: AppColors.primary),
        label: 'Applications',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person, color: AppColors.primary),
        label: 'Profile',
      ),
    ];

    final List<NavigationDestination> startupDestinations = const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.add_circle_outline_rounded),
        selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
        label: 'Post Role',
      ),
      NavigationDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people, color: AppColors.primary),
        label: 'Applicants',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person, color: AppColors.primary),
        label: 'Profile',
      ),
    ];

    final activeDestinations = isStartup ? startupDestinations : studentDestinations;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: activeScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            navProvider.setTab(index);
          },
          destinations: activeDestinations,
          height: 65,
          elevation: 0,
        ),
      ),
    );
  }
}
