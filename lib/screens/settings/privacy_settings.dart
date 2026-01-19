import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataCollection = true;
  bool _voiceDataSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Privacy & Security", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("SECURITY"),
            const SizedBox(height: 16),
            _buildActionTile(
              "Change Password",
              "Update your login credentials.",
              LucideIcons.lock,
              () {},
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              "Two-Factor Authentication",
              "Add an extra layer of security.",
              LucideIcons.shieldCheck,
              () {},
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("DATA MANAGEMENT"),
             const SizedBox(height: 16),
            _buildSwitchTile(
              "Improve Translation Accuracy",
              "Allow anonymous gesture data usage.",
              _dataCollection,
              (val) => setState(() => _dataCollection = val),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              "Share Voice Models",
              "Contribute to community voice library.",
              _voiceDataSharing,
              (val) => setState(() => _voiceDataSharing = val),
            ),
            
            const SizedBox(height: 48),
            Center(
              child: TextButton(
                onPressed: () {
                   // Delete account logic
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deletion request sent.")));
                },
                child: const Text("Delete Account Permanently", style: TextStyle(color: AppTheme.logoBerry, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.grey,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
       padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.logoSage,
          ),
        ],
      ),
    );
  }
}
