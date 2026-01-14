import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/theme/theme_provider.dart'; // Ensure these imports exist or adjust
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/data/user_model.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Use if available, else generic icon

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;

        // Check if user exists in Firestore
        final userRepo = ref.read(userRepositoryProvider);
        final exists = await userRepo.userExists(user.uid);

        if (!exists) {
          // Create new user profile
          final newUser = UserModel(
            id: user.uid,
            phoneNumber: user.phoneNumber ?? '', // Might be null with Google
            email: user.email,
            name: user.displayName,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
          );
          await userRepo.createUser(newUser);

          if (mounted) context.go('/welcome'); // Role Selection
        } else {
          // Existing user - Check role to route properly
          final userData = await userRepo.getUser(user.uid);
          if (userData?.role != null) {
            if (mounted) context.go('/home');
          } else {
            if (mounted) context.go('/welcome');
          }
        }
      }
    } catch (e) {
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
