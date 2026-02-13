#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Standard library imports
import copy
import csv
import itertools
import threading
import os
import sys
import io
import base64

# Third-party imports
import cv2 as cv
import numpy as np
import eventlet
eventlet.monkey_patch()

# Flask imports
from flask import Flask, Response, request, jsonify
from flask_socketio import SocketIO
from flask_cors import CORS

# Audio processing imports
import soundfile as sf

# MediaPipe imports
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

# Local imports - Video
from video.model.keypoint_classifier.keypoint_classifier import KeyPointClassifier

# Local imports - Voice Cloning
sys.path.append(os.path.join(os.path.dirname(__file__), 'clone'))
from clone.voice_cloning import VoiceCloningManager
from tts.tts_manager import TTSManager

# Flask app initialization
app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='eventlet', logger=False, engineio_logger=False)

# Global variables
camera = None
is_processing = False
backend_dir = os.path.dirname(os.path.abspath(__file__))

# Initialize Voice Cloning Manager
vc_manager = VoiceCloningManager(models_dir=os.path.join(backend_dir, "clone", "saved_models"))

# Initialize TTS Manager
tts_manager = TTSManager(
    parrot_checkpoint_path=os.path.join(backend_dir, "tts", "checkpoints", "parrot_model.ckpt"), 
    vocoder_checkpoint_path=os.path.join(backend_dir, "tts", "checkpoints", "vocoder_model.ckpt") 
)

# Voice profile storage
active_voice_profile = {
    'embedding': None,
    'type': 'Natural',  # Natural, Professional, Warm, or Cloned
    'auto_speak': True  # Auto-speak detected signs
}
voice_profiles_lock = threading.Lock()


