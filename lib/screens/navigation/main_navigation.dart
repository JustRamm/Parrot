import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/communication_hub.dart';
import '../voice_studio/voice_library.dart';
import '../profile/profile_screen.dart';
import '../../core/theme.dart';

import '../tts/tts_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CommunicationHub(),
    const TTSScreen(),
    const VoiceLibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind the navbar
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildCustomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450), // Limit width on large screens
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppTheme.logoSage.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown, // Prevents overflow on tiny screens
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, "Translate", assetPath: "assets/icons/parrot_active.png"),
                _buildNavItem(1, "Speak", assetPath: "assets/icons/speech_bubble_active.png"),
                _buildNavItem(2, "Voice", icon: LucideIcons.mic2),
                _buildNavItem(3, "Profile", icon: LucideIcons.user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, {IconData? icon, String? assetPath}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.logoSage.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetPath != null)
              Image.asset(
                assetPath,
                width: 24,
                height: 24,
                color: isSelected ? null : Colors.grey.shade400, // Tint grey if not selected (might need adjustment based on image type)
                opacity: isSelected ? const AlwaysStoppedAnimation(1.0) : const AlwaysStoppedAnimation(0.5),
              )
            else if (icon != null)
              Icon(
                icon,
                color: isSelected ? AppTheme.logoSage : Colors.grey.shade400,
                size: 24,
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: EdgeInsets.only(left: isSelected ? 8.0 : 0),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.logoSage,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
