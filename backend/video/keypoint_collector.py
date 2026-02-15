
import csv
import copy
import argparse
import itertools
from collections import deque
from collections import Counter

import cv2 as cv
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

from model.keypoint_classifier.keypoint_classifier import KeyPointClassifier


def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--device", type=int, default=0)
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--height", type=int, default=480)

    # Use 19 classes as per user request
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

    # Load Model (Tasks API) - Consistent with server.py
    base_options = python.BaseOptions(model_asset_path='model/hand_landmarker.task')
    options = vision.HandLandmarkerOptions(base_options=base_options,
                                           num_hands=1,
                                           min_hand_detection_confidence=args.min_detection_confidence,
                                           min_hand_presence_confidence=0.5,
                                           min_tracking_confidence=args.min_tracking_confidence)
    detector = vision.HandLandmarker.create_from_options(options)

    # Label loading
    with open('model/keypoint_classifier/keypoint_classifier_label.csv', encoding='utf-8-sig') as f:
        keypoint_classifier_labels = csv.reader(f)
        keypoint_classifier_labels = [row[0] for row in keypoint_classifier_labels]

    print(f"Loaded {len(keypoint_classifier_labels)} labels.")
    print("Press 0-9 to log data for the first 10 classes.")
    print("Press a-i to log data for the next 9 classes.")
    print("Press 'q' to quit.")

    mode = 0  # 0: Normal, 1: Logging

    while True:
        key = cv.waitKey(10)
        if key == 27 or key == 113:  # ESC or q
            break
        
        number, mode = select_mode(key, mode)

        ret, image = cap.read()
        if not ret:
            break
        image = cv.flip(image, 1)  # Mirror display
        debug_image = copy.deepcopy(image)

        image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
        
        # Create MP Image for Tasks API
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image)
        
        # Detect
        detection_result = detector.detect(mp_image)

        if detection_result.hand_landmarks:
            for hand_landmarks, handedness in zip(detection_result.hand_landmarks, detection_result.handedness):
                landmark_list = calc_landmark_list(debug_image, hand_landmarks)
                pre_processed_landmark_list = pre_process_landmark(landmark_list)

                if getattr(select_mode, "log_now", False):
                    logging_csv(number, mode, pre_processed_landmark_list)
                    select_mode.log_now = False


                debug_image = draw_landmarks(debug_image, landmark_list)
                debug_image = draw_info(debug_image, mode, number)

        cv.imshow('Dataset Collector', debug_image)

    cap.release()
    cv.destroyAllWindows()


def select_mode(key, mode):
    # persistent buffer (survives between calls)
    if not hasattr(select_mode, "buffer"):
        select_mode.buffer = ""

    number = -1
    log_now = False

    # digit keys 0–9
    if 48 <= key <= 57:
        select_mode.buffer += chr(key)
        mode = 1

    # backspace
    elif key == 8:
        select_mode.buffer = select_mode.buffer[:-1]

    # ENTER → confirm number
    elif key == 13:
        if select_mode.buffer != "":
            number = int(select_mode.buffer)
            log_now = True
            select_mode.buffer = ""

    # cancel input
    elif key == 110:  # n
        mode = 0
        select_mode.buffer = ""

    # manual log mode toggle (kept from your original)
    elif key == 107:  # k
        mode = 1

    # show currently typed number (without logging yet)
    if select_mode.buffer != "":
        number = int(select_mode.buffer)

    # store log flag on the function so main loop can read it
    select_mode.log_now = log_now

    return number, mode


def calc_landmark_list(image, landmarks):
    image_width, image_height = image.shape[1], image.shape[0]
    landmark_point = []
    
    # Iterate through list of landmarks (Tasks API returns list of NormalizedLandmark)
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


def logging_csv(number, mode, landmark_list):
    if mode == 0:
        pass
    if mode == 1 and (0 <= number <= 18):
        csv_path = 'model/keypoint_classifier/keypoint.csv'
        with open(csv_path, 'a', newline="") as f:
            writer = csv.writer(f)
            writer.writerow([number, *landmark_list])
        print(f"Logged data for class {number}")


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
    return image


def draw_info(image, mode, number):
    cv.putText(image, "Dataset Collector", (10, 30), cv.FONT_HERSHEY_SIMPLEX, 
               1.0, (0, 0, 0), 4, cv.LINE_AA)
    cv.putText(image, "Dataset Collector", (10, 30), cv.FONT_HERSHEY_SIMPLEX, 
               1.0, (255, 255, 255), 2, cv.LINE_AA)
    
    status_text = "Waiting"
    if number != -1:
        status_text = f"Saving {number}"
    
    cv.putText(image, f"Status: {status_text}", (10, 70), cv.FONT_HERSHEY_SIMPLEX, 
               0.6, (0, 255, 0), 2, cv.LINE_AA)
               
    return image


if __name__ == '__main__':
    main()
