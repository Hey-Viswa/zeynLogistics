import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/phone_screen.dart';
import '../features/onboarding/country_screen.dart';
import '../features/onboarding/verify_method_screen.dart';
import '../features/home/home_screen.dart';
import '../features/requester/book_ride_screen.dart';
import '../features/driver/active_trip_screen.dart';
import '../shared/data/trip_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/phone', builder: (context, state) => const PhoneScreen()),
      GoRoute(
        path: '/country',
        builder: (context, state) => const CountryScreen(),
      ),
      GoRoute(
        path: '/verify-method',
        builder: (context, state) => const VerifyMethodScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/book-ride',
        builder: (context, state) => const BookRideScreen(),
      ),
      GoRoute(
        path: '/active-trip',
        builder: (context, state) {
          final trip = state.extra as Trip;
          return ActiveTripScreen(trip: trip);
        },
      ),
    ],
  );
});
