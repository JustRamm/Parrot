import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _sourceLanguage = 'American Sign Language (ASL)';
  String _targetLanguage = 'English (US)';
  String _voiceRegion = 'United States';

  final List<String> _signLanguages = [
    'American Sign Language (ASL)',
    'British Sign Language (BSL)',
    'French Sign Language (LSF)',
    'German Sign Language (DGS)',
  ];

  final List<String> _spokenLanguages = [
    'English (US)',
    'English (UK)',
    'Spanish (ES)',
    'French (FR)',
    'German (DE)',
    'Mandarin Chinese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Language & Region", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("TRANSLATION PREFERENCES"),
            const SizedBox(height: 16),
            _buildDropdownTile(
              "Sign Language Input",
              "Select the gesture language to detect.",
              _sourceLanguage,
              _signLanguages,
              (val) => setState(() => _sourceLanguage = val!),
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              "Text/Speech Output",
              "Select the language for text and voice output.",
              _targetLanguage,
              _spokenLanguages,
              (val) => setState(() => _targetLanguage = val!),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("REGIONAL SETTINGS"),
            const SizedBox(height: 16),
             _buildDropdownTile(
              "Voice Region",
              "Affects voice accent and colloquialisms.",
              _voiceRegion,
              ['United States', 'United Kingdom', 'Australia', 'Canada'],
              (val) => setState(() => _voiceRegion = val!),
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

  Widget _buildDropdownTile(String title, String subtitle, String value, List<String> items, ValueChanged<String?> onChanged) {
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
              const Icon(LucideIcons.globe, size: 20, color: AppTheme.logoSage),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundClean,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 20),
                onChanged: onChanged,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
