import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../shared/theme/app_theme.dart';
import '../shared/theme/theme_provider.dart';
import '../shared/widgets/connectivity_wrapper.dart';
import 'router.dart';
// import 'firebase_options.dart'; // TODO: Uncomment when firebase_options.dart is generated

class LogistixApp extends ConsumerWidget {
  const LogistixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Logistix App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: router,
          builder: (context, child) {
            return ConnectivityWrapper(child: child!);
          },
        );
      },
    );
  }
}
