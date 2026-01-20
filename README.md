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

- **Framework**: [Flutter](https://flutter.dev)
- **Icons**: [Lucide Icons](https://lucide.dev)
- **State Management**: ValueNotifier & Provider patterns
- **Design System**: Custom minimalist theme with logo-inspired sage, rose, and berry accents.

## 📱 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/JustRamm/Parrot.git
   ```
2. Navigate to the project directory:
   ```bash
   cd parrot
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

### Backend Setup

The project requires a Python backend for video processing.

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the server:
   ```bash
   python server.py
   ```

### Customizing Gestures & Training

You can train Parrot to recognize your own custom gestures or new words.

**1. Update Labels**
Edit `backend/model/keypoint_classifier/keypoint_classifier_label.csv` and add your new word labels (one per line).

**2. Collect Data**
Run the data collector script to capture your hand movements for each word.
```bash
cd backend
python keypoint_collector.py
```
*   Use keys **0-9** for the first 10 labels and **a-z** for subsequent labels.
*   Press and hold the key while performing the gesture to record data frames.
*   Collect ~100-200 frames per gesture for best results.
*   Press 'q' to save and exit.

**3. Train the Model**
Run the training script to generate a new AI model based on your collected data.
```bash
python train_classifier.py
```
This will automatically save the new `keypoint_classifier.tflite` model.

**4. Restart Server**
Restart the backend server to apply changes:
```bash
python server.py
```

- `lib/core`: Theme and global configurations.
- `lib/screens/home`: Real-time translation hub and camera interface.
- `lib/screens/voice_studio`: Voice library management and cloned voices dashboard.
- `lib/screens/onboarding`: Voice creation wizard and onboarding flows.
- `lib/screens/profile`: User profile and settings management.
- `lib/widgets`: Reusable UI components like Emotion Indicators and Waveform Visualizers.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