class VideoCamera(object):
    def __init__(self):
        # Open camera with multiple backend attempts for Windows
        print("Initializing Camera (Backends: DSHOW, MSMF)...")
        self.cap = cv.VideoCapture(0, cv.CAP_DSHOW)
        if not self.cap.isOpened():
             self.cap = cv.VideoCapture(0, cv.CAP_MSMF)
        if not self.cap.isOpened():
             self.cap = cv.VideoCapture(0)
             
        if not self.cap.isOpened():
             print("CRITICAL: Could not open any video source.")
        else:
             print(f"Camera successfully opened. Backend: {self.cap.getBackendName()}")

        self.cap.set(cv.CAP_PROP_FRAME_WIDTH, 640) 
        self.cap.set(cv.CAP_PROP_FRAME_HEIGHT, 480)
        self.cap.set(cv.CAP_PROP_FPS, 30)
        
        # Load Model (Tasks API) - Updated Path to be absolute
        script_dir = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.join(script_dir, 'video', 'model', 'hand_landmarker.task')
        base_options = python.BaseOptions(model_asset_path=model_path)
        options = vision.HandLandmarkerOptions(base_options=base_options,
                                               num_hands=2,
                                               min_hand_detection_confidence=0.7,
                                               min_hand_presence_confidence=0.5,
                                               min_tracking_confidence=0.5)
        self.detector = vision.HandLandmarker.create_from_options(options)
        
        kf_model_path = os.path.join(script_dir, 'video', 'model', 'keypoint_classifier', 'keypoint_classifier.tflite')
        self.keypoint_classifier = KeyPointClassifier(model_path=kf_model_path)
        
        # Load Labels - Updated Path to be absolute
        labels_path = os.path.join(script_dir, 'video', 'model', 'keypoint_classifier', 'keypoint_classifier_label.csv')
        with open(labels_path, encoding="utf-8-sig") as f:
            keypoint_classifier_labels = csv.reader(f)
            self.keypoint_classifier_labels = [row[0] for row in keypoint_classifier_labels]

        # Threading and State
        self.lock = threading.Lock()
        self.running = True
        self.frame = None # Encoded JPEG
        self.text = ""
        self.last_emitted_text = ""
        
        # Detection state
        self.last_landmarks_data = None # Store (landmarks, handedness, label, brect)
        self.is_detecting = False
        
        # Detection state
        self.last_landmarks_data = None # Store (landmarks, handedness, label, brect)
        self.needs_processing = False
        
        self.t = threading.Thread(target=self.update, args=())
        self.t.daemon = True
        self.t.start()
        
        # Single detection worker thread
        self.d_thread = threading.Thread(target=self.detection_worker, daemon=True)
        self.d_thread.start()
        
    def detection_worker(self):
        """Persistent worker for detection to avoid thread spawn overhead"""
        while self.running:
            if not self.needs_processing or self.image_for_detection is None:
                eventlet.sleep(0.01)
                continue
                
            try:
                img = self.image_for_detection.copy()
                self.needs_processing = False
                
                # Detection
                rgb_image = cv.cvtColor(img, cv.COLOR_BGR2RGB)
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_image)
                detection_result = self.detector.detect(mp_image)
                
                new_landmarks_data = []
                detected_text = ""
                
                if detection_result.hand_landmarks:
                    for hand_landmarks, handedness in zip(detection_result.hand_landmarks, detection_result.handedness):
                        brect = calc_bounding_rect(img, hand_landmarks)
                        landmark_list = calc_landmark_list(img, hand_landmarks)
                        
                        # Classifier
                        pre_processed_landmark_list = pre_process_landmark(landmark_list)
                        hand_sign_id = self.keypoint_classifier(pre_processed_landmark_list)
                        
                        if 0 <= hand_sign_id < len(self.keypoint_classifier_labels):
                            label = self.keypoint_classifier_labels[hand_sign_id]
                        else:
                            label = "Unknown"
                        
                        if label == "_": label = ""
                        
                        new_landmarks_data.append({
                            'landmarks': landmark_list,
                            'handedness': handedness,
                            'label': label,
                            'brect': brect
                        })
                        
                        if label != "":
                            detected_text = label
                
                with self.lock:
                    self.last_landmarks_data = new_landmarks_data
                    self.text = detected_text
                    
                    # Emit only if changed
                    if detected_text != "" and detected_text != self.last_emitted_text:
                        socketio.emit('text_update', {'text': detected_text})
                        self.last_emitted_text = detected_text
                        
                        # Auto-speak if enabled
                        if active_voice_profile['auto_speak']:
                            try:
                                synthesize_and_emit_audio(detected_text)
                            except Exception as e:
                                print(f"Auto-speak error: {e}")
                        
            except Exception as e:
                print(f"Detection worker Error: {e}")
            
            eventlet.sleep(0.01)

    def _trigger_detection(self, image):
        """Signal the worker to process the latest frame"""
        if not self.needs_processing:
            self.image_for_detection = image
            self.needs_processing = True

    def update(self):
        print("Starting video capture loop with detection...")
        while self.running:
            try:
                ret, image = self.cap.read()
                if not ret:
                    eventlet.sleep(0.1)
                    continue
                
                image = cv.flip(image, 1)
                
                # Signal detection worker
                self._trigger_detection(image)
                
                # Draw landmarks and info
                debug_image = image.copy()
                with self.lock:
                    if self.last_landmarks_data:
                        for item in self.last_landmarks_data:
                            debug_image = draw_bounding_rect(True, debug_image, item['brect'])
                            debug_image = draw_landmarks(debug_image, item['landmarks'])
                            debug_image = draw_info_text(debug_image, item['brect'], item['handedness'], item['label'])
                
                # ret, jpeg = cv.imencode('.jpg', debug_image, [int(cv.IMWRITE_JPEG_QUALITY), 70])
                ret, jpeg = cv.imencode('.jpg', debug_image, [int(cv.IMWRITE_JPEG_QUALITY), 50])
                if ret:
                    with self.lock:
                        self.frame = jpeg.tobytes()
                
                eventlet.sleep(0.02) # ~50 FPS target for capture
            except Exception as e:
                print(f"Loop ERROR: {e}")
                eventlet.sleep(0.1)
        
    def __del__(self):
        self.running = False
        if self.cap.isOpened():
             self.cap.release()

    def get_frame(self):
        with self.lock:
            if self.frame is None:
                 return None, None
            return self.frame, self.text


# --- Helper Functions from app.py ---

def calc_bounding_rect(image, landmarks):
    image_width, image_height = image.shape[1], image.shape[0]
    landmark_array = np.empty((0, 2), int)

    for _, landmark in enumerate(landmarks):
        landmark_x = min(int(landmark.x * image_width), image_width - 1)
        landmark_y = min(int(landmark.y * image_height), image_height - 1)
        landmark_point = [np.array((landmark_x, landmark_y))]
        landmark_array = np.append(landmark_array, landmark_point, axis=0)

    x, y, w, h = cv.boundingRect(landmark_array)
    return [x, y, x + w, y + h]

