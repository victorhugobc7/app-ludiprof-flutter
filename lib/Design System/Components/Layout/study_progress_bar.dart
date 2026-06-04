import 'package:flutter/material.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';

/// A slim, animated progress bar for study sessions.
///
/// Shows current progress as a fraction of total items.
/// Animates smoothly between values.
class StudyProgressBar extends StatelessWidget {
  /// Current step (0-based index of the item being studied).
  final int current;

  /// Total number of items in the session.
  final int total;

  /// Height of the bar. Defaults to 6.
  final double height;

  /// Background color of the track.
  final Color? trackColor;

  /// Fill color of the progress indicator.
  final Color? fillColor;

  /// Border radius of the bar.
  final double borderRadius;

  const StudyProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.height = 6,
    this.trackColor,
    this.fillColor,
    this.borderRadius = 100,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor ?? Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * fraction,
                height: height,
                decoration: BoxDecoration(
                  color: fillColor ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
