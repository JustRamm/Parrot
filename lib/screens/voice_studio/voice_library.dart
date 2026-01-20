import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../../providers/app_state.dart';

class VoiceLibraryScreen extends StatefulWidget {
  const VoiceLibraryScreen({super.key});

  @override
  State<VoiceLibraryScreen> createState() => _VoiceLibraryScreenState();
}

class _VoiceLibraryScreenState extends State<VoiceLibraryScreen> {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  String _activeVoiceId = AppState.currentVoiceId.value ?? "1";
  bool _isPlayingDemo = false;
  
  final List<Map<String, String>> _voices = [
    {"id": "1", "name": "Natural Me", "date": "2 days ago", "type": "Natural", "demoText": "Hello! This is my natural voice identity, cloned for real-time communication."},
    {"id": "2", "name": "Formal Public", "date": "1 week ago", "type": "Professional", "demoText": "Good afternoon. I am using my formal voice profile, optimized for professional environments."},
    {"id": "3", "name": "Casual Tone", "date": "3 weeks ago", "type": "Warm", "demoText": "Hey there! I'm using my casual tone. It's great for chatting with friends and family."},
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playDemo(Map<String, String> voice) async {
    if (_isPlayingDemo) return;
    
    setState(() => _isPlayingDemo = true);
    
    try {
      final text = voice['demoText']!;
      final profile = voice['type']!;
      
      // Use null embedding for demo to force profile usage on backend
      final audioBytes = await _apiService.synthesizeSpeech(text, null, voiceProfile: profile);
      await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));
      
      _audioPlayer.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _isPlayingDemo = false);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Demo failed: $e")));
        setState(() => _isPlayingDemo = false);
      }
    }
  }

  void _selectVoice(Map<String, String> voice) {
    setState(() {
      _activeVoiceId = voice['id']!;
    });
    AppState.currentVoiceId.value = voice['id'];
    AppState.currentVoiceProfile.value = voice['type']!;
    
    // In a real app, you'd also load the specific embedding for this voice here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundClean,
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 60, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Voice Studio",
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Manage your digital voice identities",
              style: TextStyle(
                color: AppTheme.primaryDark.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _buildActiveVoiceCard(),
            const SizedBox(height: 48),
            Row(
              children: [
                Text(
                  "MY VOICES",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryDark.withOpacity(0.3),
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.logoSage.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${_voices.length} TOTAL",
                    style: const TextStyle(
                      color: AppTheme.logoSage,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
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
            _buildCreateNewButton(context),
            const SizedBox(height: 130), // Clearance for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildActiveVoiceCard() {
    final activeVoice = _voices.firstWhere((v) => v['id'] == _activeVoiceId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, Color(0xFF454E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.logoSage.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.logoSage.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.logoSage,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "LIVE IDENTITY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _playDemo(activeVoice),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlayingDemo ? LucideIcons.loader2 : LucideIcons.play, 
                    color: Colors.white, 
                    size: 16
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            activeVoice['name']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Primary voice for real-time synthesis",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          // Waveform Animation Placeholder
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (index) {
                return Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: 4,
                  height: 10 + (index % 7) * 4.0,
                  decoration: BoxDecoration(
                    color: AppTheme.logoSage.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(3),
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
    return GestureDetector(
      onTap: () => _selectVoice(voice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isActive ? AppTheme.logoSage.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isActive 
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            : [],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.logoSage.withOpacity(0.1) : AppTheme.backgroundClean,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isActive ? LucideIcons.volume2 : LucideIcons.mic,
                color: isActive ? AppTheme.logoSage : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voice['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: isActive ? AppTheme.primaryDark : AppTheme.primaryDark.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    voice['type'] ?? "Standard",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!isActive)
              IconButton(
                icon: const Icon(LucideIcons.playCircle, color: Colors.grey, size: 24),
                onPressed: () => _playDemo(voice),
              ),
            if (isActive)
              const Icon(LucideIcons.checkCircle2, color: AppTheme.logoSage, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToWizard(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.logoSage.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.logoSage.withOpacity(0.2), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.logoSage,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 16),
            const Text(
              "Clone New Identity",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primaryDark, letterSpacing: -0.5),
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