def calc_landmark_list(image, landmarks):
    image_width, image_height = image.shape[1], image.shape[0]
    landmark_point = []
    for _, landmark in enumerate(landmarks):
        landmark_x = min(int(landmark.x * image_width), image_width - 1)
        landmark_y = min(int(landmark.y * image_height), image_height - 1)
        landmark_point.append([landmark_x, landmark_y])
    return landmark_point

def pre_process_landmark(landmark_list):
    temp_landmark_list = copy.deepcopy(landmark_list)
    base_x, base_y = 0, 0
    for index, landmark_point in enumerate(temp_landmark_list):
        if index == 0:
            base_x, base_y = landmark_point[0], landmark_point[1]
        temp_landmark_list[index][0] = temp_landmark_list[index][0] - base_x
        temp_landmark_list[index][1] = temp_landmark_list[index][1] - base_y
    temp_landmark_list = list(itertools.chain.from_iterable(temp_landmark_list))
    max_value = max(list(map(abs, temp_landmark_list)))
    def normalize_(n):
        return n / max_value
    temp_landmark_list = list(map(normalize_, temp_landmark_list))
    return temp_landmark_list

def draw_landmarks(image, landmark_point):
    if len(landmark_point) > 0:
        # Thumb
        cv.line(image, tuple(landmark_point[2]), tuple(landmark_point[3]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[2]), tuple(landmark_point[3]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[3]), tuple(landmark_point[4]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[3]), tuple(landmark_point[4]), (255, 255, 255), 2)
        # Index finger
        cv.line(image, tuple(landmark_point[5]), tuple(landmark_point[6]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[5]), tuple(landmark_point[6]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[6]), tuple(landmark_point[7]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[6]), tuple(landmark_point[7]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[7]), tuple(landmark_point[8]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[7]), tuple(landmark_point[8]), (255, 255, 255), 2)
        # Middle finger
        cv.line(image, tuple(landmark_point[9]), tuple(landmark_point[10]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[9]), tuple(landmark_point[10]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[10]), tuple(landmark_point[11]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[10]), tuple(landmark_point[11]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[11]), tuple(landmark_point[12]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[11]), tuple(landmark_point[12]), (255, 255, 255), 2)
        # Ring finger
        cv.line(image, tuple(landmark_point[13]), tuple(landmark_point[14]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[13]), tuple(landmark_point[14]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[14]), tuple(landmark_point[15]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[14]), tuple(landmark_point[15]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[15]), tuple(landmark_point[16]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[15]), tuple(landmark_point[16]), (255, 255, 255), 2)
        # Little finger
        cv.line(image, tuple(landmark_point[17]), tuple(landmark_point[18]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[17]), tuple(landmark_point[18]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[18]), tuple(landmark_point[19]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[18]), tuple(landmark_point[19]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[19]), tuple(landmark_point[20]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[19]), tuple(landmark_point[20]), (255, 255, 255), 2)
        # Palm
        cv.line(image, tuple(landmark_point[0]), tuple(landmark_point[1]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[0]), tuple(landmark_point[1]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[1]), tuple(landmark_point[2]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[1]), tuple(landmark_point[2]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[2]), tuple(landmark_point[5]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[2]), tuple(landmark_point[5]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[5]), tuple(landmark_point[9]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[5]), tuple(landmark_point[9]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[9]), tuple(landmark_point[13]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[9]), tuple(landmark_point[13]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[13]), tuple(landmark_point[17]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[13]), tuple(landmark_point[17]), (255, 255, 255), 2)
        cv.line(image, tuple(landmark_point[17]), tuple(landmark_point[0]), (0, 0, 0), 6)
        cv.line(image, tuple(landmark_point[17]), tuple(landmark_point[0]), (255, 255, 255), 2)

    # Key Points
    for index, landmark in enumerate(landmark_point):
        if index == 0:  # Wrist 1
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 1:  # Wrist 2
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 2:  # Thumb base
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 3:  # Thumb first joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 4:  # Thumb tip
            cv.circle(image, (landmark[0], landmark[1]), 8, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 8, (0, 0, 0), 1)
        if index == 5:  # Index finger base
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 6:  # Index finger second joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 7:  # Index finger first joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 8:  # Index finger tip
            cv.circle(image, (landmark[0], landmark[1]), 8, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 8, (0, 0, 0), 1)
        if index == 9:  # Middle finger base
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 10:  # Middle finger second joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 11:  # Middle finger first joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 12:  # Middle finger tip
            cv.circle(image, (landmark[0], landmark[1]), 8, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 8, (0, 0, 0), 1)
        if index == 13:  # Ring finger base
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 14:  # Ring finger second joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 15:  # Ring finger first joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 16:  # Ring finger tip
            cv.circle(image, (landmark[0], landmark[1]), 8, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 8, (0, 0, 0), 1)
        if index == 17:  # Little finger base
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 18:  # Little finger second joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 19:  # Little finger first joint
            cv.circle(image, (landmark[0], landmark[1]), 5, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 5, (0, 0, 0), 1)
        if index == 20:  # Little finger tip
            cv.circle(image, (landmark[0], landmark[1]), 8, (255, 255, 255), -1)
            cv.circle(image, (landmark[0], landmark[1]), 8, (0, 0, 0), 1)
    return image

