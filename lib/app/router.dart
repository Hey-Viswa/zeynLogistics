import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/intro_screen.dart';
import '../features/onboarding/login_screen.dart';
// import '../features/onboarding/otp_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/role_selection_screen.dart';
// import '../features/onboarding/phone_screen.dart';

import '../features/home/home_screen.dart';
import '../features/requester/book_ride_screen.dart';
import '../features/requester/trip_status_screen.dart';
import '../features/driver/active_trip_screen.dart';
import '../shared/data/trip_provider.dart';
import '../features/driver/driver_verification_screen.dart';
import '../features/driver/verification_pending_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/saved_places_screen.dart';
import '../shared/data/user_model.dart';
import '../features/manager/manager_home_screen.dart';
import '../features/manager/driver_detail_screen.dart';
import '../features/chat/chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildPage(const SplashScreen()),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (context, state) => _buildPage(const IntroScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPage(const LoginScreen()),
      ),
      // GoRoute(
      //   path: '/otp',
      //   pageBuilder: (context, state) {
      //     final phone = state.extra as String? ?? '';
      //     return _buildPage(OtpScreen(phoneNumber: phone));
      //   },
      // ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => _buildPage(const WelcomeScreen()),
      ),
      GoRoute(
        path: '/role-selection',
        pageBuilder: (context, state) =>
            _buildPage(const RoleSelectionScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _buildPage(const HomeScreen()),
      ),
      GoRoute(
        path: '/book-ride',
        pageBuilder: (context, state) => _buildPage(const BookRideScreen()),
      ),
      GoRoute(
        path: '/trip-status/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPage(TripStatusScreen(tripId: id));
        },
      ),
      GoRoute(
        path: '/active-trip',
        pageBuilder: (context, state) {
          final trip = state.extra as Trip;
          return _buildPage(ActiveTripScreen(trip: trip));
        },
      ),
      GoRoute(
        path: '/driver-verification',
        pageBuilder: (context, state) =>
            _buildPage(const DriverVerificationScreen()),
      ),
      GoRoute(
        path: '/verification-pending',
        pageBuilder: (context, state) =>
            _buildPage(const VerificationPendingScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildPage(const ProfileScreen()),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) {
          final user = state.extra as UserModel;
          return _buildPage(EditProfileScreen(user: user));
        },
      ),
      GoRoute(
        path: '/saved-places',
        pageBuilder: (context, state) {
          final user = state.extra as UserModel;
          return _buildPage(SavedPlacesScreen(user: user));
        },
      ),
      GoRoute(
        path: '/manager-home',
        pageBuilder: (context, state) => _buildPage(const ManagerHomeScreen()),
      ),
      GoRoute(
        path: '/driver-detail/:id',
        pageBuilder: (context, state) {
          final driver = state.extra as UserModel;
          // In a real app we might fetch by ID if extra is null,
          // but for now we rely on passing the object.
          return _buildPage(DriverDetailScreen(driver: driver));
        },
      ),
      GoRoute(
        path: '/chat/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPage(ChatScreen(chatId: id));
        },
      ),
    ],
  );
});

CustomTransitionPage _buildPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.05, 0.0); // Subtle slide
      const end = Offset.zero;
      const curve = Curves.easeInOutCubicEmphasized;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var fadeAnimation = CurvedAnimation(parent: animation, curve: curve);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
