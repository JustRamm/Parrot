import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/app_state.dart';
import '../../core/theme.dart';

class EmotionConfigScreen extends StatelessWidget {
  const EmotionConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensitivity Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Gesture Map", LucideIcons.move),
            const SizedBox(height: 24),
            ValueListenableBuilder<double>(
              valueListenable: AppState.gestureSensitivity,
              builder: (context, val, _) => Column(
                children: [
                  _buildSliderLabel("Gesture Speed Sensitivity", val),
                  Slider(value: val, onChanged: (newVal) => AppState.gestureSensitivity.value = newVal),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Slow/Steady", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("Fast/Aggressive", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader("Audio Output", LucideIcons.volumeX),
            const SizedBox(height: 24),
            ValueListenableBuilder<double>(
              valueListenable: AppState.volumeIntensity,
              builder: (context, val, _) => Column(
                children: [
                  _buildSliderLabel("Volume Intensity", val),
                  Slider(value: val, onChanged: (newVal) => AppState.volumeIntensity.value = newVal),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader("Voice Identity", LucideIcons.userCheck),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: AppState.identityMode,
              builder: (context, val, _) => SwitchListTile(
                title: const Text("Identity-Preserving Mode", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Use your unique cloned voice instead of the system default."),
                value: val,
                activeColor: AppTheme.primaryDark,
                onChanged: (newVal) => AppState.identityMode.value = newVal,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryDark.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: AppTheme.primaryDark),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text("Identity-preserving mode uses few-shot learning to maintain your vocal signature.", 
                      style: TextStyle(fontSize: 13, color: AppTheme.primaryDark.withOpacity(0.6))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryDark),
        const SizedBox(width: 12),
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: AppTheme.primaryDark)),
      ],
    );
  }

  Widget _buildSliderLabel(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        Text("${(value * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
      ],
    );
  }
}
