
import numpy as np
import tensorflow as tf

class SequenceClassifier(object):
    def __init__(
        self,
        model_path="model/sequence_classifier.tflite",
        num_threads=1,
    ):
        self.interpreter = tf.lite.Interpreter(
            model_path=model_path, num_threads=num_threads
        )

        self.interpreter.allocate_tensors()
        self.input_details = self.interpreter.get_input_details()
        self.output_details = self.interpreter.get_output_details()

    def __call__(
        self,
        sequence,
    ):
        """
        Input: sequence of shape (30, 258)
        """
        input_details_tensor_index = self.input_details[0]["index"]
        # Ensure sequence has batch dimension: (1, 30, 258)
        input_data = np.array([sequence], dtype=np.float32)
        
        self.interpreter.set_tensor(
            input_details_tensor_index, input_data
        )
        self.interpreter.invoke()

        output_details_tensor_index = self.output_details[0]["index"]
        result = self.interpreter.get_tensor(output_details_tensor_index)
        result_index = np.argmax(np.squeeze(result))
        
        # Also return confidence
        confidence = np.max(np.squeeze(result))

        return result_index, confidence
