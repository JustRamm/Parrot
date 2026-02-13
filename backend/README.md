# 🎤 Voice Cloning Backend with Sign Language TTS

## 🚀 Quick Start

```bash
# Start the server
cd "c:\Users\abira\OneDrive\Desktop\final year project\backend"
python server.py
```

Server runs on `http://localhost:5000`

---

## ✨ New Features

### 🎯 **Automatic Text-to-Speech for Sign Language**
- Detected signs are automatically converted to speech
- Uses cloned voice or voice profiles
- Real-time audio streaming via SocketIO
- Toggle auto-speak on/off

### 🗣️ **Voice Profile Management**
- Clone any voice and use it for sign language TTS
- Switch between Natural, Professional, Warm, or Cloned voices
- Persistent voice settings across sessions

---

## 📋 Setup (First Time Only)

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Download Models
```bash
python download_models.py
```

Downloads 3 models (~421 MB):
- encoder.pt (16.3 MB)
- synthesizer.pt (353.39 MB)
- vocoder.pt (51.35 MB)

### 3. Verify Installation
```bash
python test_voice_cloning.py
```

---

## 🎯 API Endpoints

### Sign Language TTS Integration

#### POST `/clone_and_activate_voice`
Clone voice and activate it for sign language TTS

**Request:**
```bash
curl -X POST http://localhost:5000/clone_and_activate_voice \
  -F "audio=@my_voice.wav"
```

**Response:**
```json
{
  "success": true,
  "message": "Voice cloned and activated successfully",
  "is_mock": false,
  "active_profile": {
    "type": "Cloned",
    "has_cloned_voice": true,
    "auto_speak": true
  }
}
```

#### POST `/set_voice_profile`
Set active voice profile for sign language TTS

**Request:**
```json
{
  "voice_type": "Professional",  // Natural, Professional, Warm, or Cloned
  "embedding": [...],  // Optional: from /clone_voice
  "auto_speak": true
}
```

**Response:**
```json
{
  "success": true,
  "active_profile": {
    "type": "Professional",
    "has_cloned_voice": false,
    "auto_speak": true
  }
}
```

#### GET `/get_voice_status`
Get current voice profile status

**Response:**
```json
{
  "active_profile": {
    "type": "Cloned",
    "has_cloned_voice": true,
    "auto_speak": true
  },
  "available_profiles": ["Natural", "Professional", "Warm", "Cloned"]
}
```

### Voice Cloning (Original)

#### POST `/clone_voice`
Create voice embedding from audio sample

**Request:**
```bash
curl -X POST http://localhost:5000/clone_voice -F "audio=@sample.wav"
```

**Response:**
```json
{
  "embedding": [0.123, -0.456, ...],
  "success": true,
  "is_mock": false
}
```

#### POST `/synthesize`
Generate speech from text

**Request:**
```bash
curl -X POST http://localhost:5000/synthesize \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello world", "voice_profile": "Natural"}' \
  --output output.wav
```

**With cloned voice:**
```json
{
  "text": "Your text here",
  "embedding": [...],  // from /clone_voice
  "voice_profile": "Natural"  // optional
}
```

---

## 🔌 SocketIO Events

### Client → Server

#### `request_speech`
Request speech synthesis for specific text
```javascript
socket.emit('request_speech', { text: 'Hello world' });
```

#### `toggle_auto_speak`
Toggle automatic speech for detected signs
```javascript
socket.emit('toggle_auto_speak', { enabled: true });
```

### Server → Client

#### `text_update`
Sign language text detected
```javascript
socket.on('text_update', (data) => {
  console.log('Detected:', data.text);
});
```

#### `audio_ready`
Audio synthesized and ready to play
```javascript
socket.on('audio_ready', (data) => {
  const audioBlob = base64ToBlob(data.audio, 'audio/wav');
  const audioUrl = URL.createObjectURL(audioBlob);
  const audio = new Audio(audioUrl);
  audio.play();
});
```

#### `auto_speak_status`
Auto-speak status changed
```javascript
socket.on('auto_speak_status', (data) => {
  console.log('Auto-speak:', data.enabled);
});
```

---

## 📱 Flutter Integration

### Clone and Activate Voice
```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> cloneAndActivateVoice(File audioFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://localhost:5000/clone_and_activate_voice'),
  );
  request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
  
  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  var result = json.decode(responseData);
  
  if (result['success']) {
    print('Voice activated: ${result['active_profile']['type']}');
  }
}
```

