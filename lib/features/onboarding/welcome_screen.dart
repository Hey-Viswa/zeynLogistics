import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import 'role_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) async {
    // Save onboarding state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    // Update role
    await ref.read(roleProvider.notifier).setRole(role);

    // Persist to Backend
    // Start persistence in background or await it?
    // Ideally await to ensure it sticks.
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'role': role == UserRole.driver ? 'driver' : 'requester',
      });
    }

    // Navigate
    if (context.mounted) {
      if (role == UserRole.driver) {
        final status = ref.read(verificationProvider);
        if (status == VerificationStatus.none) {
          context.push('/driver-verification');
        } else if (status == VerificationStatus.pending) {
          context.push('/verification-pending');
        } else {
          context.push('/home');
        }
      } else {
        context.push('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Title Section
              Text(
                'Welcome to Logistix',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              SizedBox(height: 8.h),
              Text(
                    'How will you\nuse the app?',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.left,
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              SizedBox(height: 48.h),

              // Role Cards
              _RoleCard(
                icon: Icons.local_shipping_outlined,
                title: 'Driver',
                description: 'I want to accept trips and earn money.',
                onTap: () => _selectRole(context, ref, UserRole.driver),
                delay: 400.ms,
              ),
              SizedBox(height: 16.h),
              _RoleCard(
                icon: Icons.business_center_outlined,
                title: 'Requester',
                description: 'I want to book vehicles for moving goods.',
                onTap: () => _selectRole(context, ref, UserRole.requester),
                delay: 600.ms,
              ),
              const Spacer(),

              // Footer text styling
              Center(
                child: Text(
                  'By continuing, you agree to our Terms & Conditions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Duration delay;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap();
            },
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
