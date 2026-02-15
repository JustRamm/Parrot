import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/app_state.dart';
import '../../widgets/waveform_visualizer.dart';
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
  final ApiService _apiService = ApiService();

  void _nextStep() {
    if (_currentStep == 1 && _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a voice file first.")),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _generateVoice();
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
              SnackBar(
                content: Text(validationError.message),
                backgroundColor: Colors.red,
              ),
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
          SnackBar(
            content: Text("Error selecting file: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
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

    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message), 
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on NetworkException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on ServerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: ${e.toString()}"), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
        padding: const EdgeInsets.all(24.0),
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
            
            // Progress or Error status
            ValueListenableBuilder<double>(
              valueListenable: AppState.voiceCreationProgress,
              builder: (context, progress, child) {
                if (_isProcessing) {
                  return Column(
                     children: [
                       const Text("Training Voice Model...", style: TextStyle(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 10),
                       LinearProgressIndicator(value: progress),
                       const SizedBox(height: 20),
                     ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            ElevatedButton(
              onPressed: _isProcessing ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
              ),
              child: _isProcessing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == 2 ? "Generate Identity" : "Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildIntroduction();
      case 1: return _buildDonorVoiceOption();
      case 2: return _buildResidualRecording();
      default: return const SizedBox();
    }
  }

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Voice Studio", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
        const SizedBox(height: 16),
        const Text("Create a digital vocal identity that sounds like you using donor samples or residual sounds."),
        const SizedBox(height: 32),
        Center(
          child: Container(
            height: 120, width: 120,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
            child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset("assets/brand/logo.jpg", fit: BoxFit.cover)),
          ),
        ),
      ],
    );
  }

  Widget _buildDonorVoiceOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Donor Voice", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text("Upload a clear audio clip (WAV/MP3) to use as a signature base. Ensure it is at least 3-5 seconds long."),
        const SizedBox(height: 24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickVoiceFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity, 
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.logoSage, width: 2),
                borderRadius: BorderRadius.circular(16), 
                color: _selectedFilePath != null ? AppTheme.logoSage.withOpacity(0.1) : AppTheme.logoSage.withOpacity(0.05)
              ),
              child: Column(
                children: [
                   Icon(
                     _selectedFilePath != null ? LucideIcons.checkCircle : LucideIcons.uploadCloud, 
                     size: 48, 
                     color: AppTheme.logoSage
                   ),
                   const SizedBox(height: 12),
                   Text(
                     _selectedFileName ?? "Select Voice File", 
                     style: const TextStyle(fontWeight: FontWeight.w600)
                   ),
                   if (_selectedFileName != null)
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text("Ready to clone", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                     )
                ]
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResidualRecording() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Confirmation", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text("We are ready to generate your voice identity model based on the uploaded sample."),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: Colors.amber, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text("Ensure the backend server is running and models are loaded.", style: TextStyle(fontSize: 12, color: Colors.black87))),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Icon(LucideIcons.fingerprint, size: 80, color: AppTheme.logoSage.withOpacity(0.5)),
        ),
      ],
    );
  }
}
