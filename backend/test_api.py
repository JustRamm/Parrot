"""
API Test Script for Voice Cloning Backend

This script tests the voice cloning and synthesis endpoints.
Make sure the server is running before executing this script.
"""

import requests
import json
import sys
from pathlib import Path

def test_server_connection():
    """Test if the server is running"""
    print("Testing server connection...")
    try:
        response = requests.get('http://localhost:5000/', timeout=5)
        if response.status_code == 200:
            print("✓ Server is running")
            return True
        else:
            print(f"⚠ Server responded with status code: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("✗ Cannot connect to server. Is it running?")
        print("  Start the server with: python server.py")
        return False
    except Exception as e:
        print(f"✗ Error connecting to server: {e}")
        return False

def test_synthesis_with_profile(profile="Natural"):
    """Test speech synthesis with a voice profile"""
    print(f"\nTesting synthesis with '{profile}' profile...")
    
    try:
        response = requests.post(
            'http://localhost:5000/synthesize',
            json={
                'text': f'Hello! This is a test of the {profile} voice profile.',
                'voice_profile': profile
            },
            timeout=30
        )
        
        if response.status_code == 200:
            output_file = f'test_output_{profile.lower()}.wav'
            with open(output_file, 'wb') as f:
                f.write(response.content)
            
            file_size = len(response.content)
            print(f"✓ Synthesis successful")
            print(f"  Audio saved to: {output_file}")
            print(f"  File size: {file_size / 1024:.2f} KB")
            return True
        else:
            print(f"✗ Synthesis failed with status code: {response.status_code}")
            print(f"  Response: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("✗ Request timed out (synthesis may be slow on CPU)")
        return False
    except Exception as e:
        print(f"✗ Error during synthesis: {e}")
        return False

def test_voice_cloning(audio_file_path=None):
    """Test voice cloning endpoint"""
    print("\nTesting voice cloning...")
    
    if audio_file_path is None:
        print("⚠ No audio file provided. Skipping voice cloning test.")
        print("  To test voice cloning, provide a WAV file:")
        print("  python test_api.py path/to/audio.wav")
        return None
    
    audio_path = Path(audio_file_path)
    if not audio_path.exists():
        print(f"✗ Audio file not found: {audio_file_path}")
        return None
    
    try:
        print(f"  Uploading: {audio_path.name}")
        with open(audio_path, 'rb') as f:
            response = requests.post(
                'http://localhost:5000/clone_voice',
                files={'audio': f},
                timeout=30
            )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                embedding = result.get('embedding')
                is_mock = result.get('is_mock', False)
                
                print(f"✓ Voice cloning successful")
                print(f"  Embedding size: {len(embedding)} dimensions")
                
                if is_mock:
                    print(f"  ⚠ Note: Using mock embedding (models not loaded)")
                
                return embedding
            else:
                print(f"✗ Voice cloning failed: {result.get('error')}")
                return None
        else:
            print(f"✗ Request failed with status code: {response.status_code}")
            print(f"  Response: {response.text}")
            return None
            
    except requests.exceptions.Timeout:
        print("✗ Request timed out")
        return None
    except Exception as e:
        print(f"✗ Error during voice cloning: {e}")
        return None

def test_synthesis_with_embedding(embedding):
    """Test speech synthesis with a cloned voice embedding"""
    print("\nTesting synthesis with cloned voice...")
    
    try:
        response = requests.post(
            'http://localhost:5000/synthesize',
            json={
                'text': 'This sentence is using the cloned voice profile.',
                'embedding': embedding
            },
            timeout=30
        )
        
        if response.status_code == 200:
            output_file = 'test_output_cloned.wav'
            with open(output_file, 'wb') as f:
                f.write(response.content)
            
            file_size = len(response.content)
            print(f"✓ Synthesis with cloned voice successful")
            print(f"  Audio saved to: {output_file}")
            print(f"  File size: {file_size / 1024:.2f} KB")
            return True
        else:
            print(f"✗ Synthesis failed with status code: {response.status_code}")
            print(f"  Response: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("✗ Request timed out")
        return False
    except Exception as e:
        print(f"✗ Error during synthesis: {e}")
        return False

def main():
    """Main test function"""
    print("=" * 70)
    print("  Voice Cloning Backend API Test")
    print("=" * 70)
    
    # Check if audio file was provided
    audio_file = sys.argv[1] if len(sys.argv) > 1 else None
    
    # Test 1: Server connection
    if not test_server_connection():
        print("\n" + "=" * 70)
        print("✗ Tests aborted: Server is not running")
        print("=" * 70)
        return False
    
    # Test 2: Synthesis with different profiles
    profiles = ["Natural", "Professional", "Warm"]
    synthesis_results = []
    
    for profile in profiles:
        result = test_synthesis_with_profile(profile)
        synthesis_results.append(result)
    
    # Test 3: Voice cloning (if audio file provided)
    embedding = test_voice_cloning(audio_file)
    
    # Test 4: Synthesis with cloned voice (if cloning succeeded)
    cloned_synthesis_result = False
    if embedding is not None:
        cloned_synthesis_result = test_synthesis_with_embedding(embedding)
    
    # Summary
    print("\n" + "=" * 70)
    print("  Test Summary")
    print("=" * 70)
    
    print(f"\nSynthesis Tests:")
    for i, profile in enumerate(profiles):
        status = "✓" if synthesis_results[i] else "✗"
        print(f"  {status} {profile} profile")
    
    if audio_file:
        print(f"\nVoice Cloning Tests:")
        print(f"  {'✓' if embedding else '✗'} Voice cloning")
        if embedding:
            print(f"  {'✓' if cloned_synthesis_result else '✗'} Synthesis with cloned voice")
    else:
        print(f"\n⚠ Voice cloning tests skipped (no audio file provided)")
    
    all_passed = all(synthesis_results)
    if audio_file:
        all_passed = all_passed and embedding is not None and cloned_synthesis_result
    
    print("\n" + "=" * 70)
    if all_passed:
        print("✓ All tests passed!")
    else:
        print("⚠ Some tests failed. Check the output above for details.")
    print("=" * 70)
    
    return all_passed

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠ Tests cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n✗ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
