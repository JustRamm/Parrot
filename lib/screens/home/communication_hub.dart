import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import '../../providers/app_state.dart';
import '../../widgets/emotion_indicator.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/waveform_visualizer.dart';

class CommunicationHub extends StatefulWidget {
  const CommunicationHub({super.key});

  @override
  State<CommunicationHub> createState() => _CommunicationHubState();
}

class _CommunicationHubState extends State<CommunicationHub> {
  late TextEditingController _transcriptionController;
  bool _isCameraActive = false;
  IO.Socket? socket;
  // Polling variables
  Uint8List? _frameBytes;
  Timer? _pollingTimer;
  bool _isPolling = false;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  final http.Client _httpClient = http.Client();
  bool _isSpeaking = false;
  bool _isFetchingFrame = false;

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

    _initSocket();
    
    // Automatically start camera for testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toggleCamera();
    });
  }

  void _initSocket() {
    // For Desktop/Web 'http://127.0.0.1:5000' works better than localhost on Windows.
    socket = IO.io('http://127.0.0.1:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.onConnect((_) {
      print('Connected to Sign Language Backend');
    });

    socket?.on('text_update', (data) {
      if (data != null && data['text'] != null) {
        String newText = data['text'];
        // Simple smoothing: only update if different
        if (AppState.translatedText.value != newText) {
             AppState.translatedText.value = newText;
        }
      }
    });
    
    socket?.onDisconnect((_) => print('Disconnected'));
  }

  @override
  void dispose() {
    _transcriptionController.dispose();
    socket?.dispose();
    _audioPlayer.dispose();
    _httpClient.close();
    _stopPolling();
    super.dispose();
  }

  void _toggleCamera() {
    setState(() {
      _isCameraActive = !_isCameraActive;
      if (_isCameraActive) {
        socket?.connect();
        _startPolling();
      } else {
        socket?.disconnect();
        _stopPolling();
      }
    });
  }

  void _startPolling() {
    _stopPolling(); // Ensure no duplicates
    _isPolling = true;
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_isCameraActive && _isPolling && !_isFetchingFrame) {
        _fetchFrame();
      }
    });
  }

  void _stopPolling() {
    _isPolling = false;
    _isFetchingFrame = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchFrame() async {
    _isFetchingFrame = true;
    try {
      // Use the video_frame endpoint which returns a single JPG
      // Reusing _httpClient is much faster on Windows/Web
      final response = await _httpClient.get(Uri.parse('http://127.0.0.1:5000/video_frame'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _frameBytes = response.bodyBytes;
          });
        }
      }
    } catch (e) {
      // Don't spam console if connection failed once
    } finally {
      _isFetchingFrame = false;
    }
  }

  Future<void> _speakText() async {
    if (_isSpeaking) return;
    
    final text = _transcriptionController.text;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nothing to speak!")));
      return;
    }

    setState(() => _isSpeaking = true);
    
    try {
      final embedding = AppState.voiceEmbedding.value;
      if (embedding == null) {
        if (mounted) {
           showDialog(
             context: context,
             builder: (ctx) => AlertDialog(
               title: const Text("Voice Required"),
               content: const Text("Please create your custom voice identity in Voice Studio first."),
               actions: [
                 TextButton(
                   onPressed: () => Navigator.of(ctx).pop(),
                   child: const Text("OK"),
                 ),
               ],
             ),
           );
        }
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Synthesizing with YOUR voice..."), duration: Duration(seconds: 1)));
      final audioBytes = await _apiService.synthesizeSpeech(
        text, 
        embedding, 
        voiceProfile: AppState.currentVoiceProfile.value
      );
      await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));

    } catch (e) {
      print("TTS Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Speech Error: ${e.toString()}")));
    } finally {
      setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "Parrot",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: -1,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white, size: 22),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
          _buildLiveStatusBadge(),
          const SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Camera Viewport
          Expanded(
            flex: 11,
            child: _buildCameraViewport(),
          ),
          
          // Transcription Sheet
          Expanded(
            flex: 10,
            child: _buildTranscriptionSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isCameraActive 
            ? AppTheme.logoSage.withOpacity(0.2) 
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isCameraActive 
              ? AppTheme.logoSage.withOpacity(0.5) 
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _isCameraActive ? AppTheme.logoSage : Colors.white60,
              shape: BoxShape.circle,
              boxShadow: _isCameraActive 
                  ? [BoxShadow(color: AppTheme.logoSage, blurRadius: 4, spreadRadius: 1)] 
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isCameraActive ? "LIVE" : "STANDBY",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewport() {
    return GestureDetector(
      onTap: _toggleCamera,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isCameraActive)
              _frameBytes != null
                  ? Image.memory(
                      _frameBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                    )
                  : const Center(child: CircularProgressIndicator(color: AppTheme.logoSage))
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.videoOff,
                    size: 48,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Camera is paused",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            
            // Helpful overlay when offline
            if (!_isCameraActive)
              Positioned(
                bottom: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Text(
                    "Tap anywhere to start recognition",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              
            // Scanning Line Animation if Active
            if (_isCameraActive)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.logoSage.withOpacity(0),
                        AppTheme.logoSage.withOpacity(0.5),
                        AppTheme.logoSage.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptionSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.logoSage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "DETECTION LOG",
                  style: TextStyle(
                    color: AppTheme.logoSage,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              if (_isSpeaking)
                WaveformVisualizer(isAnimating: true, color: AppTheme.logoSage),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: TextField(
              controller: _transcriptionController,
              maxLines: null,
              expands: true,
              readOnly: true,
              style: TextStyle(
                height: 1.5,
                color: AppTheme.primaryDark,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              decoration: InputDecoration(
                hintText: "Start signing to see text...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 24,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSpeaking ? null : _speakText,
                  icon: _isSpeaking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(LucideIcons.volume2, size: 20),
                  label: Text(_isSpeaking ? "SPEAKING..." : "CONVERT TO VOICE"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.logoSage,
                    elevation: 10,
                    shadowColor: AppTheme.logoSage.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(LucideIcons.copy, AppTheme.logoRose, () {
                // TODO: Copy logic
              }),
            ],
          ),
          const SizedBox(height: 120), // Clearance for floating navbar
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

