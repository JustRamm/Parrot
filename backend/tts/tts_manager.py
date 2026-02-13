import os
import sys
import torch
import numpy as np
from pathlib import Path

# Add clone path for voice cloning TTS
current_dir = os.path.dirname(os.path.abspath(__file__))
clone_dir = os.path.join(os.path.dirname(current_dir), 'clone')
sys.path.insert(0, clone_dir)

class TTSManager:
    """
    Unified TTS Manager that handles both voice cloning and profile-based synthesis.
    Falls back gracefully when models are not available.
    """
    
    def __init__(self, 
                 parrot_checkpoint_path=None, 
                 vocoder_checkpoint_path=None,
                 device=None):
        
        self.device = device if device else torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"TTSManager initializing on {self.device}...")
        
        # Try to import voice cloning modules
        self.voice_cloning_available = False
        try:
            from synthesizer.inference import Synthesizer
            from vocoder import inference as vocoder
            self.Synthesizer = Synthesizer
            self.vocoder = vocoder
            self.voice_cloning_available = True
            print("✓ Voice cloning modules available")
        except ImportError as e:
            print(f"⚠ Voice cloning modules not available: {e}")
        
        # Initialize voice cloning models for profile-based TTS
        self.synthesizer = None
        self.vocoder_loaded = False
        
        # Speaker profiles with pre-generated embeddings (will be created if models available)
        self.speaker_profiles = {
            'Natural': None,
            'Professional': None,
            'Warm': None
        }
        
        # Load models if available
        self._load_models()
    
    def _load_models(self):
        """Load voice cloning models for profile-based TTS"""
        if not self.voice_cloning_available:
            print("⚠ Skipping model loading - voice cloning modules not available")
            return
        
        try:
            # Try to load synthesizer
            clone_models_dir = os.path.join(os.path.dirname(current_dir), 'clone', 'saved_models')
            syn_path = os.path.join(clone_models_dir, 'synthesizer.pt')
            voc_path = os.path.join(clone_models_dir, 'vocoder.pt')
            
            if os.path.exists(syn_path) and os.path.getsize(syn_path) > 1000:
                print(f"Loading synthesizer from {syn_path}...")
                self.synthesizer = self.Synthesizer(syn_path)
                print("✓ Synthesizer loaded")
            else:
                print(f"⚠ Synthesizer not found at {syn_path}")
            
            if os.path.exists(voc_path) and os.path.getsize(voc_path) > 1000:
                print(f"Loading vocoder from {voc_path}...")
                self.vocoder.load_model(voc_path)
                self.vocoder_loaded = True
                print("✓ Vocoder loaded")
            else:
                print(f"⚠ Vocoder not found at {voc_path}")
            
            # Generate default speaker embeddings if models loaded
            if self.synthesizer and self.vocoder_loaded:
                self._generate_default_embeddings()
            
        except Exception as e:
            print(f"⚠ Error loading TTS models: {e}")
            self.synthesizer = None
            self.vocoder_loaded = False
    
    def _generate_default_embeddings(self):
        """Generate default speaker embeddings for voice profiles"""
        try:
            # Create slightly different random embeddings for each profile
            # In production, these would be from actual voice samples
            np.random.seed(42)  # For consistency
            
            # Natural: neutral embedding
            self.speaker_profiles['Natural'] = np.random.randn(256).astype(np.float32) * 0.05
            
            # Professional: slightly different
            np.random.seed(43)
            self.speaker_profiles['Professional'] = np.random.randn(256).astype(np.float32) * 0.05
            
            # Warm: slightly different
            np.random.seed(44)
            self.speaker_profiles['Warm'] = np.random.randn(256).astype(np.float32) * 0.05
            
            print("✓ Default speaker profiles generated")
            
        except Exception as e:
            print(f"⚠ Error generating default embeddings: {e}")
    
    def synthesize(self, text, speaker_id=0, embedding=None):
        """
        Synthesize speech from text.
        
        Priority:
        1. Use provided embedding (cloned voice)
        2. Use speaker profile embedding
        3. Fall back to mock audio
        
        Args:
            text: Text to synthesize
            speaker_id: Speaker ID (0=Natural, 1=Professional, 2=Warm)
            embedding: Optional voice embedding from voice cloning
            
        Returns:
            numpy array of audio samples (int16 or float32)
        """
        
        # Map speaker_id to profile name
        profile_names = ['Natural', 'Professional', 'Warm']
        profile_name = profile_names[speaker_id] if 0 <= speaker_id < 3 else 'Natural'
        
        # Priority 1: Use provided embedding (cloned voice)
        if embedding is not None:
            return self._synthesize_with_embedding(text, embedding)
        
        # Priority 2: Use speaker profile embedding
        if self.speaker_profiles.get(profile_name) is not None:
            return self._synthesize_with_embedding(text, self.speaker_profiles[profile_name])
        
        # Priority 3: Fall back to mock audio
        print(f"⚠ Using mock audio for '{profile_name}' profile")
        return self._generate_mock_audio(speaker_id, text)
    
    def _synthesize_with_embedding(self, text, embedding):
        """Synthesize using voice cloning with embedding"""
        if not self.synthesizer or not self.vocoder_loaded:
            print("⚠ Models not loaded, using mock audio")
            return self._generate_mock_audio(0, text)
        
        try:
            # Ensure embedding is numpy array
            if isinstance(embedding, list):
                embedding = np.array(embedding, dtype=np.float32)
            
            # Synthesize mel spectrogram
            specs = self.synthesizer.synthesize_spectrograms([text], [embedding])
            spec = specs[0]
            
            # Generate waveform
            wav = self.vocoder.infer_waveform(spec)
            
            # Normalize
            wav = wav / (np.abs(wav).max() + 1e-8) * 0.95
            
            print(f"✓ Synthesized: '{text[:30]}...' ({len(wav)/self.synthesizer.sample_rate:.2f}s)")
            
            return wav
            
        except Exception as e:
            print(f"✗ Synthesis failed: {e}")
            import traceback
            traceback.print_exc()
            return self._generate_mock_audio(0, text)
    
    def _generate_mock_audio(self, speaker_id, text):
        """Generate mock audio with varying characteristics based on speaker_id"""
        sample_rate = 24000
        
        # Duration based on text length (rough estimate: 10 chars per second)
        duration = max(1.0, min(5.0, len(text) / 10.0))
        
        # Frequency varies by speaker
        frequencies = {
            0: 440,   # Natural - A4
            1: 380,   # Professional - Lower
            2: 520    # Warm - Higher
        }
        freq = frequencies.get(speaker_id, 440)
        
        t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
        
        # Create a more pleasant tone with harmonics
        audio = 0.3 * np.sin(2 * np.pi * freq * t)  # Fundamental
        audio += 0.15 * np.sin(2 * np.pi * freq * 2 * t)  # 2nd harmonic
        audio += 0.075 * np.sin(2 * np.pi * freq * 3 * t)  # 3rd harmonic
        
        # Add fade in/out
        fade_samples = int(sample_rate * 0.05)  # 50ms fade
        fade_in = np.linspace(0, 1, fade_samples)
        fade_out = np.linspace(1, 0, fade_samples)
        
        audio[:fade_samples] *= fade_in
        audio[-fade_samples:] *= fade_out
        
        return (audio * 32767).astype(np.int16)
    
    def is_ready(self):
        """Check if TTS is ready for synthesis"""
        return self.synthesizer is not None and self.vocoder_loaded
    
    def get_status(self):
        """Get current TTS status"""
        return {
            'voice_cloning_available': self.voice_cloning_available,
            'synthesizer_loaded': self.synthesizer is not None,
            'vocoder_loaded': self.vocoder_loaded,
            'ready': self.is_ready(),
            'device': str(self.device),
            'profiles_available': list(self.speaker_profiles.keys())
        }
