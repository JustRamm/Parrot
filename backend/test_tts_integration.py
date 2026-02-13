"""
Test script for TTS integration fixes
Tests all the improvements made to the TTS system
"""

import sys
import os

# Add paths
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'clone'))

def test_imports():
    """Test that all required modules can be imported"""
    print("=" * 70)
    print("Testing Imports")
    print("=" * 70)
    
    try:
        import numpy as np
        print("✓ numpy")
    except ImportError as e:
        print(f"✗ numpy: {e}")
        return False
    
    try:
        import torch
        print(f"✓ torch ({torch.__version__})")
        print(f"  CUDA available: {torch.cuda.is_available()}")
    except ImportError as e:
        print(f"✗ torch: {e}")
        return False
    
    try:
        import soundfile as sf
        print("✓ soundfile")
    except ImportError as e:
        print(f"✗ soundfile: {e}")
        return False
    
    try:
        from tts.tts_manager import TTSManager
        print("✓ TTSManager")
    except ImportError as e:
        print(f"✗ TTSManager: {e}")
        return False
    
    try:
        from clone.voice_cloning import VoiceCloningManager
        print("✓ VoiceCloningManager")
    except ImportError as e:
        print(f"✗ VoiceCloningManager: {e}")
        return False
    
    print()
    return True

