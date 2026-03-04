import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, classification_report

RANDOM_SEED = 42

dataset = 'model/keypoint_classifier/keypoint.csv'
model_save_path = 'model/keypoint_classifier/keypoint_classifier.keras'
tflite_save_path = 'model/keypoint_classifier/keypoint_classifier.tflite'

print("Loading dataset...")
try:
    df = pd.read_csv(dataset, header=None)
    X_dataset = df.iloc[:, 1:].values
    y_dataset = df.iloc[:, 0].values
except Exception as e:
    print(f"Error loading dataset: {e}")
    print("Does 'keypoint.csv' exist? Did you run keypoint_collector.py?")
    exit()

# 🔥 AUTO-DETECT NUMBER OF CLASSES
NUM_CLASSES = len(np.unique(y_dataset))

X_train, X_test, y_train, y_test = train_test_split(
    X_dataset, y_dataset, train_size=0.75, random_state=RANDOM_SEED
)

print(f"Training on {len(X_train)} samples, Testing on {len(X_test)} samples.")
print(f"Classes found: {np.unique(y_dataset)}")
print(f"Number of classes: {NUM_CLASSES}")

model = tf.keras.models.Sequential([
    tf.keras.layers.Input((42,)),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(20, activation='relu'),
    tf.keras.layers.Dropout(0.4),
    tf.keras.layers.Dense(10, activation='relu'),
    tf.keras.layers.Dense(NUM_CLASSES, activation='softmax')  # 🔥 dynamic
])

model.summary()

cp_callback = tf.keras.callbacks.ModelCheckpoint(
    model_save_path, verbose=1, save_weights_only=False)

es_callback = tf.keras.callbacks.EarlyStopping(
    patience=20, verbose=1, restore_best_weights=True)

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

print("Starting training...")
history = model.fit(
    X_train,
    y_train,
    epochs=1000,
    batch_size=128,
    validation_data=(X_test, y_test),
    callbacks=[cp_callback, es_callback]
)

print("Training complete. Evaluating...")
val_loss, val_acc = model.evaluate(X_test, y_test, batch_size=128)
print(f"Validation accuracy: {val_acc}")

# Reload best model
model = tf.keras.models.load_model(model_save_path)

# Inference test
predict_result = model.predict(np.array([X_test[0]]))
print(np.squeeze(predict_result))
print("Predicted class:", np.argmax(np.squeeze(predict_result)))

# ================= CONFUSION MATRIX =================
y_pred = np.argmax(model.predict(X_test), axis=1)

cm = confusion_matrix(y_test, y_pred)

plt.figure(figsize=(10, 8))
sns.heatmap(cm, annot=False, cmap="Blues")
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("True")
plt.show()

print("Classification Report:")
print(classification_report(y_test, y_pred))

# ================= TFLITE =================
print("Converting to TFLite...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_quantized_model = converter.convert()

with open(tflite_save_path, 'wb') as f:
    f.write(tflite_quantized_model)

print(f"TFLite model saved to {tflite_save_path}")
print("Done.")
