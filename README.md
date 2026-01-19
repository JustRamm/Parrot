# Parrot 🦜

Parrot is a cutting-edge Flutter application designed to bridge the communication gap for individuals using sign language. It provides real-time gesture-to-speech translation with personalized voice cloning technology.

## 🚀 Features

- **Real-Time Translation**: Convert sign language gestures into text instantly using advanced computer vision.
- **Voice Studio**: Create and manage personalized AI voice clones that sound just like the user.
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

## 📂 Project Structure

- `lib/core`: Theme and global configurations.
- `lib/screens/home`: Real-time translation hub and camera interface.
- `lib/screens/onboarding`: Voice creation wizard and onboarding flows.
- `lib/screens/profile`: User profile and settings management.
- `lib/widgets`: Reusable UI components like Emotion Indicators and Waveform Visualizers.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
