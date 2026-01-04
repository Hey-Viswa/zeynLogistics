import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/phone_screen.dart';
import '../features/onboarding/country_screen.dart';
import '../features/onboarding/verify_method_screen.dart';
import '../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
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
    ],
  );
});
