# FaceNet TFLite model

Place your FaceNet model here:

```
assets/models/facenet.tflite
```

## Recommended model

- Mobile FaceNet TFLite (128-D or 512-D output; app normalizes to **128 dimensions**)
- Input: **160×160×3** float32, normalized as `(pixel - 127.5) / 128.0`

## Obtain a model

1. Export from TensorFlow Hub FaceNet mobile checkpoint to TFLite, or  
2. Use a pre-converted `facenet.tflite` compatible with 160×160 RGB input.

Without this file, face registration and check-in will fail at model load time.