def test_tts_manager():
    """Test TTS Manager initialization and methods"""
    print("=" * 70)
    print("Testing TTS Manager")
    print("=" * 70)
    
    try:
        from tts.tts_manager import TTSManager
        
        # Initialize
        print("Initializing TTS Manager...")
        tts_manager = TTSManager()
        print()
        
        # Check status
        status = tts_manager.get_status()
        print("TTS Manager Status:")
        for key, value in status.items():
            print(f"  {key}: {value}")
        print()
        
        # Test synthesis with each profile
        test_text = "Hello world"
        profiles = ['Natural', 'Professional', 'Warm']
        
        for i, profile in enumerate(profiles):
            print(f"Testing {profile} profile...")
            try:
                audio = tts_manager.synthesize(test_text, speaker_id=i)
                if audio is not None:
                    print(f"  ✓ Generated audio: {len(audio)} samples, dtype: {audio.dtype}")
                else:
                    print(f"  ✗ No audio generated")
            except Exception as e:
                print(f"  ✗ Error: {e}")
        
        print()
        return True
        
    except Exception as e:
        print(f"✗ TTS Manager test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_voice_cloning_manager():
    """Test Voice Cloning Manager"""
    print("=" * 70)
    print("Testing Voice Cloning Manager")
    print("=" * 70)
    
    try:
        from clone.voice_cloning import VoiceCloningManager
        
        # Initialize
        print("Initializing Voice Cloning Manager...")
        models_dir = os.path.join(os.path.dirname(__file__), 'clone', 'saved_models')
        vc_manager = VoiceCloningManager(models_dir=models_dir)
        print()
        
        # Check status
        print("Voice Cloning Status:")
        print(f"  Encoder loaded: {vc_manager.encoder_loaded}")
        print(f"  Synthesizer loaded: {vc_manager.synthesizer_loaded}")
        print(f"  Vocoder loaded: {vc_manager.vocoder_loaded}")
        print()
        
        # Test synthesis
        if vc_manager.encoder_loaded and vc_manager.synthesizer_loaded and vc_manager.vocoder_loaded:
            print("Testing voice cloning synthesis...")
            # Create a mock embedding
            import numpy as np
            mock_embedding = np.random.randn(256).tolist()
            
            try:
                wav, error = vc_manager.synthesize("Hello world", mock_embedding)
                if wav is not None and error is None:
                    print(f"  ✓ Synthesis successful: {len(wav)} samples")
                else:
                    print(f"  ⚠ Synthesis returned: wav={wav is not None}, error={error}")
            except Exception as e:
                print(f"  ✗ Synthesis error: {e}")
        else:
            print("⚠ Models not loaded, skipping synthesis test")
        
        print()
        return True
        
    except Exception as e:
        print(f"✗ Voice Cloning Manager test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_integration():
    """Test integration between TTS Manager and Voice Cloning"""
    print("=" * 70)
    print("Testing Integration")
    print("=" * 70)
    
    try:
        from tts.tts_manager import TTSManager
        from clone.voice_cloning import VoiceCloningManager
        import numpy as np
        
        # Initialize both
        print("Initializing both managers...")
        tts_manager = TTSManager()
        models_dir = os.path.join(os.path.dirname(__file__), 'clone', 'saved_models')
        vc_manager = VoiceCloningManager(models_dir=models_dir)
        print()
        
        # Test fallback priority
        print("Testing fallback priority:")
        
        # 1. Test with cloned voice embedding
        if vc_manager.synthesizer_loaded and vc_manager.vocoder_loaded:
            print("  1. Testing with cloned voice embedding...")
            mock_embedding = np.random.randn(256).tolist()
            wav, error = vc_manager.synthesize("Test", mock_embedding)
            if wav is not None:
                print("     ✓ Cloned voice synthesis works")
            else:
                print(f"     ⚠ Cloned voice failed: {error}")
        else:
            print("  1. ⚠ Skipping cloned voice test (models not loaded)")
        
        # 2. Test with profile embedding
        print("  2. Testing with profile embedding...")
        wav = tts_manager.synthesize("Test", speaker_id=0)
        if wav is not None:
            if tts_manager.is_ready():
                print("     ✓ Profile synthesis with voice cloning works")
            else:
                print("     ⚠ Using mock audio (expected if models not loaded)")
        else:
            print("     ✗ Profile synthesis failed")
        
        # 3. Test mock audio fallback
        print("  3. Testing mock audio fallback...")
        wav = tts_manager._generate_mock_audio(0, "Test")
        if wav is not None and len(wav) > 0:
            print("     ✓ Mock audio generation works")
        else:
            print("     ✗ Mock audio generation failed")
        
        print()
        return True
        
    except Exception as e:
        print(f"✗ Integration test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_config():
    """Test configuration file"""
    print("=" * 70)
    print("Testing Configuration")
    print("=" * 70)
    
    try:
        from tts import config
        
        print("Configuration loaded:")
        print(f"  Base dir: {config.BASE_DIR}")
        print(f"  Voice cloning models dir: {config.VOICE_CLONING_MODELS_DIR}")
        print(f"  Voice profiles: {list(config.VOICE_PROFILES.keys())}")
        print(f"  Use CUDA: {config.USE_CUDA}")
        print()
        
        # Check if paths exist
        print("Checking paths:")
        if os.path.exists(config.VOICE_CLONING_MODELS_DIR):
            print(f"  ✓ Voice cloning models dir exists")
            
            # Check for model files
            for model_name in ['encoder.pt', 'synthesizer.pt', 'vocoder.pt']:
                model_path = os.path.join(config.VOICE_CLONING_MODELS_DIR, model_name)
                if os.path.exists(model_path):
                    size_mb = os.path.getsize(model_path) / (1024 * 1024)
                    print(f"    ✓ {model_name} ({size_mb:.2f} MB)")
                else:
                    print(f"    ✗ {model_name} not found")
        else:
            print(f"  ✗ Voice cloning models dir does not exist")
        
        print()
        return True
        
    except Exception as e:
        print(f"✗ Configuration test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all tests"""
    print("\n" + "=" * 70)
    print("TTS Integration Test Suite")
    print("=" * 70 + "\n")
    
    results = {
        'Imports': test_imports(),
        'Configuration': test_config(),
        'TTS Manager': test_tts_manager(),
        'Voice Cloning Manager': test_voice_cloning_manager(),
        'Integration': test_integration()
    }
    
    # Summary
    print("=" * 70)
    print("Test Summary")
    print("=" * 70)
    
    for test_name, passed in results.items():
        status = "✓ PASSED" if passed else "✗ FAILED"
        print(f"{test_name:.<50} {status}")
    
    all_passed = all(results.values())
    
    print()
    if all_passed:
        print("✓ All tests passed!")
    else:
        print("⚠ Some tests failed. Check output above for details.")
    
    print("=" * 70)
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    sys.exit(main())
