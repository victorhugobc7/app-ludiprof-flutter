import 'package:flutter/material.dart';
import 'package:app_ludiprof/Scenes/flashcard/flashcard_view.dart';
import 'package:app_ludiprof/Scenes/main_tab/main_tab_view.dart';
import 'package:app_ludiprof/Scenes/onboarding/onboarding_view.dart';
import 'package:app_ludiprof/Scenes/creator/card_creator_view.dart';
import 'package:app_ludiprof/Scenes/creator/deck_creator_view.dart';
import 'package:app_ludiprof/Scenes/creator/roadmap_creator_view.dart';
import 'package:app_ludiprof/Scenes/dashboard/dashboard_view.dart';
import 'package:app_ludiprof/Scenes/profile/profile_view.dart';
import 'package:app_ludiprof/Scenes/creator/integrated_flow_view.dart';

class AppCoordinator {
  static final AppCoordinator _instance = AppCoordinator._internal();
  factory AppCoordinator() => _instance;
  AppCoordinator._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void goBack() {
    navigatorKey.currentState?.pop();
  }

  void goToHome() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainTabView()),
      (_) => false,
    );
  }

  void goToOnboarding() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const OnboardingView()),
      (_) => false,
    );
  }

  void goToFlashcards(String deckId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => FlashcardView(deckId: deckId)),
    );
  }

  void goToCardCreator() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const CardCreatorView()),
    );
  }

  void goToDeckCreator() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const DeckCreatorView()),
    );
  }

  void goToIntegratedFlow() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const IntegratedFlowView()),
    );
  }

  void goToRoadmapCreator() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const RoadmapCreatorView()),
    );
  }

  void goToDashboard() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const DashboardView()),
    );
  }

  void goToProfile() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const ProfileView()),
    );
  }
}
