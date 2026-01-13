import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/intro_screen.dart';
import '../features/onboarding/otp_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/phone_screen.dart';

import '../features/home/home_screen.dart';
import '../features/requester/book_ride_screen.dart';
import '../features/requester/trip_status_screen.dart';
import '../features/driver/active_trip_screen.dart';
import '../shared/data/trip_provider.dart';
import '../features/driver/driver_verification_screen.dart';
import '../features/driver/verification_pending_screen.dart';
import '../features/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
      GoRoute(path: '/phone', builder: (context, state) => const PhoneScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/book-ride',
        builder: (context, state) => const BookRideScreen(),
      ),
      GoRoute(
        path: '/trip-status/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TripStatusScreen(tripId: id);
        },
      ),
      GoRoute(
        path: '/active-trip',
        builder: (context, state) {
          final trip = state.extra as Trip;
          return ActiveTripScreen(trip: trip);
        },
      ),
      GoRoute(
        path: '/driver-verification',
        builder: (context, state) => const DriverVerificationScreen(),
      ),
      GoRoute(
        path: '/verification-pending',
        builder: (context, state) => const VerificationPendingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
