
import os
import numpy as np
import threading
from pathlib import Path

# Try imports, handle if components are missing
try:
    from encoder import inference as encoder
    from synthesizer.inference import Synthesizer
    from vocoder import inference as vocoder
    MODULES_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Voice cloning modules not found: {e}")
    MODULES_AVAILABLE = False

class VoiceCloningManager:
    def __init__(self, models_dir="saved_models"):
        self.models_dir = Path(models_dir)
        self.encoder_loaded = False
        self.synthesizer_loaded = False
        self.vocoder_loaded = False
        self.synthesizer = None
        self.lock = threading.Lock()
        
        print(f"Initializing Voice Cloning Manager...")
        print(f"Models directory: {self.models_dir.absolute()}")
        
        # Check if models directory exists
        if not self.models_dir.exists():
            print(f"⚠ Models directory {self.models_dir} does not exist. Creating it...")
            self.models_dir.mkdir(parents=True, exist_ok=True)
            print(f"⚠ Please run 'python download_models.py' to download required models.")
            return

        if not MODULES_AVAILABLE:
            print(f"⚠ Voice cloning modules not available. Using mock mode.")
            return

        self._load_models()

    def _load_models(self):
        """Load all three models required for voice cloning"""
        try:
            # Encoder
            enc_path = self.models_dir / "encoder.pt"
            if enc_path.exists() and enc_path.stat().st_size > 1000:
                print(f"Loading encoder from {enc_path}...")
                encoder.load_model(enc_path)
                self.encoder_loaded = True
                print("✓ Encoder loaded successfully.")
            else:
                if enc_path.exists():
                    print(f"⚠ Encoder file exists but is too small ({enc_path.stat().st_size} bytes)")
                else:
                    print(f"⚠ Encoder model not found at {enc_path}")
            
            # Synthesizer
            syn_path = self.models_dir / "synthesizer.pt"
            if syn_path.exists() and syn_path.stat().st_size > 1000:
                print(f"Loading synthesizer from {syn_path}...")
                self.synthesizer = Synthesizer(syn_path)
                self.synthesizer_loaded = True
                print("✓ Synthesizer loaded successfully.")
            else:
                if syn_path.exists():
                    print(f"⚠ Synthesizer file exists but is too small ({syn_path.stat().st_size} bytes)")
                else:
                    print(f"⚠ Synthesizer model not found at {syn_path}")

            # Vocoder
            voc_path = self.models_dir / "vocoder.pt"
            if voc_path.exists() and voc_path.stat().st_size > 1000:
                print(f"Loading vocoder from {voc_path}...")
                vocoder.load_model(voc_path)
                self.vocoder_loaded = True
                print("✓ Vocoder loaded successfully.")
            else:
                if voc_path.exists():
                    print(f"⚠ Vocoder file exists but is too small ({voc_path.stat().st_size} bytes)")
                else:
                    print(f"⚠ Vocoder model not found at {voc_path}")
            
            # Summary
            if self.encoder_loaded and self.synthesizer_loaded and self.vocoder_loaded:
                print("\n✓ All voice cloning models loaded successfully!")
            else:
                print("\n⚠ Some models failed to load. Voice cloning will use mock mode.")
                print("  Run 'python download_models.py' to download missing models.")
                
        except Exception as e:
            print(f"✗ Error loading voice models: {e}")
            import traceback
            traceback.print_exc()

    def clone_voice(self, audio_data, sample_rate=16000):
        """
        Process audio data to create a speaker embedding.
        
        Args:
            audio_data: Either a file path (str/Path) or numpy array of audio samples
            sample_rate: Sample rate of the audio (if numpy array)
            
        Returns: 
            dict with 'embedding', 'success', and optionally 'is_mock' keys
        """
        if not self.encoder_loaded or not MODULES_AVAILABLE:
            print("⚠ Encoder model not loaded. Returning MOCK embedding for demonstration.")
            # Return a random 256-dimensional embedding
            mock_embedding = np.random.uniform(-0.1, 0.1, 256).tolist()
            return {"embedding": mock_embedding, "success": True, "is_mock": True}
        
        try:
            # Preprocess the wav
            # encoder.preprocess_wav can handle both file paths and numpy arrays
            if isinstance(audio_data, (str, Path)):
                preprocessed_wav = encoder.preprocess_wav(audio_data)
            else:
                # If it's a numpy array, we need to specify the source sample rate
                preprocessed_wav = encoder.preprocess_wav(audio_data, source_sr=sample_rate)
            
            # Generate embedding
            embed = encoder.embed_utterance(preprocessed_wav)
            
            return {
                "embedding": embed.tolist(), 
                "success": True,
                "is_mock": False
            }
        except Exception as e:
            print(f"✗ Error in clone_voice: {e}")
            import traceback
            traceback.print_exc()
            return {"error": str(e), "success": False}

    def synthesize(self, text, embedding_list):
        """
        Synthesize speech from text and embedding.
        
        Args:
            text: Text to synthesize
            embedding_list: Speaker embedding as a list/array
            
        Returns:
            tuple: (generated_wav, error_message)
        """
        if not (self.synthesizer_loaded and self.vocoder_loaded) or not MODULES_AVAILABLE:
            print("⚠ Synthesizer/Vocoder models not loaded. Returning MOCK audio.")
            # Generate 2 seconds of a simple sine wave (beep) to simulate audio response
            sample_rate = 22050  # Standard for these models
            duration = 1.5
            t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
            # A pleasant A4 tone (440Hz) with fade in/out
            fade_samples = int(sample_rate * 0.05)  # 50ms fade
            envelope = np.ones_like(t)
            envelope[:fade_samples] = np.linspace(0, 1, fade_samples)
            envelope[-fade_samples:] = np.linspace(1, 0, fade_samples)
            generated_wav = 0.3 * np.sin(2 * np.pi * 440 * t) * envelope
            return generated_wav, None
             
        try:
            embed = np.array(embedding_list)
            
            # Synthesizer - generate mel spectrogram
            print(f"Synthesizing text: '{text[:50]}...'")
            specs = self.synthesizer.synthesize_spectrograms([text], [embed])
            spec = specs[0]
            
            # Vocoder - convert spectrogram to waveform
            print(f"Generating waveform...")
            generated_wav = vocoder.infer_waveform(spec)
            
            # Normalize
            generated_wav = generated_wav / (np.abs(generated_wav).max() + 1e-8) * 0.95
            
            print(f"✓ Synthesis complete. Audio length: {len(generated_wav)/self.synthesizer.sample_rate:.2f}s")
            
            return generated_wav, None
        except Exception as e:
            print(f"✗ Error in synthesize: {e}")
            import traceback
            traceback.print_exc()
            return None, str(e)