### Set Voice Profile
```dart
Future<void> setVoiceProfile(String voiceType, {bool autoSpeak = true}) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/set_voice_profile'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'voice_type': voiceType,  // Natural, Professional, Warm
      'auto_speak': autoSpeak,
    }),
  );
  
  if (response.statusCode == 200) {
    print('Voice profile set to: $voiceType');
  }
}
```

### Listen for Audio (SocketIO)
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

class VoiceTTSService {
  late IO.Socket socket;
  final AudioPlayer audioPlayer = AudioPlayer();
  
  void connect() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    
    // Listen for detected text
    socket.on('text_update', (data) {
      print('Detected sign: ${data['text']}');
    });
    
    // Listen for synthesized audio
    socket.on('audio_ready', (data) async {
      final audioBase64 = data['audio'];
      final audioBytes = base64.decode(audioBase64);
      
      // Play audio
      await audioPlayer.play(BytesSource(audioBytes));
      print('Playing: ${data['text']} (${data['voice_type']})');
    });
    
    // Listen for auto-speak status
    socket.on('auto_speak_status', (data) {
      print('Auto-speak: ${data['enabled']}');
    });
  }
  
  void toggleAutoSpeak(bool enabled) {
    socket.emit('toggle_auto_speak', {'enabled': enabled});
  }
  
  void requestSpeech(String text) {
    socket.emit('request_speech', {'text': text});
  }
  
  void disconnect() {
    socket.disconnect();
    audioPlayer.dispose();
  }
}
```

### Complete Example
```dart
// Initialize service
final voiceTTS = VoiceTTSService();
voiceTTS.connect();

// Clone and activate voice
File audioFile = File('path/to/recording.wav');
await cloneAndActivateVoice(audioFile);

// Or use a voice profile
await setVoiceProfile('Professional');

// Toggle auto-speak
voiceTTS.toggleAutoSpeak(true);

// Manual speech request
voiceTTS.requestSpeech('Hello world');

// Cleanup
voiceTTS.disconnect();
```

---

## 🧪 Testing

```bash
# Test system
python test_voice_cloning.py

# Test API
python test_api.py

# Test with your audio
python test_api.py path/to/audio.wav
```

---

## 🔧 Troubleshooting

### Models Not Loading
```bash
# Check models
dir clone\saved_models\*.pt

# Re-download
python download_models.py
```

### Port Already in Use
```bash
# Find process
netstat -ano | findstr :5000

# Kill process
taskkill /PID <process_id> /F
```

### Audio Not Playing
- Check SocketIO connection
- Verify auto_speak is enabled
- Check browser console for errors
- Ensure audio permissions are granted

---

## 📊 Performance

- **Voice Cloning:** 2-3 seconds
- **Synthesis:** 5-10 seconds per sentence
- **Real-time TTS:** ~1-2 second delay
- **Quality:** 22.05 kHz, 16-bit WAV
- **CPU Mode:** Active (GPU optional for 5-10x speedup)

### Enable GPU (Optional)
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

---

## 📁 Project Structure

```
backend/
├── server.py                  # Main Flask server with TTS integration
├── requirements.txt           # Dependencies
├── download_models.py         # Model downloader
├── test_voice_cloning.py      # System test
├── test_api.py               # API test
└── clone/
    ├── voice_cloning.py      # Voice cloning manager
    ├── saved_models/         # Pretrained models
    │   ├── encoder.pt
    │   ├── synthesizer.pt
    │   └── vocoder.pt
    ├── encoder/              # Encoder module
    ├── synthesizer/          # Synthesizer module
    └── vocoder/              # Vocoder module
```

---

## ✨ Features

✅ Real-time voice cloning
✅ **Automatic TTS for sign language detection**
✅ **Voice profile management**
✅ **Real-time audio streaming via SocketIO**
✅ 3 built-in voice profiles + cloned voices
✅ High-quality audio (22.05 kHz)
✅ RESTful API + SocketIO events
✅ Graceful fallback to mock mode
✅ Comprehensive error handling

---

## 🎓 How It Works

1. **Sign Detection** → Camera detects hand signs
2. **Text Recognition** → Signs converted to text
3. **Voice Synthesis** → Text converted to speech using active voice profile
4. **Audio Streaming** → Audio sent to client via SocketIO
5. **Playback** → Client plays audio in real-time

---

## 📚 Resources

- **Original Project:** https://github.com/CorentinJ/Real-Time-Voice-Cloning
- **Paper:** "Transfer Learning from Speaker Verification to Multispeaker Text-To-Speech Synthesis"

---

**Status:** ✅ Fully functional with sign language TTS integration!

**Start the server:** `python server.py`
