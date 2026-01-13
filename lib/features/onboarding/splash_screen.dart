import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // Artificial delay to show off animations
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    final roleString = prefs.getString('user_role');

    if (mounted) {
      if (seen) {
        if (roleString != null && roleString != 'UserRole.none') {
          if (roleString == 'UserRole.driver') {
            final verificationStatus = prefs.getString('verification_status');
            if (verificationStatus == 'VerificationStatus.verified') {
              context.go('/home');
            } else if (verificationStatus == 'VerificationStatus.pending') {
              context.go('/verification-pending');
            } else {
              context.go('/driver-verification');
            }
          } else {
            // Requester or other roles go to home directly for now
            context.go('/home');
          }
        } else {
          context.go('/welcome');
        }
      } else {
        context.go('/intro');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon with bounce/pulse
            Icon(
                  Icons.local_shipping_rounded,
                  size: 80.sp,
                  color: Theme.of(context).colorScheme.primary,
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withOpacity(0.3),
                ),

            SizedBox(height: 16.h),

            // App Name with fade and slide
            Text(
              'Logistix',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            SizedBox(height: 8.h),

            // Tagline
            Text(
              'Moving things, made simple.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(delay: 600.ms),

            SizedBox(height: 48.h),

            // Custom Loader
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
