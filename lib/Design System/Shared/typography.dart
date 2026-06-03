import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';

/// Centralized text styles for the LudiProf app.
///
/// All styles use [AppColors] for consistency and reference
/// a single source of truth for font sizes, weights, and colors.
class AppTypography {
  AppTypography._();

  // ── Headings ──────────────────────────────────────────────

  static final TextStyle heading1 = GoogleFonts.mulish(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading2 = GoogleFonts.mulish(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading3 = GoogleFonts.mulish(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ──────────────────────────────────────────────────

  static final TextStyle body = GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodySmall = GoogleFonts.mulish(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ── Caption / Button ──────────────────────────────────────

  static final TextStyle caption = GoogleFonts.mulish(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static final TextStyle button = GoogleFonts.mulish(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ── Flashcard-specific ────────────────────────────────────

  static final TextStyle cardQuestion = GoogleFonts.mulish(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle cardAnswer = GoogleFonts.mulish(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.primary,
  );
}
