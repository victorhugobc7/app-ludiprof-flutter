/// An ordered collection of decks forming a learning path.
///
/// Roadmaps let teachers organize multiple decks into a structured
/// progression (e.g., "BNCC Fundamentals → Classroom Assessment → Inclusive Practices").
class Roadmap {
  final String id;
  final String name;
  final String description;
  final List<String> deckIds;
  final String createdBy; // 'system' or user ID
  final DateTime createdAt;

  Roadmap({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? deckIds,
    this.createdBy = 'system',
    DateTime? createdAt,
  })  : deckIds = deckIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deckIds': deckIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Roadmap.fromMap(Map<dynamic, dynamic> map) {
    return Roadmap(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      deckIds: List<String>.from(map['deckIds'] as List? ?? []),
      createdBy: map['createdBy'] as String? ?? 'system',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Roadmap copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? deckIds,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Roadmap(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deckIds: deckIds ?? List<String>.from(this.deckIds),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
