import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:app_ludiprof/Models/user_profile.dart';
import 'package:app_ludiprof/Services/storage_service.dart';

/// Repository for the single local [UserProfile].
///
/// The profile is stored under the Hive key `'current'` in [StorageService.userBox].
class UserRepository extends ChangeNotifier {
  static const String _currentKey = 'current';

  /// Returns the stored user profile, or `null` if none exists yet.
  UserProfile? getUser() {
    final raw = StorageService.userBox.get(_currentKey);
    if (raw == null) return null;
    return UserProfile.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  /// Whether a user profile already exists.
  bool hasUser() => StorageService.userBox.containsKey(_currentKey);

  /// Creates a new user profile with the given [displayName],
  /// generates a UUID, persists it, and marks onboarding as complete.
  Future<UserProfile> createUser(String displayName) async {
    final user = UserProfile(
      id: const Uuid().v4(),
      displayName: displayName,
    );
    await StorageService.userBox.put(_currentKey, user.toMap());
    await StorageService.markOnboarded();
    notifyListeners();
    return user;
  }

  /// Updates the existing user profile.
  Future<void> updateUser(UserProfile user) async {
    await StorageService.userBox.put(_currentKey, user.toMap());
    notifyListeners();
  }
}
