import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/local_storage_repository.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/questionnaire/screens/questionnaire_screen.dart';
import 'features/splash/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize local storage
  final repo = LocalStorageRepository();
  await repo.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(repo),
      ],
      child: const DryCareApp(),
    ),
  );
}

class DryCareApp extends ConsumerWidget {
  const DryCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Dynamically set status bar icons based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'DryCare – Dry Skin Face Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashWrapper(),
    );
  }
}

class SplashWrapper extends ConsumerWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SplashScreen(nextScreen: const AppRouter());
  }
}

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingCompletedProvider);
    final questionnaireDone = ref.watch(questionnaireCompletedProvider);

    if (!onboardingDone) {
      return const OnboardingScreen();
    }
    if (!questionnaireDone) {
      return const QuestionnaireScreen();
    }
    return const DashboardScreen();
  }
}
