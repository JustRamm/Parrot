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

## 🎓 AI Communication Model Training Guide

Parrot is trained to recognize specific sign language gestures, but you can easily extend it to understand new words or adapt it to your unique hand movements.

### **Step 1: Define Your Words**
The system currently supports **19 gesture classes**. You can rename existing ones or retrain them entirely.

1.  Navigate to the file:
    `backend/video/model/keypoint_classifier/keypoint_classifier_label.csv`
2.  Open it in any text editor.
3.  Each line represents a word class.
    *   Line 1 corresponds to ID `0`
    *   Line 2 corresponds to ID `1`
    *   ...etc.
4.  Change the text of the line you wish to train (e.g., change "Hello" to "Greetings").

### **Step 2: Collect Training Data**
You need to record examples of your hand signs so the AI can learn from them.

1.  Open your terminal and navigate to the video backend:
    ```bash
    cd backend/video
    ```
2.  Launch the data collector:
    ```bash
    python keypoint_collector.py
    ```
3.  **How to Record**:
    *   **IDs 0-9**: Press keys **`0`** through **`9`** on your keyboard.
    *   **IDs 10-18**: Press keys **`a`** through **`i`** on your keyboard.
4.  **Process**:
    *   Perform the gesture in front of the camera.
    *   **Hold down** the corresponding key to log data frames.
    *   Vary your hand position slightly (distance, angle) to make the model robust.
    *   Aim for **100-300 samples** per gesture for high accuracy.
5.  Press `q` to save and exit.

### **Step 3: Train the Neural Network**
This step processes your recorded data into a new AI model file.

1.  In the same `backend/video` directory, run:
    ```bash
    python train_classifier.py
    ```
2.  The script will:
    *   Load the dataset from `keypoint.csv`.
    *   Train the model using TensorFlow.
    *   Print the validation accuracy (aim for >90%).
    *   Automatically export the new `keypoint_classifier.tflite` model.

### **Step 4: Activate Changes**
To see your new gestures in action:

1.  Restart the backend server:
    ```bash
    # Go back to backend root if needed
    cd ..
    python server.py
    ```
2.  Restart the Flutter application to refresh the labels (if they were changed).

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


