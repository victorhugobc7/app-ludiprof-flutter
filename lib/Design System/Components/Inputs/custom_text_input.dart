import 'package:flutter/material.dart';
import 'package:app_ludiprof/Design System/Shared/typography.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const CustomTextInput({
    super.key,
    required this.controller,
    this.placeholder = '',
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
