import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/local_storage_repository.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/questionnaire/screens/questionnaire_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
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

    return MaterialApp(
      title: 'DryCare – Dry Skin Face Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppRouter(),
    );
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
