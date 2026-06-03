/// A collection of flashcards forming a study unit.
class Deck {
  final String id;
  final String name;
  final String description;
  final List<String> cardIds;
  final String createdBy; // 'system' or user ID
  final DateTime createdAt;

  Deck({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? cardIds,
    this.createdBy = 'system',
    DateTime? createdAt,
  })  : cardIds = cardIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cardIds': cardIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Deck.fromMap(Map<dynamic, dynamic> map) {
    return Deck(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      cardIds: List<String>.from(map['cardIds'] as List? ?? []),
      createdBy: map['createdBy'] as String? ?? 'system',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Deck copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? cardIds,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cardIds: cardIds ?? List<String>.from(this.cardIds),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
