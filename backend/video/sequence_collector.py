
import csv
import copy
import argparse
import itertools
import os
import time
from collections import deque

import cv2 as cv
import numpy as np
import mediapipe as mp

# Use legacy solutions for Holistic as it's more stable for combined tracking in Python
mp_holistic = mp.solutions.holistic
mp_drawing = mp.solutions.drawing_utils

def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--device", type=int, default=0)
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--height", type=int, default=480)

    parser.add_argument("--min_detection_confidence",
                        help='min_detection_confidence',
                        type=float, default=0.7)
    parser.add_argument("--min_tracking_confidence",
                        help='min_tracking_confidence',
                        type=float, default=0.5)

    args = parser.parse_args()
    return args

def main():
    args = get_args()

    cap_device = args.device
    cap_width = args.width
    cap_height = args.height
    
    cap = cv.VideoCapture(cap_device, cv.CAP_DSHOW)
    cap.set(cv.CAP_PROP_FRAME_WIDTH, cap_width)
    cap.set(cv.CAP_PROP_FRAME_HEIGHT, cap_height)

    # Initialize Holistic
    holistic = mp_holistic.Holistic(
        min_detection_confidence=args.min_detection_confidence,
        min_tracking_confidence=args.min_tracking_confidence
    )

    # Label loading
    labels_path = 'model/keypoint_classifier/keypoint_classifier_label.csv'
    if not os.path.exists(labels_path):
        # Fallback if run from backend/video
        labels_path = 'model/keypoint_classifier/keypoint_classifier_label.csv'
    
    with open(labels_path, encoding='utf-8-sig') as f:
        keypoint_classifier_labels = csv.reader(f)
        keypoint_classifier_labels = [row[0] for row in keypoint_classifier_labels]

    print(f"Loaded {len(keypoint_classifier_labels)} labels.")
    print("--- DATASET COLLECTOR V2 (TEMPORAL + HOLISTIC) ---")
    print("Press 0-9 or a-i to select a class.")
    print("Hold 'K' to start recording a sequence (30 frames).")
    print("Press 'Q' to quit.")

    mode = 0  # 0: Normal, 1: Ready to Log
    selected_class = -1
    sequence_length = 30 # Number of frames per sequence
    current_sequence = []

    while True:
        key = cv.waitKey(10)
        if key == 27 or key == 113:  # ESC or q
            break
        
        # Select Class
        new_class, _ = select_mode(key, mode)
        if new_class != -1:
            selected_class = new_class
            print(f"Selected Class: {selected_class} ({keypoint_classifier_labels[selected_class]})")

        ret, image = cap.read()
        if not ret:
            break
        image = cv.flip(image, 1)  # Mirror display
        debug_image = copy.deepcopy(image)

        # To improve performance, optionally mark the image as not writeable to pass by reference.
        image.flags.writeable = False
        image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
        results = holistic.process(image)

        # Draw landmarks
        image.flags.writeable = True
        draw_styled_landmarks(debug_image, results)

        # Extract Landmarks
        keypoints = extract_keypoints(results)
        
        # Record Sequence if 'k' is pressed and class is selected
        if key == 107: # 'k'
            if selected_class == -1:
                print("Error: Select a class first!")
            else:
                print(f"Recording sequence for class {selected_class}...")
                current_sequence = []
                # Simple loop to capture next 30 frames with landmarks
                for frame_num in range(sequence_length):
                    ret, image = cap.read()
                    if not ret: break
                    image = cv.flip(image, 1)
                    debug_image_rec = copy.deepcopy(image)
                    
                    image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
                    results = holistic.process(image)
                    draw_styled_landmarks(debug_image_rec, results)
                    
                    # Show progress
                    cv.putText(debug_image_rec, f"RECORDING: {frame_num+1}/{sequence_length}", (10, 110), 
                               cv.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2, cv.LINE_AA)
                    cv.imshow('Dataset Collector', debug_image_rec)
                    cv.waitKey(1)
                    
                    current_sequence.append(extract_keypoints(results))
                
                # Save sequence
                save_sequence(selected_class, current_sequence)
                print("Sequence Saved.")

        # Display info
        draw_info(debug_image, selected_class, keypoint_classifier_labels)
        cv.imshow('Dataset Collector', debug_image)

    cap.release()
    cv.destroyAllWindows()

def select_mode(key, mode):
    number = -1
    if 48 <= key <= 57:  # 0 ~ 9
        number = key - 48
    if 97 <= key <= 105: # a ~ i (indices 10~18)
        number = key - 97 + 10
    return number, mode

def extract_keypoints(results):
    """
    Extracts and normalizes landmarks from Holistic results.
    Includes Pose, Left Hand, and Right Hand.
    """
    # Pose landmarks (33 landmarks * 4: x, y, z, visibility)
    # We only really need upper body for ASL: 0-24
    if results.pose_landmarks:
        pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten()
    else:
        pose = np.zeros(33*4)
        
    # Left Hand (21 landmarks * 3: x, y, z)
    if results.left_hand_landmarks:
        lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten()
    else:
        lh = np.zeros(21*3)
        
    # Right Hand (21 landmarks * 3: x, y, z)
    if results.right_hand_landmarks:
        rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten()
    else:
        rh = np.zeros(21*3)
        
    return np.concatenate([pose, lh, rh])

def save_sequence(label, sequence):
    """Saves a sequence of landmarks to a folder structure for training."""
    # We'll save to a directory 'sequences' if we want clean data, 
    # but for simplicity let's stick to a CSV-like format or separate files.
    # Actually, for LSTM, a numpy archive or folder per class is better.
    base_dir = 'model/sequences'
    os.makedirs(os.path.join(base_dir, str(label)), exist_ok=True)
    
    # Generate unique filename based on timestamp
    timestamp = int(time.time() * 1000)
    file_path = os.path.join(base_dir, str(label), f"{timestamp}.npy")
    np.save(file_path, sequence)

def draw_styled_landmarks(image, results):
    # Draw pose connections
    mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS,
                             mp_drawing.DrawingSpec(color=(80,22,10), thickness=2, circle_radius=4), 
                             mp_drawing.DrawingSpec(color=(80,44,121), thickness=2, circle_radius=2)
                             ) 
    # Draw left hand connections
    mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS, 
                             mp_drawing.DrawingSpec(color=(121,22,76), thickness=2, circle_radius=4), 
                             mp_drawing.DrawingSpec(color=(121,44,250), thickness=2, circle_radius=2)
                             ) 
    # Draw right hand connections  
    mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS, 
                             mp_drawing.DrawingSpec(color=(245,117,66), thickness=2, circle_radius=4), 
                             mp_drawing.DrawingSpec(color=(245,66,230), thickness=2, circle_radius=2)
                             ) 

def draw_info(image, selected_class, labels):
    cv.putText(image, "Dataset Collector V2 (Sequence)", (10, 30), cv.FONT_HERSHEY_SIMPLEX, 
               0.9, (255, 255, 255), 2, cv.LINE_AA)
    
    class_text = "None"
    if selected_class != -1:
        class_text = f"{selected_class}: {labels[selected_class]}"
    
    cv.putText(image, f"Class: {class_text}", (10, 70), cv.FONT_HERSHEY_SIMPLEX, 
               0.7, (0, 255, 0), 2, cv.LINE_AA)
    
    cv.putText(image, "Hold 'K' to record 30-frame sequence", (10, 460), cv.FONT_HERSHEY_SIMPLEX, 
               0.6, (255, 255, 0), 1, cv.LINE_AA)

if __name__ == '__main__':
    main()
