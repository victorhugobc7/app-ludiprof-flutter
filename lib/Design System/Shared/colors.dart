import 'package:flutter/material.dart';
import 'package:app_ludiprof/Models/card_type.dart';

/// Centralized color palette for the LudiProf app.
///
/// All colors are defined as static constants for consistency
/// across the entire design system.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF9FD9FF);
  static const Color primaryDark = Color(0xFF72BAEA);
  static const Color primaryLight = Color(0xFFC7E9FF);

  static const Color accent = Color(0xFFFFC107);
  static const Color accentDark = Color(0xFFFFA000);

  // ── Surfaces ─────────────────────────────────────────────
  static const Color background = Color(0xFFEBF7FF);
  static const Color surface = Colors.white;

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF343737);
  static const Color textSecondary = Color(0xFF757575);

  // ── Card-type specific ────────────────────────────────────
  /// Blue — Conceito (knowledge acquisition)
  static const Color conceito = Color(0xFF42A5F5);

  /// Orange — Cenário de Problema (situational analysis)
  static const Color cenarioProblema = Color(0xFFFF7043);

  /// Green — Ação Prática (kinesthetic task)
  static const Color acaoPratica = Color(0xFF66BB6A);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  // ── Helpers ───────────────────────────────────────────────

  /// Returns the accent color associated with the given [CardType].
  static Color forCardType(CardType type) {
    switch (type) {
      case CardType.conceito:
        return conceito;
      case CardType.cenarioProblema:
        return cenarioProblema;
      case CardType.acaoPratica:
        return acaoPratica;
    }
  }
}
