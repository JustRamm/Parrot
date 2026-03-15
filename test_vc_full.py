
import sys
import os

# Set up paths
backend_dir = r"c:\Users\abira\OneDrive\Desktop\final year project\backend"
sys.path.append(backend_dir)
sys.path.append(os.path.join(backend_dir, "clone"))

try:
    print("Testing imports...")
    from encoder import inference as encoder
    print("✓ Encoder imported")
    from synthesizer.inference import Synthesizer
    print("✓ Synthesizer imported")
    from vocoder import inference as vocoder
    print("✓ Vocoder imported")
    
    print("\nInitializing VoiceCloningManager and loading models...")
    from clone.voice_cloning import VoiceCloningManager
    models_dir = os.path.join(backend_dir, "clone", "saved_models")
    manager = VoiceCloningManager(models_dir=models_dir)
    
    print(f"\nStatus Summary:")
    print(f"  Encoder loaded: {manager.encoder_loaded}")
    print(f"  Synthesizer loaded: {manager.synthesizer_loaded}")
    print(f"  Vocoder loaded: {manager.vocoder_loaded}")
    
    if manager.encoder_loaded and manager.synthesizer_loaded and manager.vocoder_loaded:
        print("\n✓ SUCCESS: Voice cloning is fully functional with real models!")
    else:
        print("\n✗ FAILURE: Some models failed to load. Check paths or files.")
        
except Exception as e:
    print(f"\n✗ CRITICAL ERROR: {e}")
    import traceback
    traceback.print_exc()
