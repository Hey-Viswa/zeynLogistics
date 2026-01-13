import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../onboarding/role_provider.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Under Review',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We have received your documents. Our team typically completes verification within 24 hours.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () async {
                  // MOCK: Simulate admin approval happening instantly for demo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checking status... (Simulating Approval)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  await Future.delayed(const Duration(seconds: 2));

                  if (context.mounted) {
                    await ref
                        .read(verificationProvider.notifier)
                        .setStatus(VerificationStatus.verified);

                    // Navigate to Home (Driver)
                    // The Router might handle this automatically if we had a redirect, but for MVP explicit is fine
                    context.go('/home');
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
                child: const Text('Check Status'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Allow going back to correct docs if needed?
                  // Or Logout?
                  context.go('/welcome'); // Temporary exit
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
