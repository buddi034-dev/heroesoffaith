import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedAvatar extends StatefulWidget {
  final User? user;
  final String userName;
  final double radius;
  final Color backgroundColor;
  final TextStyle? textStyle;

  const AnimatedAvatar({
    super.key,
    required this.user,
    required this.userName,
    this.radius = 22,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.textStyle,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8), // Slower rotation
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return CustomPaint(
          painter: MultiColorCircularPainter(_rotationController.value),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: widget.backgroundColor,
              backgroundImage: widget.user?.photoURL != null
                  ? NetworkImage(widget.user!.photoURL!)
                  : null,
              child: widget.user?.photoURL == null
                  ? Text(
                      widget.userName.isNotEmpty 
                          ? widget.userName[0].toUpperCase() 
                          : 'U',
                      style: widget.textStyle ??
                          GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class MultiColorCircularPainter extends CustomPainter {
  final double rotationValue;

  MultiColorCircularPainter(this.rotationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Create rotating gradient
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFf093fb),
      const Color(0xFFf5576c),
      const Color(0xFF43A047),
      const Color(0xFFFF7043),
    ];

    // Create sweep gradient that rotates
    final gradient = SweepGradient(
      colors: colors + [colors.first], // Add first color at end for smooth loop
      stops: List.generate(colors.length + 1, (i) => i / colors.length),
      transform: GradientRotation(rotationValue * 2 * pi),
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw the animated circular border
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}