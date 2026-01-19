import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/communication_hub.dart';
import '../voice_studio/voice_library.dart';
import '../profile/profile_screen.dart';
import '../../core/theme.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CommunicationHub(),
    const VoiceLibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppTheme.surfaceWhite,
          indicatorColor: AppTheme.logoSage.withOpacity(0.1),
          destinations: [
            NavigationDestination(
               icon: Icon(LucideIcons.messageSquare, color: AppTheme.primaryDark.withOpacity(0.4)),
              selectedIcon: Icon(LucideIcons.messageSquare, color: AppTheme.logoSage),
              label: 'Translate',
            ),
            NavigationDestination(
               icon: Icon(LucideIcons.mic2, color: AppTheme.primaryDark.withOpacity(0.4)),
              selectedIcon: Icon(LucideIcons.mic2, color: AppTheme.logoSage),
              label: 'Voice Studio',
            ),
            NavigationDestination(
               icon: Icon(LucideIcons.user, color: AppTheme.primaryDark.withOpacity(0.4)),
              selectedIcon: Icon(LucideIcons.user, color: AppTheme.logoSage),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
