import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    _controller.forward();

    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundClean,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryDark.withOpacity(0.05),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset("assets/brand/logo.jpg"),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      "EchoSign",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 34,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Voice Identity Studio",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryDark.withOpacity(0.6),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
