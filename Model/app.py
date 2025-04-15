from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import requests
from io import BytesIO

app = Flask(__name__)

# Load model once at startup
model = tf.keras.models.load_model("RiceDiseaseModel.h5")

class_names = [
    'Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf',
    'Leaf Blast', 'Leaf scald', 'Narrow Brown Leaf Spot',
    'Neck_Blast', 'Rice Hispa', 'Sheath Blight'
]

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    if not data or 'image_url' not in data:
        return jsonify({"error": "Please provide image_url in JSON"}), 400

    try:
        image_url = data['image_url']
        response = requests.get(image_url)
        response.raise_for_status()  # Ensure we got the image

        # Load and preprocess image
        image = Image.open(BytesIO(response.content)).convert('RGB')
        image = image.resize((256, 256))
        img_array = tf.keras.preprocessing.image.img_to_array(image) 
        img_array = tf.expand_dims(img_array, axis=0)

        # Predict
        predictions = model.predict(img_array)
        predicted_class = class_names[np.argmax(predictions)]
        confidence = float(np.max(predictions))

        return jsonify({
            "predicted_class": predicted_class,
            "confidence": confidence
        })

    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Could not fetch image: {str(e)}"}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host="192.168.125.26",debug=True)
