import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Opacity and Scale)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // 2. Floating Animation (The "y: [0, -8, 0]" effect)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController.forward();

    // 3. Navigation Timer (2200ms)
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        // Replace with your actual login route
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient background matching Tailwind's sky-100 via-white to-teal-50
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F2FE), // sky-100
              Colors.white,
              Color(0xFFF0FDFA), // teal-50
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeController,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon Container
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -8 * _floatController.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.teal], // primary to accent
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop, // Droplets icon
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Text Content
                const Text(
                  'AquaPay',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Text(
                  'Smart Water Utility Payments',
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
                const SizedBox(height: 32),
                // Loading Dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) => _LoadingDot(index: index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for the pulsing dots at the bottom
class _LoadingDot extends StatefulWidget {
  final int index;
  const _LoadingDot({required this.index});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Staggered start based on index
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _dotController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_dotController),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
