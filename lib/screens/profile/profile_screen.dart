import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../settings/emotion_config_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmotionConfigScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Profile Header
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.logoSage.withOpacity(0.1),
                      border: Border.all(color: AppTheme.logoSage.withOpacity(0.2), width: 4),
                    ),
                    child: const Icon(LucideIcons.user, size: 60, color: AppTheme.logoSage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.logoSage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.camera, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "John Doe",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            ),
            const Text(
              "Pro Member",
              style: TextStyle(fontSize: 14, color: AppTheme.logoSage, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("Translations", "1.2k"),
                  _buildStatItem("Accuracy", "98%"),
                  _buildStatItem("Voices", "4"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Menu Items
            _buildMenuItem(context, LucideIcons.bookOpen, "Gesture Library", onTap: () => context.push('/learning')),
            _buildMenuItem(context, LucideIcons.userCheck, "Account Details", onTap: () => context.push('/account-settings')),
            _buildMenuItem(context, LucideIcons.history, "Translation History", onTap: () => context.push('/history')),
            _buildMenuItem(context, LucideIcons.globe, "Language & Region", onTap: () => context.push('/settings/language')),
            _buildMenuItem(context, LucideIcons.eye, "Accessibility", onTap: () => context.push('/settings/accessibility')),
            _buildMenuItem(context, LucideIcons.lock, "Privacy & Security", onTap: () => context.push('/settings/privacy')),
             _buildMenuItem(context, LucideIcons.creditCard, "Subscription", onTap: () => context.push('/subscription')),
             _buildMenuItem(context, LucideIcons.helpCircle, "Help & Support", onTap: () => context.push('/settings/help')),
            
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Navigate back to auth screen on logout
                    context.go('/auth');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.logoRose,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.logoRose.withOpacity(0.2)),
                    ),
                  ),
                  child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryDark.withOpacity(0.7)),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
              const Spacer(),
              Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
