import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieProgressBar extends StatefulWidget {
  final int current;
  final int total;
  final double height;

  const LottieProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.height = 24,
  });

  @override
  State<LottieProgressBar> createState() => _LottieProgressBarState();
}

class _LottieProgressBarState extends State<LottieProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _updateProgress();
  }

  @override
  void didUpdateWidget(covariant LottieProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current || oldWidget.total != widget.total) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final target = widget.total > 0 ? (widget.current / widget.total).clamp(0.0, 1.0) : 0.0;
    _controller.animateTo(target, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Lottie.asset(
        'assets/lottie/progress.json',
        controller: _controller,
        fit: BoxFit.fill,
        alignment: Alignment.center,
      ),
    );
  }
}
