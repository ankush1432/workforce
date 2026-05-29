class AppConfig {
  static const appName = 'Face Attendance';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://wages.aarvedsol.com/api/v1',
  );

  /// Cosine similarity threshold (embeddings are L2-normalized).
  static const faceMatchThreshold = 0.75;

  /// FaceNet output dimension sent to API.
  static const embeddingSize = 192;

  static const facenetModelPath = 'assets/models/mobilefacenet.tflite';
  static const facenetInputSize = 112;

  // Face quality gates
  static const minFaceQualityScore = 0.55;
  static const minFaceSizeRatio = 0.12;
  static const maxFaceSizeRatio = 0.65;
  static const minSharpnessVariance = 50.0;
  static const minBrightness = 50.0;
  static const maxBrightness = 220.0;

  /// Android camera frame skip for liveness (process every Nth frame).
  static const livenessFrameSkip = 3;
}
