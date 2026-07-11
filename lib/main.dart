import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/opportunity_provider.dart';
import 'providers/application_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/navigation_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/email_verification_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/startup/pending_verification_screen.dart';
import 'presentation/screens/main_nav_screen.dart';
import 'presentation/screens/details/opportunity_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VentureConnectApp());
}

class VentureConnectApp extends StatelessWidget {
  const VentureConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OpportunityProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => TabNavigationProvider()),
      ],
      child: MaterialApp(
        title: 'ALU VentureConnect',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/email_verification': (context) => const EmailVerificationScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/pending_verification': (context) => const PendingVerificationScreen(),
          '/main_nav': (context) => const MainNavScreen(),
          '/opportunity_details': (context) => const OpportunityDetailsScreen(),
        },
      ),
    );
  }
}
