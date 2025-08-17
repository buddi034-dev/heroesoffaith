import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:herosoffaith/src/core/routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Use single controller for better performance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Initialize animations with staggered intervals
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    // Start animations immediately
    _startAnimations();
    
    // Navigate after 1.5 seconds for faster transition
    Timer(
      const Duration(milliseconds: 1500),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        }
      },
    );
  }

  void _startAnimations() {
    // Start single animation controller
    _animationController.forward();
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main title with animations
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Heroes of Faith',
                        style: GoogleFonts.cinzel(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                            Shadow(
                              offset: const Offset(0, 0),
                              blurRadius: 15,
                              color: Colors.red.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subtitle with delayed fade
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Preserving Stories of Faith',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
