import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

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
        title: const Text("Voice Studio", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppTheme.primaryDark),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.backgroundClean,
            ),
            onPressed: () => _navigateToWizard(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildActiveVoiceCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Voice Library",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                ),
                Text(
                  "${_voices.length} voices",
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _voices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final voice = _voices[index];
                final isActive = voice['id'] == _activeVoiceId;
                return _buildVoiceItem(voice, isActive);
              },
            ),
            const SizedBox(height: 32),
            _buildCreateNewButton(context),
            const SizedBox(height: 120), // Clearance for navbar
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
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.zap, color: AppTheme.logoSage, size: 14),
                    SizedBox(width: 6),
                    Text("ACTIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ],
                ),
              ),
              const Icon(LucideIcons.moreHorizontal, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            activeVoice['name']!,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            "Ready to speak • Natural Tone",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(20, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 4,
                  height: 10 + (index % 5) * 8.0,
                  decoration: BoxDecoration(
                    color: AppTheme.logoSage.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceItem(Map<String, String> voice, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? AppTheme.logoSage : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.logoSage.withOpacity(0.1) : AppTheme.backgroundClean,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isActive ? LucideIcons.volume2 : LucideIcons.mic,
              color: isActive ? AppTheme.logoSage : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voice['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark),
                ),
                Text(
                  voice['type'] ?? "Standard",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isActive)
            TextButton(
              onPressed: () => setState(() => _activeVoiceId = voice['id']!),
              child: const Text("Select", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateNewButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToWizard(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white, // AppTheme.logoSage.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.logoSage, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.logoSage.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, color: AppTheme.logoSage, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              "Create New Voice",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 4),
            Text(
              "Clone your voice in 30 seconds",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToWizard(BuildContext context) {
    context.push('/voice-wizard');
  }
}
