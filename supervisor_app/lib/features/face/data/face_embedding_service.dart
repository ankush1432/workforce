import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supervisor_app/features/face/data/face_embedding_generator.dart';
import 'package:supervisor_app/features/face/data/face_matcher.dart';
import 'package:supervisor_app/features/face/data/liveness_detection_service.dart';

/// Facade used by existing screens — delegates to FaceNet pipeline (no mock embeddings).
final faceEmbeddingServiceProvider = Provider<FaceEmbeddingService>((ref) {
  final service = FaceEmbeddingService(
    generator: ref.watch(faceEmbeddingGeneratorProvider),
    matcher: ref.watch(faceMatcherProvider),
    liveness: ref.watch(livenessDetectionServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

class FaceEmbeddingService {
  FaceEmbeddingService({
    required FaceEmbeddingGenerator generator,
    required FaceMatcher matcher,
    required LivenessDetectionService liveness,
  })  : _generator = generator,
        _matcher = matcher,
        _liveness = liveness;

  final FaceEmbeddingGenerator _generator;
  final FaceMatcher _matcher;
  final LivenessDetectionService _liveness;

  Future<void> warmUp() => _generator.warmUp();

  LivenessSession startLivenessSession() => _liveness.startSession();

  Future<List<Face>> detectFaces(InputImage image) => _generator.detectFaces(image);

  Future<void> processLivenessFrame(InputImage image, LivenessSession session) =>
      _generator.processLivenessFrame(image, session);

  /// Real 128-dimensional FaceNet embedding (L2-normalized).
  Future<List<double>> generateEmbedding(
    InputImage image, {
    bool requireLiveness = false,
    LivenessSession? livenessSession,
  }) async {
    final result = await _generator.generateFromInputImage(
      image,
      requireLiveness: requireLiveness,
      livenessSession: livenessSession,
    );
    return result.embedding;
  }

  Future<FaceEmbeddingResult> generateEmbeddingWithQuality(
    InputImage image, {
    bool requireLiveness = false,
    LivenessSession? livenessSession,
  }) =>
      _generator.generateFromInputImage(
        image,
        requireLiveness: requireLiveness,
        livenessSession: livenessSession,
      );

  double cosineSimilarity(List<double> a, List<double> b) =>
      _matcher.cosineSimilarity(a, b);

  FaceMatchResult match(List<double> probe, List<double> reference) =>
      _matcher.match(probe, reference);

  void dispose() {
    // Generator and liveness are managed by their own Riverpod providers.
  }
}
