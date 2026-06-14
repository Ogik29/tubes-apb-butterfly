#!/usr/bin/env python3
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

try:
    from tflite_runtime.interpreter import Interpreter
except Exception:
    try:
        import tensorflow as tf
        Interpreter = tf.lite.Interpreter
    except Exception as exc:
        print(json.dumps({"success": False, "error": f"TFLite runtime not installed: {exc}"}))
        sys.exit(1)

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "butterfly_dual_cnn.tflite"
LABELS_PATH = BASE_DIR / "labels.txt"
IMG_SIZE = (128, 128)


def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-x))


def softmax(x):
    x = x - np.max(x)
    e = np.exp(x)
    return e / np.sum(e)


def load_labels():
    return [line.strip() for line in LABELS_PATH.read_text(encoding="utf-8").splitlines() if line.strip()]


def preprocess(image_path, input_detail):
    image = Image.open(image_path).convert("RGB").resize(IMG_SIZE)
    arr = np.asarray(image, dtype=np.float32) / 255.0
    arr = np.expand_dims(arr, axis=0)

    dtype = input_detail["dtype"]
    if dtype == np.uint8 or dtype == np.int8:
        scale, zero_point = input_detail.get("quantization", (0.0, 0))
        if scale and scale > 0:
            arr = arr / scale + zero_point
        arr = arr.astype(dtype)
    else:
        arr = arr.astype(dtype)
    return arr


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "Usage: python predict.py <image_path>"}))
        sys.exit(1)

    image_path = Path(sys.argv[1])
    if not image_path.exists():
        print(json.dumps({"success": False, "error": f"Image not found: {image_path}"}))
        sys.exit(1)

    labels = load_labels()
    interpreter = Interpreter(model_path=str(MODEL_PATH))
    interpreter.allocate_tensors()

    input_detail = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()

    input_data = preprocess(image_path, input_detail)
    interpreter.set_tensor(input_detail["index"], input_data)
    interpreter.invoke()

    outputs = [interpreter.get_tensor(o["index"]) for o in output_details]

    species_output = None
    toxicity_output = None
    for out in outputs:
        flat = np.ravel(out).astype(np.float32)
        if flat.size == len(labels):
            species_output = flat
        elif flat.size == 1:
            toxicity_output = flat

    if species_output is None:
        print(json.dumps({"success": False, "error": "Species output with 100 classes was not found"}))
        sys.exit(1)

    # Jika output belum softmax, softmax-kan. Jika sudah probability, biarkan.
    species_probs = species_output
    if np.min(species_probs) < 0 or np.max(species_probs) > 1.0 or not np.isclose(np.sum(species_probs), 1.0, atol=1e-2):
        species_probs = softmax(species_probs)

    class_index = int(np.argmax(species_probs))
    species_name = labels[class_index]
    confidence = float(species_probs[class_index])

    toxicity_score = None
    is_toxic = False
    if toxicity_output is not None:
        raw = float(np.ravel(toxicity_output)[0])
        toxicity_score = raw if 0.0 <= raw <= 1.0 else float(sigmoid(raw))
        is_toxic = toxicity_score >= 0.5

    print(json.dumps({
        "success": True,
        "species": species_name,
        "class_index": class_index,
        "confidence": confidence,
        "is_toxic": bool(is_toxic),
        "toxicity_score": toxicity_score,
    }))


if __name__ == "__main__":
    main()
