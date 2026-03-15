
import sys
import os

# Set up paths
backend_dir = r"c:\Users\abira\OneDrive\Desktop\final year project\backend"
sys.path.append(backend_dir)
sys.path.append(os.path.join(backend_dir, "clone"))


try:
    print("Attempting to import encoder...")
    from encoder import inference as encoder
    print("✓ Success")
except Exception as e:
    print(f"✗ Failed: {e}")
    import traceback
    traceback.print_exc()

try:
    print("Attempting to import synthesizer...")
    from synthesizer.inference import Synthesizer
    print("✓ Success")
except Exception as e:
    print(f"✗ Failed: {e}")
    import traceback
    traceback.print_exc()

try:
    print("Attempting to import vocoder...")
    from vocoder import inference as vocoder
    print("✓ Success")
except Exception as e:
    print(f"✗ Failed: {e}")
    import traceback
    traceback.print_exc()

