import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("1. Acceptance of Terms", 
              "By accessing and using Parrot, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the application."),
            _buildSection("2. User Identity & Voice Cloning", 
              "The voice cloning feature requires you to provide audio samples. You agree that you have the right to use these samples and that they refer to your own voice or someone who has given you express permission."),
            _buildSection("3. Use of AI Technology", 
              "Parrot uses advanced AI for gesture recognition and voice synthesis. While we strive for accuracy, the application is provided 'as is' and should not be relied upon for critical medical or emergency communication."),
            _buildSection("4. Privacy & Data", 
              "We take your privacy seriously. Audio samples used for voice cloning are processed and stored securely. Please refer to our Privacy Policy for more details."),
            const SizedBox(height: 48),
            Center(
              child: Text(
                "Last Updated: January 2026",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryDark)),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(color: Colors.grey.shade700, height: 1.6)),
        ],
      ),
    );
  }
}
