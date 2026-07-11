import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Poll every 3 seconds to check if the user verified their email
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isVerified = await authProvider.checkEmailVerified();
      
      if (isVerified && mounted) {
        timer.cancel();
        _cooldownTimer?.cancel();
        
        final user = authProvider.userProfile!;
        if (authProvider.isStartup && !user.isVerified) {
          Navigator.pushReplacementNamed(context, '/pending_verification');
        } else {
          Navigator.pushReplacementNamed(context, '/main_nav');
        }
      }
    });
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_cooldownSeconds > 0) return;

    setState(() => _isResending = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).sendEmailVerification();
      _startCooldown();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification link resent to your email.'),
          backgroundColor: AppColors.shortlistedBadge,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    color: AppColors.primaryLight.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a link to your email address:\n${user?.email ?? ""}\n\nPlease click the link to activate your account.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              
              const SizedBox(height: 32),
              
              // Informative check banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Checking for verification status automatically...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dev simulation bypass
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.shortlistedBadge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚙️ Simulator Mode: Auto-bypassed in Mock mode.',
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
              
              // Resend Button
              ElevatedButton(
                onPressed: _cooldownSeconds > 0 || _isResending ? null : _resendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _cooldownSeconds > 0 
                            ? 'Resend Link in ${_cooldownSeconds}s' 
                            : 'Resend Verification Link',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
