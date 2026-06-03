import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_ludiprof/Design System/Shared/colors.dart';
import 'package:app_ludiprof/Services/storage_service.dart';
import 'package:app_ludiprof/Services/card_repository.dart';
import 'package:app_ludiprof/Services/deck_repository.dart';
import 'package:app_ludiprof/Services/user_repository.dart';
import 'package:app_ludiprof/Services/analytics_service.dart';
import 'package:app_ludiprof/Services/gamification_service.dart';
import 'package:app_ludiprof/Services/notification_service.dart';
import 'package:app_ludiprof/Scenes/home/home_view.dart';
import 'package:app_ludiprof/Scenes/onboarding/onboarding_view.dart';
import 'app_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await StorageService.initialize();

  // Initialize custom gamification service
  final gamificationService = GamificationService();
  
  // Initialize Notification service
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardRepository()),
        ChangeNotifierProvider(create: (_) => DeckRepository()),
        ChangeNotifierProvider(create: (_) => UserRepository()),
        ChangeNotifierProvider(create: (_) => AnalyticsService()),
        ChangeNotifierProvider.value(value: gamificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine initial screen based on onboarding status
    final bool isOnboarded = StorageService.isOnboarded;

    return ShadApp(
      title: 'LudiProf',
      navigatorKey: AppCoordinator().navigatorKey,
      materialThemeBuilder: (context, theme) {
        return theme.copyWith(
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.mulishTextTheme(theme.textTheme),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        );
      },
      home: isOnboarded ? const HomeView() : const OnboardingView(),
    );
  }
}
