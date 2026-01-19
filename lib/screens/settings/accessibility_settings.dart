import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  double _fontSize = 1.0;
  bool _highContrast = false;
  bool _screenReader = false;
  bool _reduceMotion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Accessibility", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("DISPLAY"),
            const SizedBox(height: 16),
            _buildSliderTile(
              "Text Size",
              "Adjust the font size for better readability.",
              _fontSize,
              0.5,
              2.0,
              (val) => setState(() => _fontSize = val),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              "High Contrast Mode",
              "Increase contrast for easier viewing.",
              _highContrast,
              (val) => setState(() => _highContrast = val),
              LucideIcons.contrast,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader("INTERACTION"),
            const SizedBox(height: 16),
             _buildSwitchTile(
              "Screen Reader Support",
              "Optimize UI for TalkBack/VoiceOver.",
              _screenReader,
              (val) => setState(() => _screenReader = val),
              LucideIcons.cpu, // Using CPU as a proxy for 'tech' icon
            ),
            const SizedBox(height: 16),
             _buildSwitchTile(
              "Reduce Motion",
              "Minimize animations and transitions.",
              _reduceMotion,
              (val) => setState(() => _reduceMotion = val),
              LucideIcons.stopCircle,
            ),
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

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) {
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
          Icon(icon, color: AppTheme.primaryDark),
          const SizedBox(width: 16),
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

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, ValueChanged<double> onChanged) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.type, color: AppTheme.primaryDark),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("A", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  activeColor: AppTheme.logoSage,
                  inactiveColor: AppTheme.logoSage.withOpacity(0.2),
                  onChanged: onChanged,
                ),
              ),
              const Text("A", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
