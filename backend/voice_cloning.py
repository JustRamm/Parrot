
import os
import numpy as np
import threading
from pathlib import Path

# Try imports, handle if components are missing
try:
    from encoder.inference import load_model as load_encoder
    from encoder.inference import embed_utterance, preprocess_wav
    from synthesizer.inference import Synthesizer
    from vocoder.inference import load_model as load_vocoder
    from vocoder.inference import infer_waveform
except ImportError as e:
    print(f"Warning: Voice cloning modules not found: {e}")

class VoiceCloningManager:
    def __init__(self, models_dir="saved_models"):
        self.models_dir = Path(models_dir)
        self.encoder_loaded = False
        self.synthesizer_loaded = False
        self.vocoder_loaded = False
        self.synthesizer = None
        self.lock = threading.Lock()
        
        # Check if models directory exists
        if not self.models_dir.exists():
            print(f"Warning: Models directory {self.models_dir} does not exist.")
            return

        self._load_models()

    def _load_models(self):
        try:
            # Encoder
            enc_path = self.models_dir / "encoder.pt"
            if enc_path.exists():
                load_encoder(enc_path)
                self.encoder_loaded = True
                print("Encoder loaded.")
            
            # Synthesizer
            syn_path = self.models_dir / "synthesizer.pt"
            if syn_path.exists():
                self.synthesizer = Synthesizer(syn_path)
                self.synthesizer_loaded = True
                print("Synthesizer loaded.")

            # Vocoder
            voc_path = self.models_dir / "vocoder.pt"
            if voc_path.exists():
                load_vocoder(voc_path)
                self.vocoder_loaded = True
                print("Vocoder loaded.")
                
        except Exception as e:
            print(f"Error loading voice models: {e}")

    def clone_voice(self, audio_data, sample_rate=16000):
        """
        Process audio data to create a speaker embedding.
        Returns: embedding ID (or the embedding itself as list)
        """
        if not self.encoder_loaded:
            return {"error": "Encoder model not loaded"}
        
        try:
            # Preprocess the wav
            # In a real scenario, we might need to write the bytes to a temp file
            # or convert the raw bytes to numpy array
            
            # For simplicity, assuming audio_data is already a numpy array of the wav
            # If it's raw bytes, we need to decode it.
            
            # If input is raw bytes from a request:
            # wav = preprocess_wav(io.BytesIO(audio_data)) 
            
            # Here we assume preprocessed wav for now
            preprocessed_wav = preprocess_wav(audio_data)
            embed = embed_utterance(preprocessed_wav)
            return {"embedding": embed.tolist(), "success": True}
        except Exception as e:
            return {"error": str(e), "success": False}

    def synthesize(self, text, embedding_list):
        """
        Synthesize speech from text and embedding.
        """
        if not (self.synthesizer_loaded and self.vocoder_loaded):
             return None, "Models not loaded"
             
        try:
            embed = np.array(embedding_list)
            
            # Synthesizer
            # The synthesizer expects a list of texts and embeddings
            specs = self.synthesizer.synthesize_spectrograms([text], [embed])
            spec = specs[0]
            
            # Vocoder
            generated_wav = infer_waveform(spec)
            
            # Resize/Normalise if needed
            generated_wav = np.pad(generated_wav, (0, self.synthesizer.sample_rate), mode="constant")
            generated_wav = generated_wav / np.abs(generated_wav).max() * 0.97
            
            return generated_wav, None
        except Exception as e:
            return None, str(e)
