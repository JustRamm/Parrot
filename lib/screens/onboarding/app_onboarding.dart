import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class AppOnboardingScreen extends StatefulWidget {
  const AppOnboardingScreen({super.key});

  @override
  State<AppOnboardingScreen> createState() => _AppOnboardingScreenState();
}

class _AppOnboardingScreenState extends State<AppOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Express Naturally",
      description: "EchoSign uses advanced Sign Language Recognition to bridge the communication gap in real-time.",
      icon: LucideIcons.hand,
    ),
    OnboardingData(
      title: "Personalized Voice",
      description: "Don't settle for robotic voices. Clone your own voice or a loved one's to maintain your unique identity.",
      icon: LucideIcons.mic2,
    ),
    OnboardingData(
      title: "Feel the Emotion",
      description: "Our AI detects the intensity of your movements to inject genuine emotion into your speech output.",
      icon: LucideIcons.heart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppTheme.logoRose.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _pages[index].icon,
                        size: 80,
                        color: AppTheme.logoRose,
                      ),
                    ),
                    const SizedBox(height: 64),
                    Text(
                      _pages[index].title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _pages[index].description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.primaryDark.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppTheme.logoRose : AppTheme.logoRose.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      context.go('/auth');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? "Get Started" : "Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({required this.title, required this.description, required this.icon});
}
