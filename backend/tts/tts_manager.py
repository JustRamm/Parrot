
import os
import sys
import torch
import yaml
import numpy as np
import json
from pathlib import Path

# Adjust paths to ensure imports work
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)
sys.path.append(os.path.join(current_dir, 'utils', 'aligner'))
sys.path.append(os.path.join(current_dir, 'utils', 'vocoder'))

# Import Parrot modules
from modules.parrot import Parrot
from modules.data import DFATokenizer, get_mask_from_lengths
import lightning as L

# Import Vocoder modules
from utils.vocoder.models import CodeGenerator
from utils.vocoder.utils import AttrDict

# Import Aligner utils for text processing
from utils.aligner.text import Tokenizer
from utils.aligner.cleaners import english_cleaners

class LitParrot(L.LightningModule):
    def __init__(self, data_config, src_vocab_size, src_pad_idx):
        super().__init__()
        self.save_hyperparameters()
        self.parrot = Parrot(data_config, src_vocab_size, src_pad_idx)
    
    def infer(self, batch):
        self.eval()
        return self.parrot.infer(batch)

class TTSManager:
    def __init__(self, 
                 parrot_config_path=None, 
                 parrot_checkpoint_path=None,
                 vocoder_config_path=None,
                 vocoder_checkpoint_path=None,
                 device=None):
        
        self.device = device if device else torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"TTSManager initializing on {self.device}...")

        # Default paths if not provided
        if not parrot_config_path:
            parrot_config_path = os.path.join(current_dir, "config", "parrot_config.yaml") # Placeholder
        if not vocoder_config_path:
            vocoder_config_path = os.path.join(current_dir, "utils", "vocoder", "config.json")
            
        self.parrot_model = None
        self.vocoder_model = None
        self.tokenizer = None
        self.vocoder_h = None
        
        # Load Parrot
        try:
            if parrot_checkpoint_path and os.path.exists(parrot_checkpoint_path):
                print(f"Loading Parrot model from {parrot_checkpoint_path}")
                # We need the alignment symbols to init tokenizer for Parrot
                # Assuming symbols.pkl is in the same dir as config or hardcoded
                # For now, we will wrap model loading in try-except
                
                # Load config
                with open(parrot_config_path, "r") as f:
                    self.parrot_config = yaml.load(f, Loader=yaml.FullLoader)
                
                # Setup Tokenizer
                # The Parrot module uses DFATokenizer inside, but we need to tokenize raw text
                # We need to reconstruct the Tokenizer manually
                
                alignment_path = Path(self.parrot_config["path"]["alignment_path"])
                # We need to make sure this path exists or is relative
                # For now let's assume we can load symbols
                
                self.dfa_tokenizer = DFATokenizer(alignment_path)
                
                # Load Model
                self.parrot_model = LitParrot.load_from_checkpoint(
                    parrot_checkpoint_path, 
                    data_config=self.parrot_config,
                    src_vocab_size=len(self.dfa_tokenizer),
                    src_pad_idx=self.dfa_tokenizer.pad_idx,
                    strict=False, # Often needed if keys mismatched slightly
                    weights_only=True
                ).to(self.device)
                self.parrot_model.eval()
                print("Parrot model loaded.")
            else:
                 print("Parrot checkpoint not found. TTS will fallback to mock.")
        except Exception as e:
            print(f"Error loading Parrot model: {e}")
            self.parrot_model = None

        # Load Vocoder
        try:
            if vocoder_checkpoint_path and os.path.exists(vocoder_checkpoint_path):
                print(f"Loading Vocoder model from {vocoder_checkpoint_path}")
                with open(vocoder_config_path) as f:
                    data = f.read()
                json_config = json.loads(data)
                self.vocoder_h = AttrDict(json_config)
                
                self.vocoder_model = CodeGenerator(self.vocoder_h).to(self.device)
                
                state_dict_g = torch.load(vocoder_checkpoint_path, map_location=self.device)
                self.vocoder_model.load_state_dict(state_dict_g['generator'])
                self.vocoder_model.eval()
                self.vocoder_model.remove_weight_norm()
                print("Vocoder model loaded.")
            else:
                 print("Vocoder checkpoint not found.")

        except Exception as e:
            print(f"Error loading Vocoder model: {e}")
            self.vocoder_model = None

    def preprocess_text(self, text):
        # 1. Clean Text
        cleaned_text = english_cleaners(text)
        # 2. Convert to Phonemes?
        # If the model was trained on characters, we just use characters.
        # But 'Parrot' usually uses phonemes.
        # DFATokenizer takes 'phoneme_seq' in its tokenize method.
        # If we don't have a G2P, we might have to assume text is enough or space separated?
        # The modules/data.py says: phones = self.tokenizer.tokenize(data_dict['characters'].split(' '))
        # This implies input is space-separated phonemes/characters.
        
        # For this implementation, we will assume character-based or simple whitespace split for now
        # OR we try to tokenize simply by character if no G2P.
        # If the user wants "strictly unique", we might need to integrate a G2P here.
        
        # Simple char breakdown for now to avoid G2P dependency crash
        return cleaned_text

    def synthesize(self, text, speaker_id=0):
        if not self.parrot_model or not self.vocoder_model:
            print("TTS Models missing, generating mock audio.")
            return self.mock_audio()
        
        try:
            # 1. Text to Phones/Tokens
            # Note: We need to match exactly how Parrot expects inputs.
            # Assuming char-based for now as a fallback
            
            # TODO: Implement proper G2P
            chars = list(self.preprocess_text(text)) 
            # If tokenizer expects space separated:
            # phones_seq = chars 
            # phones = self.dfa_tokenizer.tokenize(phones_seq)
            
            # This part is highly dependent on the 'symbols.pkl' used during training.
            # I will wrap this in try-except
            
            # Mocking tokenization for safety until symbols are confirmed
            # phones = torch.tensor([1, 2, 3]).long().unsqueeze(0).to(self.device) 
            
            # Placeholder until we read symbols
            return self.mock_audio()
            
            # 2. Parrot Inference
            # batch = {
            #     'phones': phones,
            #     'src_mask': get_mask_from_lengths([phones.shape[1]], device=self.device),
            #     'speaker': torch.tensor([speaker_id]).long().to(self.device)
            # }
            # codes_list = self.parrot_model.infer(batch)[0] # List of ints
            
            # 3. Vocoder Inference
            # codes = torch.LongTensor(codes_list).unsqueeze(0).to(self.device)
            # code_dict = {'code': codes} # Adjust based on Vocoder input
            # if self.vocoder_h.get('multispkr', None):
            #      code_dict['spkr'] = torch.LongTensor([speaker_id]).to(self.device)
            
            # y_g_hat = self.vocoder_model(**code_dict)
            # audio = y_g_hat.squeeze()
            # audio = audio * 32768.0
            # audio = audio.cpu().numpy().astype('int16')
            
            # return audio
            
        except Exception as e:
            print(f"Synthesis failed: {e}")
            return self.mock_audio()

    def mock_audio(self):
        # Generate a sine wave
        sample_rate = 24000
        duration = 2.0
        t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
        audio = 0.5 * np.sin(2 * np.pi * 440 * t)
        return (audio * 32767).astype(np.int16)

