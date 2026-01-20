import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _waveController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    
    // Main Entrance Animation Controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Continuous Wave Animation Controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Logo Animations
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    // Text Animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _mainController.forward();

    // Navigation delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white,
                    AppTheme.logoSage.withOpacity(0.05),
                    AppTheme.logoSage.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.logoSage.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset("assets/brand/logo.jpg"),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Text Section
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: SlideTransition(
                        position: _textSlide,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Text(
                        "Parrot",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Voice Identity Studio",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryDark.withOpacity(0.6),
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),

                // Custom Loading Wave Animation
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value, // Fade in with text
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(200, 40),
                        painter: WavePainter(
                          animationValue: _waveController.value,
                          color: AppTheme.logoSage,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Disclaimer/Copyright
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: child,
                );
              },
              child: const Text(
                "Powered by ABIRAM, KARTHIK, GAUTHAM & GOKUL",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final yMid = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      // Create a complex wave effect using multiple sine waves
      // The wave travels via (x - animationValue * width)
      
      // Main carrying wave
      double y = math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 8;
      
      // Secondary dampening based on distance from center for "voice" look
      double dampener = 1.0 - (2 * (x - size.width / 2) / size.width).abs();
      y *= dampener;

      if (x == 0) {
        path.moveTo(x, yMid + y);
      } else {
        path.lineTo(x, yMid + y);
      }
    }
    
    // Draw a second ghost wave for depth
    final ghostPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    final ghostPath = Path();
    for (double x = 0; x <= size.width; x++) {
      double y = math.cos((x / size.width * 3 * math.pi) - (animationValue * 2 * math.pi)) * 6;
      double dampener = 1.0 - (2 * (x - size.width / 2) / size.width).abs();
      y *= dampener;
      
      if (x == 0) {
        ghostPath.moveTo(x, yMid + y);
      } else {
        ghostPath.lineTo(x, yMid + y);
      }
    }

    canvas.drawPath(ghostPath, ghostPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
