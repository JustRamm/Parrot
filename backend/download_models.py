import os
import gdown
from pathlib import Path

def download_from_gdrive(file_id, dest_path):
    """Download file from Google Drive using gdown"""
    print(f"Downloading from Google Drive to {dest_path}...")
    try:
        url = f"https://drive.google.com/uc?id={file_id}"
        gdown.download(url, str(dest_path), quiet=False)
        print(f"Successfully downloaded {dest_path}")
        return True
    except Exception as e:
        print(f"Failed to download: {e}")
        return False

def download_from_url(url, dest_path):
    """Download file from direct URL"""
    import requests
    print(f"Downloading {url} to {dest_path}...")
    try:
        response = requests.get(url, stream=True, timeout=30)
        response.raise_for_status()
        total_size = int(response.headers.get('content-length', 0))
        
        with open(dest_path, 'wb') as f:
            if total_size == 0:
                f.write(response.content)
            else:
                downloaded = 0
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        done = int(50 * downloaded / total_size)
                        print(f"\r[{'=' * done}{' ' * (50-done)}] {downloaded}/{total_size} bytes", end='')
        print(f"\nSuccessfully downloaded {dest_path}")
        return True
    except Exception as e:
        print(f"\nFailed to download {url}: {e}")
        return False

def main():
    script_dir = Path(__file__).parent
    clone_models_dir = script_dir / "clone" / "saved_models"
    clone_models_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("Voice Cloning Models Downloader")
    print("=" * 60)
    
    # Google Drive file IDs for pretrained RTVC models
    # These are from the original Real-Time-Voice-Cloning repository
    models = {
        "encoder.pt": "1q8mEGwCkFy23KZsinbuvdKAQLqNKbYf1",
        "synthesizer.pt": "1EqFMIbvxffxtjiVrtykroF6_mUh-5Z3s", 
        "vocoder.pt": "1cf2NO6FtI0jDuy8AV3Xgn6leO6dHjIgu",
    }
    
    print("\n--- Downloading Voice Cloning Models from Google Drive ---\n")
    success_count = 0
    
    for filename, file_id in models.items():
        dest = clone_models_dir / filename
        if dest.exists() and dest.stat().st_size > 1000:  # Check if file is larger than 1KB
            print(f"✓ {filename} already exists (size: {dest.stat().st_size / (1024*1024):.2f} MB)")
            success_count += 1
        else:
            if dest.exists():
                print(f"⚠ {filename} exists but seems corrupted, re-downloading...")
                dest.unlink()
            
            if download_from_gdrive(file_id, dest):
                if dest.exists() and dest.stat().st_size > 1000:
                    print(f"✓ Downloaded {filename} ({dest.stat().st_size / (1024*1024):.2f} MB)")
                    success_count += 1
                else:
                    print(f"✗ Download failed or file corrupted: {filename}")
            else:
                print(f"✗ Failed to download {filename}")
    
    print("\n" + "=" * 60)
    print(f"Download Summary: {success_count}/{len(models)} models ready")
    print("=" * 60)
    
    if success_count == len(models):
        print("\n✓ All models downloaded successfully!")
        print("  You can now use the voice cloning feature.")
    else:
        print("\n⚠ Some models failed to download.")
        print("  The system will use mock audio for missing components.")
        print("\nTroubleshooting:")
        print("  1. Check your internet connection")
        print("  2. Try running the script again")
        print("  3. Manually download from: https://github.com/CorentinJ/Real-Time-Voice-Cloning")
    
    print("\nNote: Profile-based TTS will use fallback audio generation")
    print("      until Parrot TTS models are provided.\n")

if __name__ == "__main__":
    main()
