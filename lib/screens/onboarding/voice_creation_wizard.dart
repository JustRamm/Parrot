import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/app_state.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/exceptions.dart';
import '../../core/validators.dart';
import '../../services/api_service.dart';

class VoiceCreationWizard extends StatefulWidget {
  const VoiceCreationWizard({super.key});

  @override
  State<VoiceCreationWizard> createState() => _VoiceCreationWizardState();
}

class _VoiceCreationWizardState extends State<VoiceCreationWizard> {
  int _currentStep = 0;
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isProcessing = false;
  
  // Recording states
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedPath;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1 && _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a voice sample first (Record or Upload).")),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _generateVoice();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/voice_clone_sample_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig();
        await _audioRecorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _recordedPath = path;
        });
      }
    } catch (e) {
      debugPrint("Recording start error: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        final fileSize = await file.length();
        
        setState(() {
          _isRecording = false;
          _selectedFilePath = path;
          _selectedFileName = "Self Recording (${(fileSize / 1024).toStringAsFixed(1)} KB)";
          _selectedFileSize = fileSize;
        });
      }
    } catch (e) {
      debugPrint("Recording stop error: $e");
    }
  }

  Future<void> _pickVoiceFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final filePath = file.path!;
        final fileSize = file.size;
        
        // Validate file
        final validationError = Validators.validateAudioFile(filePath, fileSize);
        if (validationError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(validationError.message), backgroundColor: Colors.red),
            );
          }
          return;
        }
        
        setState(() {
          _selectedFilePath = filePath;
          _selectedFileName = file.name;
          _selectedFileSize = fileSize;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting file: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _generateVoice() async {
    setState(() => _isProcessing = true);
    AppState.voiceCreationProgress.value = 0.1;

    try {
      if (_selectedFilePath == null || _selectedFileSize == null) {
        throw ValidationException(ErrorMessages.invalidFileFormat);
      }

      AppState.voiceCreationProgress.value = 0.3;
      final result = await _apiService.cloneVoice(_selectedFilePath!, _selectedFileSize!);
      AppState.voiceCreationProgress.value = 0.7;

      if (result['success'] == true && result['embedding'] != null) {
        AppState.voiceEmbedding.value = result['embedding'];
        AppState.currentVoiceId.value = "custom_${DateTime.now().millisecondsSinceEpoch}";
        AppState.isVoiceGenerated.value = true;
        AppState.voiceCreationProgress.value = 1.0;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(SuccessMessages.voiceCloned)),
          );
          context.go('/main');
        }
      } else {
        throw ServerException(result['error'] ?? ErrorMessages.cloningError);
      }
    } catch (e) {
      String message = "Synthesis failed. Ensure backend is running.";
      if (e is ValidationException) message = e.message;
      if (e is ServerException) message = e.message;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        AppState.voiceCreationProgress.value = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundClean,
      appBar: AppBar(
        title: const Text("Voice Studio"),
        actions: [
          if (_currentStep > 0)
            IconButton(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(LucideIcons.chevronLeft),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppTheme.logoSage.withOpacity(0.1),
              color: AppTheme.logoSage,
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _buildStepContent(),
            ),
            const SizedBox(height: 24),
            
            ValueListenableBuilder<double>(
              valueListenable: AppState.voiceCreationProgress,
              builder: (context, progress, child) {
                if (_isProcessing) {
                  return Column(
                     children: [
                       const Text("Generating Vocal Identity...", style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryDark)),
                       const SizedBox(height: 12),
                       LinearProgressIndicator(value: progress, color: AppTheme.logoSage, backgroundColor: AppTheme.logoSage.withOpacity(0.1)),
                       const SizedBox(height: 20),
                     ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            ElevatedButton(
              onPressed: (_isProcessing || _isRecording) ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                backgroundColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isProcessing 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Text(_currentStep == 2 ? "Finalize Model" : "Next Step", style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildIntroduction();
      case 1: return _buildVocalInputMethod();
      case 2: return _buildConfirmation();
      default: return const SizedBox();
    }
  }

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Voice,\nDigitized.", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryDark, height: 1.1, letterSpacing: -2)),
        const SizedBox(height: 24),
        Text("Parrot clones your unique vocal signature so you can communicate using your own voice through sign language.",
          style: TextStyle(fontSize: 16, color: AppTheme.primaryDark.withOpacity(0.6), fontWeight: FontWeight.w500)),
        const SizedBox(height: 48),
        Center(
          child: Container(
            height: 200, width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: const LinearGradient(colors: [AppTheme.logoSage, AppTheme.logoRose], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: AppTheme.logoSage.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20))]
            ),
            child: const Icon(LucideIcons.mic2, color: Colors.white, size: 80),
          ),
        ),
      ],
    );
  }

  Widget _buildVocalInputMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Vocal Input", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryDark, letterSpacing: -1)),
        const SizedBox(height: 12),
        const Text("Provide a sample of your voice. You can record it right now or upload an existing crystal-clear recording."),
        const SizedBox(height: 32),
        
        // Record Button
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _isRecording ? Colors.red : Colors.grey.shade200, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]
            ),
            child: Column(
              children: [
                Icon(_isRecording ? LucideIcons.square : LucideIcons.mic, color: _isRecording ? Colors.red : AppTheme.logoSage, size: 40),
                const SizedBox(height: 16),
                Text(_isRecording ? "Recording... (Tap to stop)" : "Record within app", style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Center(child: Text("— OR —", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey))),
        const SizedBox(height: 20),

        // File Selection
        GestureDetector(
          onTap: _pickVoiceFile,
          child: Container(
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _selectedFilePath != null && !_isRecording ? AppTheme.logoSage : Colors.grey.shade200, width: 2, style: BorderStyle.solid),
              color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.fileAudio, color: Colors.grey.shade400, size: 24),
                const SizedBox(width: 12),
                Text(_selectedFilePath != null && !_isRecording ? _selectedFileName! : "Upload Audio File", 
                  style: TextStyle(fontWeight: FontWeight.w700, color: _selectedFilePath != null ? AppTheme.logoSage : Colors.grey.shade600))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Processing Ready", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryDark, letterSpacing: -1)),
        const SizedBox(height: 16),
        const Text("We have captured your vocal embedding. Our neural network will now create a digital clone of this profile."),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.logoSage.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.logoSage.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.shieldCheck, color: AppTheme.logoSage, size: 24),
                  SizedBox(width: 16),
                  Expanded(child: Text("Encrypted & Privacy-Focused", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryDark))),
                ],
              ),
              const SizedBox(height: 12),
              Text("Your voice data is processed locally and discarded immediately after model creation.", style: TextStyle(fontSize: 12, color: AppTheme.primaryDark.withOpacity(0.6))),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Center(child: Icon(LucideIcons.activity, size: 100, color: AppTheme.logoSage.withOpacity(0.2))),
      ],
    );
  }
}
