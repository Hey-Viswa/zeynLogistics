import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/data/user_model.dart';
import 'role_provider.dart';
import 'package:flutter/services.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _isManagerLogin =
      false; // Track if user authenticated as manager via passcode

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;

        // Check if user exists in Firestore
        final userRepo = ref.read(userRepositoryProvider);
        final userData = await userRepo.getUser(user.uid);

        if (userData == null) {
          // Create new user profile
          final role = _isManagerLogin
              ? 'manager'
              : null; // Set manager if authorized
          final newUser = UserModel(
            id: user.uid,
            phoneNumber: user.phoneNumber ?? '',
            email: user.email,
            name: user.displayName,
            photoUrl: user.photoURL,
            role: role,
            createdAt: DateTime.now(),
          );
          await userRepo.createUser(newUser);

          if (mounted) {
            if (_isManagerLogin) {
              context.go('/manager-home');
            } else {
              context.go('/welcome');
            }
          }
        } else {
          // Existing user - Sync local state with Firestore data
          // If manager login was authorized locally, force upgrade the role in Firestore
          if (_isManagerLogin && userData.role != 'manager') {
            await userRepo.updateUser(user.uid, {'role': 'manager'});
            // Re-fetch or manually construct updated model?
            // Simplest: just proceed as manager
            await ref.read(roleProvider.notifier).setRole(UserRole.manager);
            if (mounted) context.go('/manager-home');
            return;
          }

          if (userData.role != null) {
            UserRole role;
            if (userData.role == 'driver') {
              role = UserRole.driver;
            } else if (userData.role == 'requester') {
              role = UserRole.requester;
            } else if (userData.role == 'manager') {
              role = UserRole.manager;
            } else {
              role = UserRole.none;
            }

            // Update RoleProvider
            await ref.read(roleProvider.notifier).setRole(role);

            // Redirect Manager
            if (role == UserRole.manager) {
              if (mounted) context.go('/manager-home');
              return;
            }

            // Update VerificationProvider (for drivers)
            if (role == UserRole.driver) {
              VerificationStatus vStatus = VerificationStatus.none;
              if (userData.isVerified) {
                vStatus = VerificationStatus.verified;
              } else if (userData.documents.isNotEmpty) {
                vStatus = VerificationStatus.pending;
              }
              await ref.read(verificationProvider.notifier).setStatus(vStatus);

              // Route based on verification status
              if (mounted) {
                if (vStatus == VerificationStatus.verified) {
                  context.go('/home');
                } else if (vStatus == VerificationStatus.pending) {
                  context.go('/verification-pending');
                } else {
                  context.go('/driver-verification');
                }
              }
            } else {
              // Requester
              if (mounted) context.go('/home');
            }
          } else {
            // User exists but no role set (rare edge case)
            if (mounted) context.go('/welcome');
          }
        }
      }
    } catch (e, stack) {
      debugPrint('Login Error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showManagerPasscodeDialog() {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manager Access'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter Admin Passcode',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (passController.text == 'admin123') {
                // Simple hardcoded check
                Navigator.pop(context);
                setState(() => _isManagerLogin = true);
                _handleGoogleSignIn(); // Proceed to auth
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Passcode')),
                );
              }
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Animated Illustration / Icon
              Center(
                child:
                    Container(
                          height: 180.w,
                          width: 180.w,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.directions_car_rounded, // Vehicle icon
                              size: 80.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack)
                        .shimmer(delay: 1000.ms, duration: 1500.ms),
              ),

              SizedBox(height: 40.h),

              Text(
                'Internal Ride Booking',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: 12.h),

              Text(
                'Book pickups around the campus.\nFast, reliable, and internal.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const Spacer(),

              // Google Sign In Button
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Using a generic icon if no asset available, ideally generic G icon
                            Icon(Icons.g_mobiledata, size: 32.sp),
                            SizedBox(width: 12.w),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

              SizedBox(height: 16.h),
              TextButton(
                onPressed: _showManagerPasscodeDialog,
                child: Text(
                  'Manager Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
