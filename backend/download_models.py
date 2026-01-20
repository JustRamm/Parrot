import os
import requests
from pathlib import Path

def download_file(url, dest_path):
    print(f"Downloading {url} to {dest_path}...")
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        with open(dest_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"Successfully downloaded {dest_path}")
        return True
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return False

def main():
    # RTVC Models
    rtvc_base_url = "https://huggingface.co/blue-fish/Real-Time-Voice-Cloning/resolve/main/saved_models"
    script_dir = Path(__file__).parent
    clone_models_dir = script_dir / "clone" / "saved_models"
    clone_models_dir.mkdir(parents=True, exist_ok=True)
    
    models = {
        "encoder.pt": f"{rtvc_base_url}/encoder.pt",
        "synthesizer.pt": f"{rtvc_base_url}/synthesizer.pt",
        "vocoder.pt": f"{rtvc_base_url}/vocoder.pt",
    }
    
    print("--- Downloading Voice Cloning Models ---")
    for filename, url in models.items():
        dest = clone_models_dir / filename
        if not dest.exists():
            download_file(url, dest)
        else:
            print(f"{filename} already exists.")
            
    # Parrot TTS Models (Mock/Placeholder)
    # Since we cannot find the proprietary 'Parrot' models on the web, 
    # we will rely on the TTSManager's fallback to mock audio if these are missing.
    # However, to satisfy the file existence check if any, we can create placeholders, 
    # BUT TTSManager uses torch.load which will crash on empty files.
    # We will just skip downloading them and let TTSManager handle the "File not found" gracefullly 
    # by falling back to the sine wave generator as implemented.
    
    print("\nNote: 'Parrot' TTS models (parrot_model.ckpt) were not found in public repositories.")
    print("The system will use the downloaded Voice Cloning models for 'Cloned Voice' synthesis.")
    print("Standard TTS fallback will use a generated tone until a valid Parrot model is provided.")

if __name__ == "__main__":
    main()
