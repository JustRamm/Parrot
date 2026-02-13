#!/usr/bin/env python
"""
Voice Cloning Setup Script
This script helps you set up the voice cloning backend by:
1. Installing required dependencies
2. Downloading pretrained models
3. Verifying the installation
"""

import subprocess
import sys
import os
from pathlib import Path

def print_header(text):
    """Print a formatted header"""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70 + "\n")

def run_command(cmd, description):
    """Run a command and handle errors"""
    print(f"→ {description}...")
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        print(f"✓ {description} completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ {description} failed")
        print(f"  Error: {e.stderr}")
        return False

def check_python_version():
    """Check if Python version is compatible"""
    print_header("Checking Python Version")
    version = sys.version_info
    print(f"Python version: {version.major}.{version.minor}.{version.micro}")
    
    if version.major == 3 and version.minor >= 8:
        print("✓ Python version is compatible")
        return True
    else:
        print("✗ Python 3.8 or higher is required")
        return False

def install_dependencies():
    """Install required Python packages"""
    print_header("Installing Dependencies")
    
    script_dir = Path(__file__).parent
    requirements_file = script_dir / "requirements.txt"
    
    if not requirements_file.exists():
        print(f"✗ requirements.txt not found at {requirements_file}")
        return False
    
    print(f"Installing packages from {requirements_file}...")
    return run_command(
        f'pip install -r "{requirements_file}"',
        "Installing Python packages"
    )

def download_models():
    """Download pretrained voice cloning models"""
    print_header("Downloading Voice Cloning Models")
    
    script_dir = Path(__file__).parent
    download_script = script_dir / "download_models.py"
    
    if not download_script.exists():
        print(f"✗ download_models.py not found at {download_script}")
        return False
    
    return run_command(
        f'python "{download_script}"',
        "Downloading models"
    )

def verify_installation():
    """Verify that all components are properly installed"""
    print_header("Verifying Installation")
    
    script_dir = Path(__file__).parent
    models_dir = script_dir / "clone" / "saved_models"
    
    required_models = ["encoder.pt", "synthesizer.pt", "vocoder.pt"]
    all_present = True
    
    for model_name in required_models:
        model_path = models_dir / model_name
        if model_path.exists() and model_path.stat().st_size > 1000:
            size_mb = model_path.stat().st_size / (1024 * 1024)
            print(f"✓ {model_name} found ({size_mb:.2f} MB)")
        else:
            print(f"✗ {model_name} missing or corrupted")
            all_present = False
    
    # Try importing key modules
    print("\nChecking Python modules...")
    modules_to_check = [
        "torch", "numpy", "librosa", "soundfile", 
        "scipy", "sklearn", "flask", "flask_socketio"
    ]
    
    for module in modules_to_check:
        try:
            __import__(module)
            print(f"✓ {module} installed")
        except ImportError:
            print(f"✗ {module} not installed")
            all_present = False
    
    return all_present

def main():
    """Main setup function"""
    print_header("Voice Cloning Backend Setup")
    print("This script will set up the voice cloning backend for your application.")
    print("Please ensure you have a stable internet connection.")
    
    input("\nPress Enter to continue...")
    
    # Step 1: Check Python version
    if not check_python_version():
        print("\n⚠ Please upgrade Python to version 3.8 or higher")
        return False
    
    # Step 2: Install dependencies
    if not install_dependencies():
        print("\n⚠ Failed to install dependencies. Please check the error messages above.")
        return False
    
    # Step 3: Download models
    if not download_models():
        print("\n⚠ Failed to download models. You may need to download them manually.")
        print("   Visit: https://github.com/CorentinJ/Real-Time-Voice-Cloning")
    
    # Step 4: Verify installation
    if verify_installation():
        print_header("Setup Complete!")
        print("✓ All components are properly installed")
        print("\nYou can now run the backend server:")
        print("  python server.py")
        return True
    else:
        print_header("Setup Incomplete")
        print("⚠ Some components are missing or not properly installed")
        print("\nPlease review the errors above and:")
        print("  1. Ensure all dependencies are installed")
        print("  2. Download missing models manually if needed")
        print("  3. Run this script again to verify")
        return False

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠ Setup cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n✗ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
