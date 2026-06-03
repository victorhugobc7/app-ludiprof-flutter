/// Three flashcard types as defined by the functional requirements.
///
/// - [conceito] — Theoretical concept card (knowledge acquisition)
/// - [cenarioProblema] — Problem scenario card (situational analysis)
/// - [acaoPratica] — Practical action card (kinesthetic task, can be marked "concluída")
enum CardType {
  conceito,
  cenarioProblema,
  acaoPratica;

  String get label {
    switch (this) {
      case CardType.conceito:
        return 'Conceito';
      case CardType.cenarioProblema:
        return 'Cenário de Problema';
      case CardType.acaoPratica:
        return 'Ação Prática';
    }
  }

  String get emoji {
    switch (this) {
      case CardType.conceito:
        return '🧠';
      case CardType.cenarioProblema:
        return '🎯';
      case CardType.acaoPratica:
        return '🛠️';
    }
  }

  String get jsonKey {
    switch (this) {
      case CardType.conceito:
        return 'conceito';
      case CardType.cenarioProblema:
        return 'cenario_problema';
      case CardType.acaoPratica:
        return 'acao_pratica';
    }
  }

  static CardType fromJson(String value) {
    switch (value) {
      case 'conceito':
        return CardType.conceito;
      case 'cenario_problema':
        return CardType.cenarioProblema;
      case 'acao_pratica':
        return CardType.acaoPratica;
      default:
        return CardType.conceito;
    }
  }
}
