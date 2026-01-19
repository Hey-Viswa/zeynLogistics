import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding/role_provider.dart';
import '../requester/requester_home_screen.dart';
import '../driver/driver_home_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildBody(role),
        ),
      ),
    );
  }

  Widget _buildBody(UserRole role) {
    switch (role) {
      case UserRole.requester:
        return const RequesterHomeScreen();
      case UserRole.driver:
        return const DriverHomeScreen();
      case UserRole.none:
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
