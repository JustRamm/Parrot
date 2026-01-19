import 'package:flutter/material.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isAnimating;
  final Color color;

  const WaveformVisualizer({
    super.key,
    required this.isAnimating,
    this.color = const Color(0xFF698F79), // Default Sage
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          15,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            width: 3,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(15, (index) {
            double height = 4 + (20 * (0.5 + 0.5 * (index % 3 == 0 ? _controller.value : (1 - _controller.value))));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: height,
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [widget.color, widget.color.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
