import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
                        size: 80.sp,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                          'Company logistics,\nsimplified.',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.2,
                              ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: 16.h),

                    Text(
                      'Internal fleet management for the modern workforce.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontSize: 16.sp,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const Spacer(),

                    FilledButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.push('/login');
                          },
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.5, end: 0),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
