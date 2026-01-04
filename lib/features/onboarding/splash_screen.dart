import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await Future.delayed(const Duration(seconds: 1)); // 1 sec delay
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;

    if (mounted) {
      if (seen) {
        context.go('/phone');
      } else {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CE5B1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 8),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'zeyn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
