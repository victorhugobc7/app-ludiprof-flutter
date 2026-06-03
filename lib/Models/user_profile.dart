/// Local teacher profile — no authentication required.
///
/// Created on first launch during onboarding. Stores only
/// a display name and creation date (no PII beyond the name).
class UserProfile {
  final String id;
  final String displayName;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.displayName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
