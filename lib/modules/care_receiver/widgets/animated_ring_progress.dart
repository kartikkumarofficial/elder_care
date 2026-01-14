import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedRingProgress extends StatefulWidget {
  final double value; // 0.0 → 1.0
  final Color color;
  final double size;
  final double strokeWidth;
  final Duration duration;

  const AnimatedRingProgress({
    super.key,
    required this.value,
    required this.color,
    this.size = 84,
    this.strokeWidth = 7,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedRingProgress> createState() =>
      _AnimatedRingProgressState();
}

class _AnimatedRingProgressState extends State<AnimatedRingProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);

    _animate(from: 0, to: widget.value);
  }

  @override
  void didUpdateWidget(covariant AnimatedRingProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animate(from: _oldValue, to: widget.value);
    }
  }

  void _animate({required double from, required double to}) {
    _controller.reset();
    _animation = Tween(begin: from, end: to).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _oldValue = to;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              /// BACKGROUND RING (remaining)
              CustomPaint(
                size: Size.square(widget.size),
                painter: _CirclePainter(
                  color: Colors.grey.shade300,
                  strokeWidth: widget.strokeWidth,
                  progress: 1,
                ),
              ),

              /// FOREGROUND PROGRESS
              CustomPaint(
                size: Size.square(widget.size),
                painter: _CirclePainter(
                  color: widget.color,
                  strokeWidth: widget.strokeWidth,
                  progress: _animation.value,
                ),
              ),

              /// TEXT
              Text(
                "${(_animation.value * 100).round()}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.color != color;
}
