import 'package:flutter/material.dart';
import 'package:app_ludiprof/Models/card_type.dart';

/// A small colored badge showing a card type's emoji and label.
///
/// Used in flashcard views, deck lists, and card creators to visually
/// distinguish between Conceito, Cenário de Problema, and Ação Prática cards.
class CardTypeBadge extends StatelessWidget {
  final CardType cardType;
  final bool compact;

  const CardTypeBadge({
    super.key,
    required this.cardType,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (cardType) {
      case CardType.conceito:
        return const Color(0xFFE3F2FD); // light blue
      case CardType.cenarioProblema:
        return const Color(0xFFFFF3E0); // light orange
      case CardType.acaoPratica:
        return const Color(0xFFE8F5E9); // light green
    }
  }

  Color get _textColor {
    switch (cardType) {
      case CardType.conceito:
        return const Color(0xFF1565C0); // blue
      case CardType.cenarioProblema:
        return const Color(0xFFE65100); // orange
      case CardType.acaoPratica:
        return const Color(0xFF2E7D32); // green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cardType.emoji,
            style: TextStyle(fontSize: compact ? 12 : 14),
          ),
          const SizedBox(width: 4),
          Text(
            cardType.label,
            style: TextStyle(
              color: _textColor,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
