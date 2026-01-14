import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../onboarding/role_provider.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top,
                  size: 80.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Application Under Review',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'We have received your documents. Our team typically completes verification within 24 hours.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16.sp,
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
                style: FilledButton.styleFrom(padding: EdgeInsets.all(18.w)),
                child: Text('Check Status', style: TextStyle(fontSize: 18.sp)),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  // Allow going back to correct docs if needed?
                  // Or Logout?
                  context.go('/welcome'); // Temporary exit
                },
                child: Text('Back to Home', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
