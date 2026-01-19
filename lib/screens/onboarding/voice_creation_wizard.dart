import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/app_state.dart';
import '../../widgets/waveform_visualizer.dart';
import '../../core/theme.dart';

class VoiceCreationWizard extends StatefulWidget {
  const VoiceCreationWizard({super.key});

  @override
  State<VoiceCreationWizard> createState() => _VoiceCreationWizardState();
}

class _VoiceCreationWizardState extends State<VoiceCreationWizard> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _generateVoice();
    }
  }

  void _generateVoice() async {
    AppState.voiceCreationProgress.value = 0.1;
    
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      AppState.voiceCreationProgress.value = i / 10;
    }
    
    AppState.isVoiceGenerated.value = true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Voice Identity Generated and Applied!")),
      );
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
            ValueListenableBuilder<double>(
              valueListenable: AppState.voiceCreationProgress,
              builder: (context, progress, child) {
                if (progress > 0 && progress < 1.0) {
                  return Column(
                    children: [
                      const Text("Synthesizing Identity...", style: TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            ElevatedButton(
              onPressed: _nextStep,
              child: Text(_currentStep == 2 ? "Generate Identity" : "Continue"),
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
        const Text("Upload a clip of a family member to use as a signature base."),
        const SizedBox(height: 24),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(border: Border.all(color: AppTheme.logoSage, width: 2),
            borderRadius: BorderRadius.circular(16), color: AppTheme.logoSage.withOpacity(0.05)),
          child: Column(children: const [
            Icon(LucideIcons.uploadCloud, size: 48, color: AppTheme.logoSage),
            SizedBox(height: 12),
            Text("Select Voice File", style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    );
  }

  Widget _buildResidualRecording() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Residual Sounds", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text("Record any sounds you can make to personalize the AI model."),
        const SizedBox(height: 48),
        Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: AppState.isRecording,
            builder: (context, recording, _) {
              return Column(children: [
                WaveformVisualizer(isAnimating: recording, color: AppTheme.logoSage),
                const SizedBox(height: 40),
                GestureDetector(
                  onTapDown: (_) => AppState.isRecording.value = true,
                  onTapUp: (_) => AppState.isRecording.value = false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: recording ? AppTheme.primaryDark : AppTheme.logoSage, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.mic, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("HOLD TO RECORD", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
              ]);
            },
          ),
        ),
      ],
    );
  }
}
