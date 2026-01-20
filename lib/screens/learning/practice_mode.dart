import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import '../../core/theme.dart';

class PracticeModeScreen extends StatefulWidget {
  final String gestureName;
  const PracticeModeScreen({super.key, required this.gestureName});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  bool _isDetecting = true;
  bool _isSuccess = false;
  int _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMockDetection();
  }

  void _startMockDetection() {
    // Simulate AI detection process
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 100) {
          _progress += 2;
        } else {
          _isDetecting = false;
          _isSuccess = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock Camera Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
            ),
            child: Center(
              child: Icon(LucideIcons.camera, size: 80, color: Colors.white.withOpacity(0.1)),
            ),
          ),
          
          // HUD Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.video, color: Colors.red, size: 14),
                            SizedBox(width: 8),
                            Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.flipVertical, color: Colors.white), // Camera flip icon replacement
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Detection Status Box
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isSuccess ? AppTheme.logoSage : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isSuccess ? "Perfect!" : "Show me: ${widget.gestureName.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _isSuccess ? Colors.white : AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_isSuccess)
                         ClipRRect(
                           borderRadius: BorderRadius.circular(10),
                           child: LinearProgressIndicator(
                             value: _progress / 100,
                             minHeight: 8,
                             backgroundColor: Colors.grey.shade200,
                             valueColor: AlwaysStoppedAnimation(AppTheme.logoSage),
                           ),
                         ),
                      if (_isSuccess)
                         Column(
                           children: [
                             const Icon(LucideIcons.checkCircle, size: 48, color: Colors.white),
                             const SizedBox(height: 16),
                             ElevatedButton(
                               onPressed: () => Navigator.pop(context),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.white,
                                 foregroundColor: AppTheme.logoSage,
                                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                               ),
                               child: const Text("Next Gesture", style: TextStyle(fontWeight: FontWeight.bold)),
                             )
                           ],
                         )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
