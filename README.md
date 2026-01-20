# Parrot 🦜

Parrot is a cutting-edge Flutter application designed to bridge the communication gap for individuals using sign language. It provides real-time gesture-to-speech translation with personalized voice cloning technology.

## 🚀 Features

- **Real-Time Translation**: Convert sign language gestures into text instantly using advanced computer vision.
- **Voice Studio**: Create and manage personalized AI voice clones that sound just like the user.
- **Voice Messenger**: A built-in Text-to-Speech tool for quick, typed communication.
- **Emotion Detection**: Integrated emotion indicators that adjust based on gesture intensity and sentiment.
- **Interactive HUD**: An editable transcription area that allows users to refine translated text before speaking it out.
- **Premium UI**: A sleek, dark-themed interface built with Flutter's latest Material 3 components and Lucide icons.

## 🛠 Tech Stack

- **Frontend Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: Flutter Riverpod & ValueNotifier
- **Backend Framework**: Flask (Python) with Socket.IO
- **AI/ML**:
  - **Video Processing**: MediaPipe (Hand Tracking) + TensorFlow Lite (Gesture Classification)
  - **Voice Cloning**: Real-Time Voice Cloning (Encoder/Synthesizer/Vocoder)
  - **TTS**: Parrot/SYSPIN (Standard fallback)

## 📱 Getting Started

### Prerequisites

- **Flutter SDK** (Latest Stable)
- **Python 3.8+**
- **Git**

---

### Step 1: Backend Setup

The project requires a Python backend for video processing and voice cloning.

1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```

2.  Install Python dependencies:
    ```bash
    pip install -r requirements.txt
    ```

3.  Download required AI models (Voice Cloning):
    ```bash
    python download_models.py
    ```

4.  Run the server:
    ```bash
    python server.py
    ```
    The server listens on `http://127.0.0.1:5000` (or `0.0.0.0:5000`).

---

### Step 2: Application Setup

1.  Open a new terminal in the root directory.
2.  Install Flutter dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```

---

## 🧠 Customizing Gestures & Training

You can train Parrot to recognize your own custom gestures or new words.

### 1. Update Labels
Edit `backend/video/model/keypoint_classifier/keypoint_classifier_label.csv` and add your new word labels (one per line).

### 2. Collect Data
Run the data collector script to capture your hand movements for each word.
```bash
cd backend/video
python keypoint_collector.py
```
*   Use keys **0-9** for the first 10 labels and **a-z** for subsequent labels.
*   Press and hold the key while performing the gesture to record data frames.
*   Collect ~100-200 frames per gesture for best results.
*   Press 'q' to save and exit.

### 3. Train the Model
Run the training script to generate a new AI model based on your collected data.
```bash
cd backend/video
python train_classifier.py
```
This will automatically save the new `keypoint_classifier.tflite` model.

### 4. Restart Server
Restart the backend server to apply changes:
```bash
python server.py
```

---

## 📂 Backend Directory Structure

*   **`server.py`**: Main Flask entry point. Handles WebSockets & API.
*   **`video/`**: Sign Language detection modules.
    *   `keypoint_collector.py`: Data collection tool.
    *   `train_classifier.py`: Model training script.
    *   `model/`: Stores `hand_landmarker.task` and `keypoint_classifier.tflite`.
*   **`clone/`**: Real-Time Voice Cloning engine.
    *   `voice_cloning.py`: Logic for loading and running RTVC.
    *   `saved_models/`: Stores `encoder.pt`, `synthesizer.pt`, `vocoder.pt`.
*   **`tts/`**: Standard TTS fallback system.

## 📱 Frontend Directory Structure

*   `lib/core`: Theme, Router, and Global Configs.
*   `lib/screens/home`: Real-time translation hub (`CommunicationHub`).
*   `lib/screens/voice_studio`: Voice library and creation (`VoiceCreationWizard`).
*   `lib/screens/tts`: Text-to-Speech text input screen (`TTSScreen`).
*   `lib/services`: `ApiService` for communicating with the backend.
*   `lib/providers`: Global state (User voice, Translated text).


