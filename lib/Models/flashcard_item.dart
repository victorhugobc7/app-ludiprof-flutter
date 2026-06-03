import 'card_type.dart';

/// Enhanced flashcard model supporting three card types, persistence,
/// and practical task completion tracking.
class FlashcardItem {
  final String id;
  final String question;
  final String answer;
  final CardType cardType;
  final String deckId;
  final String createdBy; // 'system' or user ID
  bool isTaskCompleted; // For acaoPratica cards
  Map<String, dynamic> fsrsData; // Serialized FSRS state
  final DateTime createdAt;

  FlashcardItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.cardType,
    required this.deckId,
    this.createdBy = 'system',
    this.isTaskCompleted = false,
    Map<String, dynamic>? fsrsData,
    DateTime? createdAt,
  })  : fsrsData = fsrsData ?? {},
        createdAt = createdAt ?? DateTime.now();

  /// Whether this is a practical action card that can be marked as completed.
  bool get isPracticalAction => cardType == CardType.acaoPratica;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'cardType': cardType.jsonKey,
      'deckId': deckId,
      'createdBy': createdBy,
      'isTaskCompleted': isTaskCompleted,
      'fsrsData': fsrsData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FlashcardItem.fromMap(Map<dynamic, dynamic> map) {
    return FlashcardItem(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      cardType: CardType.fromJson(map['cardType'] as String? ?? 'conceito'),
      deckId: map['deckId'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? 'system',
      isTaskCompleted: map['isTaskCompleted'] as bool? ?? false,
      fsrsData: Map<String, dynamic>.from(map['fsrsData'] as Map? ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  FlashcardItem copyWith({
    String? id,
    String? question,
    String? answer,
    CardType? cardType,
    String? deckId,
    String? createdBy,
    bool? isTaskCompleted,
    Map<String, dynamic>? fsrsData,
    DateTime? createdAt,
  }) {
    return FlashcardItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      cardType: cardType ?? this.cardType,
      deckId: deckId ?? this.deckId,
      createdBy: createdBy ?? this.createdBy,
      isTaskCompleted: isTaskCompleted ?? this.isTaskCompleted,
      fsrsData: fsrsData ?? Map<String, dynamic>.from(this.fsrsData),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
