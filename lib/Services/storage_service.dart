import 'package:hive_flutter/hive_flutter.dart';

/// Centralized Hive initialization and box management.
///
/// Call [initialize] in `main()` before `runApp()`.
/// All data is stored as Maps for simplicity (no TypeAdapters needed).
class StorageService {
  static const String cardsBoxName = 'cards';
  static const String decksBoxName = 'decks';
  static const String roadmapsBoxName = 'roadmaps';
  static const String userBoxName = 'user';
  static const String sessionsBoxName = 'sessions';
  static const String appStateBoxName = 'app_state';
  static const String gamificationBoxName = 'gamification';

  static late Box cardsBox;
  static late Box decksBox;
  static late Box roadmapsBox;
  static late Box userBox;
  static late Box sessionsBox;
  static late Box appStateBox;
  static late Box gamificationBox;

  /// Initializes Hive and opens all required boxes.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    cardsBox = await Hive.openBox(cardsBoxName);
    decksBox = await Hive.openBox(decksBoxName);
    roadmapsBox = await Hive.openBox(roadmapsBoxName);
    userBox = await Hive.openBox(userBoxName);
    sessionsBox = await Hive.openBox(sessionsBoxName);
    appStateBox = await Hive.openBox(appStateBoxName);
    gamificationBox = await Hive.openBox(gamificationBoxName);
  }

  /// Whether initial seed data has been loaded.
  static bool get isSeeded => appStateBox.get('isSeeded', defaultValue: false);
  static Future<void> markSeeded() => appStateBox.put('isSeeded', true);

  /// Whether onboarding has been completed.
  static bool get isOnboarded =>
      appStateBox.get('isOnboarded', defaultValue: false);
  static Future<void> markOnboarded() => appStateBox.put('isOnboarded', true);
}
