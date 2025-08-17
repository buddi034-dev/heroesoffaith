import 'package:flutter/material.dart';

class AnimatedCardBackground extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const AnimatedCardBackground({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<AnimatedCardBackground> createState() => _AnimatedCardBackgroundState();
}

class _AnimatedCardBackgroundState extends State<AnimatedCardBackground>
    with TickerProviderStateMixin {
  late AnimationController _movementController;
  late AnimationController _flashController;
  late AnimationController _lightController;

  @override
  void initState() {
    super.initState();
    _movementController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _flashController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _lightController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _movementController.dispose();
    _flashController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_movementController, _flashController, _lightController]),
      builder: (context, child) {
        return CustomPaint(
          painter: MovingSquaresPainter(
            _movementController.value,
            _flashController.value,
            _lightController.value,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class MovingSquaresPainter extends CustomPainter {
  final double movementValue;
  final double flashValue;
  final double lightValue;

  MovingSquaresPainter(this.movementValue, this.flashValue, this.lightValue);

  @override
  void paint(Canvas canvas, Size size) {
    // No border or animation - clean card design
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}