def draw_bounding_rect(use_brect, image, brect):
    if use_brect:
        cv.rectangle(image, (brect[0], brect[1]), (brect[2], brect[3]), (0, 0, 0), 1)
    return image

def draw_info_text(image, brect, handedness, hand_sign_text):
    cv.rectangle(image, (brect[0], brect[1]), (brect[2], brect[1] - 22), (0, 0, 0), -1)
    # handedness is a ClassificationResult; get first category's name
    try:
        info_text = handedness.categories[0].category_name
    except Exception:
        info_text = ""
    if hand_sign_text != "":
        info_text = f"{info_text}:{hand_sign_text}"
    cv.putText(image, info_text, (brect[0] + 5, brect[1] - 4),
               cv.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1, cv.LINE_AA)
    return image

# --- Routes ---

def gen(camera):
    # Wait for first frame to avoid closing stream immediately
    for _ in range(100):
        frame, _ = camera.get_frame()
        if frame is not None:
            break
        eventlet.sleep(0.05)
        
    while True:
        frame, text = camera.get_frame()
        if frame is not None:
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
        eventlet.sleep(0.01)

@app.route('/video_feed')
def video_feed():
    global camera
    if camera is None:
        camera = VideoCamera()
    return Response(gen(camera),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/video_frame')
def video_frame():
    global camera
    if camera is None:
        camera = VideoCamera()
    frame, _ = camera.get_frame()
    if frame is None:
        return "", 500
    return Response(frame, mimetype='image/jpeg')

@app.route('/')
def index():
    return "Parrot Sign Language Backend Running..."

@socketio.on('connect')
def test_connect():
    print('Client connected')

@socketio.on('disconnect')
def test_disconnect():
    print('Client disconnected')

@socketio.on('request_speech')
def handle_speech_request(data):
    """Handle real-time speech synthesis request from client"""
    text = data.get('text', '')
    if text:
        try:
            synthesize_and_emit_audio(text)
        except Exception as e:
            socketio.emit('speech_error', {'error': str(e)})

@socketio.on('toggle_auto_speak')
def handle_toggle_auto_speak(data):
    """Toggle automatic speech for detected signs"""
    global active_voice_profile
    with voice_profiles_lock:
        active_voice_profile['auto_speak'] = data.get('enabled', True)
    socketio.emit('auto_speak_status', {'enabled': active_voice_profile['auto_speak']})


# --- Helper Functions ---

def synthesize_and_emit_audio(text):
    """
    Synthesize speech and emit audio via SocketIO.
    
    Priority:
    1. Cloned voice (if embedding available)
    2. Voice profile with voice cloning models
    3. Mock audio
    """
    try:
        with voice_profiles_lock:
            embedding = active_voice_profile['embedding']
            voice_type = active_voice_profile['type']
        
        wav = None
        synthesis_method = 'unknown'
        
        # Priority 1: Try cloned voice if embedding is available
        if embedding:
            print(f"Synthesizing with cloned voice: '{text}'")
            try:
                wav, error = vc_manager.synthesize(text, embedding)
                if wav is not None and error is None:
                    synthesis_method = 'cloned_voice'
                    print(f"✓ Used cloned voice")
                else:
                    print(f"⚠ Cloned voice failed: {error}")
            except Exception as e:
                print(f"⚠ Cloned voice error: {e}")
        
        # Priority 2: Try voice profile with TTS manager
        if wav is None:
            print(f"Synthesizing with {voice_type} profile: '{text}'")
            try:
                speaker_id = {'Natural': 0, 'Professional': 1, 'Warm': 2}.get(voice_type, 0)
                
                # TTS manager will use voice cloning models with profile embeddings
                # or fall back to mock audio if models not available
                wav = tts_manager.synthesize(text, speaker_id=speaker_id)
                
                if wav is not None:
                    # Check if it's mock audio or real synthesis
                    if tts_manager.is_ready():
                        synthesis_method = f'profile_{voice_type.lower()}'
                        print(f"✓ Used {voice_type} profile with voice cloning")
                    else:
                        synthesis_method = 'mock_audio'
                        print(f"⚠ Using mock audio (models not loaded)")
                    
                    # Convert int16 to float32 if needed
                    if wav.dtype == np.int16:
                        wav = wav.astype(np.float32) / 32768.0
                else:
                    print(f"✗ TTS manager returned None")
                    
            except Exception as e:
                print(f"✗ TTS synthesis error: {e}")
                import traceback
                traceback.print_exc()
        
        # Emit audio if we have it
        if wav is not None:
            try:
                # Convert to bytes
                buffer = io.BytesIO()
                sr = 22050 if embedding else 24000
                sf.write(buffer, wav, samplerate=sr, format='WAV')
                buffer.seek(0)
                audio_bytes = buffer.read()
                
                # Emit audio via SocketIO
                audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
                socketio.emit('audio_ready', {
                    'audio': audio_base64,
                    'text': text,
                    'voice_type': voice_type,
                    'synthesis_method': synthesis_method,
                    'sample_rate': sr
                })
                print(f"✓ Audio emitted: '{text}' ({synthesis_method})")
                
            except Exception as e:
                print(f"✗ Error encoding/emitting audio: {e}")
                socketio.emit('speech_error', {
                    'error': f'Audio encoding failed: {str(e)}',
                    'text': text
                })
        else:
            print(f"✗ No audio generated for: '{text}'")
            socketio.emit('speech_error', {
                'error': 'Synthesis failed - no audio generated',
                'text': text
            })
            
    except Exception as e:
        print(f"✗ Critical error in synthesize_and_emit_audio: {e}")
        import traceback
        traceback.print_exc()
        socketio.emit('speech_error', {
            'error': f'Synthesis failed: {str(e)}',
            'text': text
        })


# ... (existing code for socketio setup)


# --- Voice Cloning Routes ---

@app.route('/clone_voice', methods=['POST'])
def clone_voice():
    if 'audio' not in request.files:
        return jsonify({"error": "No audio file provided"}), 400
    
    audio_file = request.files['audio']
    
    # Save to temp file to load with librosa/preprocess_wav
    # Or load directly if utilities support it.
    # Here we define a simplified flow:
    try:
        temp_path = "temp_voice_input.wav"
        audio_file.save(temp_path)
        
        result = vc_manager.clone_voice(temp_path)
        
        # Cleanup
        if os.path.exists(temp_path):
            os.remove(temp_path)
            
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/synthesize', methods=['POST'])
def synthesize():
    data = request.json
    text = data.get("text")
    embedding = data.get("embedding")
    voice_profile = data.get("voice_profile", "Natural")
    
    if not text:
        return jsonify({"error": "Missing text"}), 400
    
    wav = None
    error = None
    
    if embedding:
        print(f"Synthesizing with Voice Cloning (RTVC) for profile: {voice_profile}...")
        wav, error = vc_manager.synthesize(text, embedding)
    
    if wav is None:
        print(f"Synthesizing with Profile-based TTS: {voice_profile}...")
        
        # In a real system, voice_profile would map to a specific speaker_id or model
        # For demo purposes, we'll vary the pitch of the mock audio based on profile
        
        speaker_id = 0
        if voice_profile == "Professional": speaker_id = 1
        elif voice_profile == "Warm": speaker_id = 2
        
        # If models are loaded, use speaker_id. If missing, manager returns mock.
        wav = tts_manager.synthesize(text, speaker_id=speaker_id)
            
        if wav.dtype == np.int16:
            wav = wav.astype(np.float32) / 32768.0
            
    if wav is None:
        return jsonify({"error": "Synthesis failed"}), 500
        
    buffer = io.BytesIO()
    sr = 22050 if embedding else 24000
    
    sf.write(buffer, wav, samplerate=sr, format='WAV')
    buffer.seek(0)
    
    return Response(buffer.read(), mimetype="audio/wav")

@app.route('/set_voice_profile', methods=['POST'])
def set_voice_profile():
    """Set the active voice profile for sign language TTS"""
    global active_voice_profile
    data = request.json
    
    voice_type = data.get('voice_type', 'Natural')
    embedding = data.get('embedding')
    auto_speak = data.get('auto_speak', True)
    
    with voice_profiles_lock:
        active_voice_profile['type'] = voice_type
        active_voice_profile['embedding'] = embedding
        active_voice_profile['auto_speak'] = auto_speak
    
    return jsonify({
        'success': True,
        'active_profile': {
            'type': voice_type,
            'has_cloned_voice': embedding is not None,
            'auto_speak': auto_speak
        }
    })

@app.route('/clone_and_activate_voice', methods=['POST'])
def clone_and_activate_voice():
    """Clone voice and immediately set it as active for sign language TTS"""
    global active_voice_profile
    
    if 'audio' not in request.files:
        return jsonify({"error": "No audio file provided"}), 400
    
    audio_file = request.files['audio']
    
    try:
        temp_path = "temp_voice_input.wav"
        audio_file.save(temp_path)
        
        # Clone the voice
        result = vc_manager.clone_voice(temp_path)
        
        # Cleanup
        if os.path.exists(temp_path):
            os.remove(temp_path)
        
        if result.get('success'):
            # Set as active voice
            with voice_profiles_lock:
                active_voice_profile['embedding'] = result['embedding']
                active_voice_profile['type'] = 'Cloned'
            
            return jsonify({
                'success': True,
                'message': 'Voice cloned and activated successfully',
                'is_mock': result.get('is_mock', False),
                'active_profile': {
                    'type': 'Cloned',
                    'has_cloned_voice': True,
                    'auto_speak': active_voice_profile['auto_speak']
                }
            })
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/get_voice_status', methods=['GET'])
def get_voice_status():
    """Get current voice profile status"""
    with voice_profiles_lock:
        return jsonify({
            'active_profile': {
                'type': active_voice_profile['type'],
                'has_cloned_voice': active_voice_profile['embedding'] is not None,
                'auto_speak': active_voice_profile['auto_speak']
            },
            'available_profiles': ['Natural', 'Professional', 'Warm', 'Cloned']
        })

@app.route('/get_tts_status', methods=['GET'])
def get_tts_status():
    """Get TTS system status"""
    try:
        vc_status = {
            'encoder_loaded': vc_manager.encoder_loaded,
            'synthesizer_loaded': vc_manager.synthesizer_loaded,
            'vocoder_loaded': vc_manager.vocoder_loaded,
            'ready': vc_manager.encoder_loaded and vc_manager.synthesizer_loaded and vc_manager.vocoder_loaded
        }
        
        tts_status = tts_manager.get_status()
        
        return jsonify({
            'voice_cloning': vc_status,
            'tts_manager': tts_status,
            'overall_ready': vc_status['ready'] or tts_status['ready']
        })
    except Exception as e:
        return jsonify({
            'error': str(e),
            'voice_cloning': {'ready': False},
            'tts_manager': {'ready': False},
            'overall_ready': False
        })


# ... (existing routes)

if __name__ == '__main__':
    try:
        # Create required directories
        os.makedirs(os.path.join(backend_dir, 'clone', 'saved_models'), exist_ok=True)
        os.makedirs(os.path.join(backend_dir, 'video', 'model'), exist_ok=True)
        os.makedirs(os.path.join(backend_dir, 'tts', 'checkpoints'), exist_ok=True)

        print("Starting Flask Server...")
        socketio.run(app, debug=False, host='0.0.0.0', port=5000, allow_unsafe_werkzeug=True)
    except Exception as e:
        print(f"Server crashed: {e}")
