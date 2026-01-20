import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
            _buildSection("1. Information We Collect", 
              "We collect audio recordings you provide for voice cloning and camera input for real-time gesture translation. This data is used solely to provide the application's core functionality."),
            _buildSection("2. How We Use Data", 
              "Audio samples are used to generate a unique vocal embedding. Camera data is processed in real-time on your device or our secure backend and is not stored permanently."),
            _buildSection("3. Data Security", 
              "We implement industry-standard security measures to protect your data. Vocal embeddings are encrypted and stored in protected environments."),
            _buildSection("4. Third-Party Services", 
              "We may use third-party AI models and hosting services to facilitate voice synthesis and processing. These partners are required to maintain strict data confidentiality."),
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
