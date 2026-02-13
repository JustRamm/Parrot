# TTS Configuration
# This file contains all configurable paths and settings for the TTS system

import os

# Base directory
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.dirname(BASE_DIR)

# Voice Cloning Models
VOICE_CLONING_MODELS_DIR = os.path.join(BACKEND_DIR, 'clone', 'saved_models')
ENCODER_MODEL_PATH = os.path.join(VOICE_CLONING_MODELS_DIR, 'encoder.pt')
SYNTHESIZER_MODEL_PATH = os.path.join(VOICE_CLONING_MODELS_DIR, 'synthesizer.pt')
VOCODER_MODEL_PATH = os.path.join(VOICE_CLONING_MODELS_DIR, 'vocoder.pt')

# TTS Models (Parrot - currently not used)
TTS_MODELS_DIR = os.path.join(BASE_DIR, 'checkpoints')
PARROT_MODEL_PATH = os.path.join(TTS_MODELS_DIR, 'parrot_model.ckpt')
TTS_VOCODER_PATH = os.path.join(TTS_MODELS_DIR, 'vocoder_model.ckpt')

# Configuration files
CONFIG_DIR = os.path.join(BASE_DIR, 'config')
PARROT_CONFIG_PATH = os.path.join(CONFIG_DIR, 'parrot_config.yaml')
VOCODER_CONFIG_PATH = os.path.join(BASE_DIR, 'utils', 'vocoder', 'config.json')

# Audio settings
DEFAULT_SAMPLE_RATE = 24000
CLONED_VOICE_SAMPLE_RATE = 22050
MOCK_AUDIO_SAMPLE_RATE = 24000

# Synthesis settings
MAX_TEXT_LENGTH = 500  # Maximum characters for synthesis
MIN_AUDIO_DURATION = 0.5  # Minimum audio duration in seconds
MAX_AUDIO_DURATION = 10.0  # Maximum audio duration in seconds

# Voice profiles
VOICE_PROFILES = {
    'Natural': {
        'speaker_id': 0,
        'description': 'Neutral, clear voice'
    },
    'Professional': {
        'speaker_id': 1,
        'description': 'Formal, authoritative voice'
    },
    'Warm': {
        'speaker_id': 2,
        'description': 'Friendly, approachable voice'
    }
}

# Device settings
USE_CUDA = True  # Set to False to force CPU
CUDA_DEVICE_ID = 0  # GPU device ID if multiple GPUs available

# Logging
VERBOSE_LOGGING = True
LOG_SYNTHESIS_TIME = True

# Error handling
MAX_SYNTHESIS_RETRIES = 2
SYNTHESIS_TIMEOUT = 30  # seconds

# Model validation
MIN_MODEL_SIZE_BYTES = 1000  # Minimum file size to consider model valid
VALIDATE_MODELS_ON_STARTUP = True

# Cache settings (future enhancement)
ENABLE_AUDIO_CACHE = False
CACHE_DIR = os.path.join(BASE_DIR, 'cache')
MAX_CACHE_SIZE_MB = 100
