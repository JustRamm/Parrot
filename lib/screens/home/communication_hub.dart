import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/app_state.dart';
import '../../widgets/emotion_indicator.dart';
import '../../core/theme.dart';

class CommunicationHub extends StatefulWidget {
  const CommunicationHub({super.key});

  @override
  State<CommunicationHub> createState() => _CommunicationHubState();
}

class _CommunicationHubState extends State<CommunicationHub> {
  late TextEditingController _transcriptionController;
  bool _isCameraActive = false;

  @override
  void initState() {
    super.initState();
    _transcriptionController = TextEditingController(text: AppState.translatedText.value);
    
    // Sync external changes to controller
    AppState.translatedText.addListener(() {
      if (_transcriptionController.text != AppState.translatedText.value) {
        _transcriptionController.text = AppState.translatedText.value;
      }
    });
  }

  @override
  void dispose() {
    _transcriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Real-Time Translation", style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isCameraActive ? AppTheme.logoSage.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isCameraActive ? AppTheme.logoSage.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, 
                  height: 8, 
                  decoration: BoxDecoration(
                    color: _isCameraActive ? AppTheme.logoSage : Colors.grey, 
                    shape: BoxShape.circle,
                    boxShadow: _isCameraActive ? [BoxShadow(color: AppTheme.logoSage.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)] : null,
                  )
                ),
                const SizedBox(width: 8),
                Text(_isCameraActive ? "LIVE" : "OFFLINE", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Camera Feed viewport (Top Half)
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isCameraActive = !_isCameraActive),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _isCameraActive 
                          ? [Colors.black, AppTheme.primaryDark.withOpacity(0.8)] 
                          : [Colors.black54, Colors.black],
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            _isCameraActive ? LucideIcons.camera : LucideIcons.cameraOff, 
                            size: 64, 
                            color: _isCameraActive ? AppTheme.logoSage.withOpacity(0.4) : Colors.white.withOpacity(0.05)
                          ),
                          if (_isCameraActive)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 2),
                              builder: (context, value, child) {
                                return Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.logoSage.withOpacity(0.1 * (1 - value)), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            ),
                          if (!_isCameraActive)
                            Transform.translate(
                              offset: const Offset(0, 50),
                              child: const Text(
                                "Tap to start camera",
                                style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 110, right: 24,
                  child: ValueListenableBuilder<double>(
                    valueListenable: AppState.emotionIntensity,
                    builder: (context, val, _) => _isCameraActive 
                      ? EmotionIndicator(intensity: val)
                      : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          // Transcription HUD (Bottom Half - Editable)
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.logoSage.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("REAL-TIME TRANSCRIPTION", 
                          style: TextStyle(color: AppTheme.logoSage, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.5)),
                      ),
                      const Spacer(),
                      // Removed clear icon as it's no longer editable
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _transcriptionController,
                      maxLines: null,
                      expands: true,
                      readOnly: true, // Make it non-editable
                      enabled: true,  // Keep it enabled so it remains visible but non-interactive
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (value) => AppState.translatedText.value = value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            height: 1.4,
                            color: AppTheme.primaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                      decoration: InputDecoration(
                        hintText: "Waiting for gesture recognition...",
                        hintStyle: TextStyle(color: Colors.grey.shade300),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Synthesizing personalized voice output..."), behavior: SnackBarBehavior.floating),
                          ),
                          icon: const Icon(LucideIcons.volume2, size: 20),
                          label: const Text("SPEAK OUT"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.logoSage,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.logoRose.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.copy, color: AppTheme.logoRose),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80), // Clearance for floating navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
