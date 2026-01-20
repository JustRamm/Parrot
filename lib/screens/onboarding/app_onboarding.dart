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
      title: "Speak with Your Hands",
      description: "Parrot translates your sign language into speech instantly, bridging the gap in real-time communication.",
      icon: LucideIcons.hand,
    ),
    OnboardingData(
      title: "Your Voice, Your Identity",
      description: "Create a personalized AI voice clone that sounds just like you, removing the robotic barrier.",
      icon: LucideIcons.mic2,
    ),
    OnboardingData(
      title: "Voice Messenger",
      description: "Type to speak instantly using our built-in Text-to-Speech messenger for quick interactions.",
      icon: LucideIcons.messageSquare,
    ),
    OnboardingData(
      title: "Express Every Emotion",
      description: "Our AI understands the intensity of your gestures to deliver your message with the right emotional tone.",
      icon: LucideIcons.heart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    AppTheme.logoSage.withOpacity(0.05 + (_currentPage * 0.02)),
                    AppTheme.logoSage.withOpacity(0.1 + (_currentPage * 0.03)),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingContent(
                        data: _pages[index],
                        isActive: _currentPage == index,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
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
                              width: _currentPage == index ? 32 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index ? AppTheme.logoSage : AppTheme.logoSage.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage == _pages.length - 1) {
                                context.go('/auth');
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutQuart,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryDark,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppTheme.logoSage.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1 ? "Get Started" : "Continue",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.arrowRight, size: 20),
                              ],
                            ),
                          ),
                        ),
                        if (_currentPage != _pages.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextButton(
                              onPressed: () => context.go('/auth'),
                              child: Text(
                                "Skip",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  final bool isActive;

  const OnboardingContent({super.key, required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            height: isActive ? 200 : 180,
            width: isActive ? 200 : 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.logoSage.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: isActive ? 10 : 0,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                data.icon,
                size: 80,
                color: AppTheme.logoSage,
              ),
            ),
          ),
          const SizedBox(height: 64),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isActive ? 1.0 : 0.5,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryDark,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isActive ? 1.0 : 0.0,
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryDark.withOpacity(0.6),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
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
