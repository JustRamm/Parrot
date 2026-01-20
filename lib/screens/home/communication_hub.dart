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
      final audioBytes = await _apiService.synthesizeSpeech(text, embedding);
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
        title: const Text("Parrot", style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: -0.5, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white, size: 24),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 4),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
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
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _toggleCamera,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Center(
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
                                  gaplessPlayback: true, // Smooth transitions
                                )
                              : const Center(child: CircularProgressIndicator(color: AppTheme.logoSage))
                          else
                            Icon(
                              LucideIcons.cameraOff, 
                              size: 64, 
                              color: Colors.white.withOpacity(0.1)
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
                /* Removed EmotionIndicator (CALM) per user request */
              ],
            ),
          ),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _transcriptionController,
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                      enabled: true,
                      textAlignVertical: TextAlignVertical.center,
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
                          onPressed: _isSpeaking ? null : _speakText,
                          icon: _isSpeaking 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(LucideIcons.volume2, size: 20),
                          label: Text(_isSpeaking ? "SPEAKING..." : "SPEAK OUT"),
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
