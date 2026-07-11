import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class PendingVerificationScreen extends StatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  State<PendingVerificationScreen> createState() => _PendingVerificationScreenState();
}

class _PendingVerificationScreenState extends State<PendingVerificationScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // In Mock mode, clicking this will automatically verify them so they can proceed in the simulator!
    // This is a great developer utility for testing the startup dashboard.
    if (authProvider.userProfile != null) {
      await authProvider.verifyStartup(authProvider.userProfile!.id);
      if (!mounted) return;
      
      Navigator.pushNamedAndRemoveUntil(context, '/main_nav', (route) => false);
    }
    
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userProfile;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.underReviewBadge.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gpp_maybe_rounded,
                    size: 80,
                    color: AppColors.underReviewBadge,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Venture Verification\nPending',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'To ensure the safety and focus of the ALU ecosystem, all student ventures must be recognized by ALU Hub or the Student Ventures Program.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Venture details card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Venture Name', style: TextStyle(color: AppColors.textSecondary)),
                        Text(user?.startupName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Registration ID', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          user?.registrationNumber ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status', style: TextStyle(color: AppColors.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.underReviewBadge.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PENDING REVIEW',
                            style: TextStyle(
                              color: AppColors.underReviewBadge,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Developer simulator hint
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.shortlistedBadge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚙️ Developer Mode: Click status check to auto-verify.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.shortlistedBadge,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Check Status Button
              ElevatedButton(
                onPressed: _isChecking ? null : _checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Check Verification Status',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 12),
              
              // Logout Button
              TextButton(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
                },
                child: const Text(
                  'Sign Out / Cancel',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
