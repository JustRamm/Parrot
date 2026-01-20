import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../../providers/app_state.dart';
import '../../widgets/waveform_visualizer.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  
  final List<String> _messages = [];
  bool _isSpeaking = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;

    if (_isSpeaking) return;

    // Add to specific history
    setState(() {
      _messages.insert(0, text);
      _isSpeaking = true;
    });
    
    // Clear input
    _textController.clear();

    try {
      final embedding = AppState.voiceEmbedding.value;
      if (embedding == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No custom voice found. Using standard voice.")));
          }
      }

      // Synthesize
      final audioBytes = await _apiService.synthesizeSpeech(
        text, 
        embedding, 
        voiceProfile: AppState.currentVoiceProfile.value
      );
      
      // Play
      await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));
      
      // Listen for completion (simple delay approx or player state)
      _audioPlayer.onPlayerComplete.first.then((_) {
         if (mounted) setState(() => _isSpeaking = false);
      });

    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
         setState(() => _isSpeaking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundClean,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Voice Messenger",
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.logoSage,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Cloned Voice Active",
                  style: TextStyle(
                    color: AppTheme.primaryDark.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Message History or Empty State
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),
              
              // Input Area moved back to bottom but with floating style
              _buildInputArea(),
            ],
          ),
          
          // Waveform Overlay when speaking
          if (_isSpeaking)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Speaking",
                        style: TextStyle(
                          color: AppTheme.logoSage,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      WaveformVisualizer(isAnimating: true, color: AppTheme.logoSage),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.logoSage.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.messageSquare,
              size: 48,
              color: AppTheme.logoSage.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Silence is Golden,\nBut your voice matters.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryDark.withOpacity(0.3),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Type anything to speak with your identity.",
            style: TextStyle(
              color: AppTheme.primaryDark.withOpacity(0.2),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw, size: 16, color: Colors.grey),
            onPressed: () => _speak(text),
            visualDensity: VisualDensity.compact,
            tooltip: "Repeat",
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.logoSage,
                    AppTheme.logoSage.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.logoSage.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 110), // Significantly above the bottom nav
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Type to speak...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _speak,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if (_textController.text.isNotEmpty)
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                onPressed: () => setState(() => _textController.clear()),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSpeaking ? null : () => _speak(_textController.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSpeaking ? Colors.grey.shade200 : AppTheme.logoSage,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSpeaking ? LucideIcons.loader2 : LucideIcons.send,
                  color: _isSpeaking ? Colors.grey : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

