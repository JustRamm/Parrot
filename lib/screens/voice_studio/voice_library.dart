import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../onboarding/voice_creation_wizard.dart';

class VoiceLibraryScreen extends StatefulWidget {
  const VoiceLibraryScreen({super.key});

  @override
  State<VoiceLibraryScreen> createState() => _VoiceLibraryScreenState();
}

class _VoiceLibraryScreenState extends State<VoiceLibraryScreen> {
  String _activeVoiceId = "1";
  
  final List<Map<String, String>> _voices = [
    {"id": "1", "name": "Natural Me", "date": "2 days ago", "type": "Natural"},
    {"id": "2", "name": "Formal Public", "date": "1 week ago", "type": "Professional"},
    {"id": "3", "name": "Casual Tone", "date": "3 weeks ago", "type": "Warm"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppBar(
        title: const Text("Voice Studio", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppTheme.logoSage),
            onPressed: () => _navigateToWizard(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildActiveVoiceCard(),
            const SizedBox(height: 32),
            const Text(
              "Your Cloned Voices",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryDark, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _voices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final voice = _voices[index];
                final isActive = voice['id'] == _activeVoiceId;
                return _buildVoiceItem(voice, isActive);
              },
            ),
            const SizedBox(height: 32),
            _buildCreateNewCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveVoiceCard() {
    final activeVoice = _voices.firstWhere((v) => v['id'] == _activeVoiceId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.logoSage, AppTheme.logoSage.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.logoSage.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("ACTIVE VOICE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.waves, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(activeVoice['name']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Last synthesized: Just now", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.logoSage,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Sample Playback", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVoiceItem(Map<String, String> voice, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border.all(color: AppTheme.logoSage.withOpacity(0.3), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.logoSage.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? LucideIcons.check : LucideIcons.mic,
              color: isActive ? AppTheme.logoSage : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(voice['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark)),
                Text("Created: ${voice['date']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          if (!isActive)
            TextButton(
              onPressed: () => setState(() => _activeVoiceId = voice['id']!),
              child: const Text("SET ACTIVE", style: TextStyle(color: AppTheme.logoSage, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, size: 20, color: Colors.grey),
            onSelected: (val) {
              if (val == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice deletion simulated.")));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text("Rename Voice")),
              const PopupMenuItem(value: 'delete', child: Text("Delete Voice", style: TextStyle(color: AppTheme.logoRose))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCreateNewCard(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToWizard(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.logoSage.withOpacity(0.2), width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.logoSage.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(LucideIcons.microphone, color: AppTheme.logoSage),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Clone New Voice", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Quick 30-second training process", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _navigateToWizard(BuildContext context) {
    context.push('/voice-wizard');
  }
}
