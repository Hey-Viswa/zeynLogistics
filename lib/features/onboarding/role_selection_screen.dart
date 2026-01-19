import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'role_provider.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/data/user_model.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),
              Text(
                'How would you like to use the app?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoleCard(
                      context,
                      ref,
                      title: 'Continue as Rider',
                      description: 'Book rides and travel easily',
                      icon: Icons.person_pin_circle_outlined,
                      role: UserRole.requester,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 24.h),
                    _buildRoleCard(
                      context,
                      ref,
                      title: 'Continue as Driver',
                      description: 'Accept rides and earn money',
                      icon: Icons.directions_car_filled_outlined,
                      role: UserRole.driver,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required IconData icon,
    required UserRole role,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _handleRoleSelection(context, ref, role),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32.sp),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRoleSelection(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) async {
    HapticFeedback.mediumImpact();

    // 1. Update Local State (Prefs)
    await ref.read(roleProvider.notifier).setRole(role);

    // 2. Update Firestore
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      // We use string representation for Firestore 'driver' or 'requester'
      final roleString = role == UserRole.driver ? 'driver' : 'requester';

      // Update role explicitly
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'role': roleString,
      });

      // Force refresh user provider if needed, but stream should catch it
    }

    if (context.mounted) {
      context.go('/home');
    }
  }
}
