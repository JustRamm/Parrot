"""
Quick test script to verify voice cloning backend functionality
"""

import sys
import os
from pathlib import Path

# Add clone folder to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'clone'))

def test_imports():
    """Test if all required modules can be imported"""
    print("Testing imports...")
    try:
        import numpy as np
        print("✓ numpy")
    except ImportError as e:
        print(f"✗ numpy: {e}")
        return False
    
    try:
        import torch
        print(f"✓ torch (version {torch.__version__})")
        print(f"  CUDA available: {torch.cuda.is_available()}")
    except ImportError as e:
        print(f"✗ torch: {e}")
        return False
    
    try:
        import librosa
        print("✓ librosa")
    except ImportError as e:
        print(f"✗ librosa: {e}")
        return False
    
    try:
        import soundfile
        print("✓ soundfile")
    except ImportError as e:
        print(f"✗ soundfile: {e}")
        return False
    
    try:
        from clone.voice_cloning import VoiceCloningManager
        print("✓ voice_cloning module")
    except ImportError as e:
        print(f"✗ voice_cloning module: {e}")
        return False
    
    return True

def test_models():
    """Test if models are downloaded and valid"""
    print("\nChecking models...")
    script_dir = Path(__file__).parent
    models_dir = script_dir / "clone" / "saved_models"
    
    if not models_dir.exists():
        print(f"✗ Models directory not found: {models_dir}")
        return False
    
    models = ["encoder.pt", "synthesizer.pt", "vocoder.pt"]
    all_good = True
    
    for model_name in models:
        model_path = models_dir / model_name
        if model_path.exists():
            size = model_path.stat().st_size
            size_mb = size / (1024 * 1024)
            if size > 1000:
                print(f"✓ {model_name} ({size_mb:.2f} MB)")
            else:
                print(f"⚠ {model_name} exists but is too small ({size} bytes)")
                all_good = False
        else:
            print(f"✗ {model_name} not found")
            all_good = False
    
    return all_good

def test_voice_cloning_manager():
    """Test if VoiceCloningManager can be initialized"""
    print("\nTesting VoiceCloningManager...")
    try:
        from clone.voice_cloning import VoiceCloningManager
        
        script_dir = Path(__file__).parent
        models_dir = script_dir / "clone" / "saved_models"
        
        manager = VoiceCloningManager(models_dir=models_dir)
        
        print(f"  Encoder loaded: {manager.encoder_loaded}")
        print(f"  Synthesizer loaded: {manager.synthesizer_loaded}")
        print(f"  Vocoder loaded: {manager.vocoder_loaded}")
        
        if manager.encoder_loaded and manager.synthesizer_loaded and manager.vocoder_loaded:
            print("✓ All models loaded successfully!")
            return True
        else:
            print("⚠ Some models failed to load (will use mock mode)")
            return False
            
    except Exception as e:
        print(f"✗ Error initializing VoiceCloningManager: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    print("=" * 70)
    print("  Voice Cloning Backend Test")
    print("=" * 70)
    
    # Test imports
    if not test_imports():
        print("\n✗ Import test failed. Please install missing dependencies:")
        print("  pip install -r requirements.txt")
        return False
    
    # Test models
    models_ok = test_models()
    if not models_ok:
        print("\n⚠ Models test failed. Please download models:")
        print("  python download_models.py")
    
    # Test manager
    manager_ok = test_voice_cloning_manager()
    
    print("\n" + "=" * 70)
    if models_ok and manager_ok:
        print("✓ All tests passed! Voice cloning backend is ready.")
        print("\nYou can now start the server:")
        print("  python server.py")
    else:
        print("⚠ Some tests failed. Please review the errors above.")
        if not models_ok:
            print("\nTo download models:")
            print("  python download_models.py")
    print("=" * 70)
    
    return models_ok and manager_ok

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
