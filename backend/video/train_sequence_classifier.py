
import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout, Input
from tensorflow.keras.callbacks import TensorBoard, EarlyStopping, ModelCheckpoint

# Paths
DATA_PATH = os.path.join('model', 'sequences')
# Get actions (labels) from the filenames in the DATA_PATH
actions = np.array([f for f in os.listdir(DATA_PATH) if os.path.isdir(os.path.join(DATA_PATH, f))])
sequence_length = 30
# 258 points = (33*4 for pose) + (21*3 for LH) + (21*3 for RH)
input_shape = 258 

def load_data():
    sequences, labels = [], []
    for action in actions:
        action_path = os.path.join(DATA_PATH, str(action))
        files = [f for f in os.listdir(action_path) if f.endswith('.npy')]
        for file in files:
            res = np.load(os.path.join(action_path, file))
            sequences.append(res)
            # Map action back to label index if necessary, 
            # here we assume action is the label index string
            labels.append(int(action))
    return np.array(sequences), np.array(labels)

def train():
    print("Loading sequence data...")
    if not os.path.exists(DATA_PATH):
        print("Data path not found. Please record some sequences first!")
        return

    X, y = load_data()
    if len(X) == 0:
        print("No data found!")
        return

    print(f"Loaded {len(X)} sequences of shape {X.shape[1:]}")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=42)

    # Build Model
    model = Sequential([
        Input(shape=(sequence_length, input_shape)),
        LSTM(64, return_sequences=True, activation='relu'),
        LSTM(128, return_sequences=True, activation='relu'),
        LSTM(64, return_sequences=False, activation='relu'),
        Dense(64, activation='relu'),
        Dropout(0.2),
        Dense(32, activation='relu'),
        Dense(len(actions), activation='softmax')
    ])

    model.compile(optimizer='Adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

    # Callbacks
    checkpoint_path = os.path.join('model', 'sequence_classifier.keras')
    cp_callback = ModelCheckpoint(checkpoint_path, monitor='val_accuracy', save_best_only=True, verbose=1)
    es_callback = EarlyStopping(monitor='val_accuracy', patience=50, verbose=1)

    print("Starting Training...")
    model.fit(X_train, y_train, epochs=2000, callbacks=[cp_callback, es_callback], 
              validation_data=(X_test, y_test), batch_size=32)

    model.summary()
    print("Training finished.")
    
    # Convert to TFLite
    print("Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    # Important for LSTM conversion to TFLite
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS, tf.lite.OpsSet.SELECT_TF_OPS]
    converter._experimental_lower_tensor_list_ops = False
    
    tflite_model = converter.convert()
    with open(os.path.join('model', 'sequence_classifier.tflite'), 'wb') as f:
        f.write(tflite_model)
    print("TFLite conversion complete.")

if __name__ == '__main__':
    train()
