import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/config/app_config.dart';

final faceMatcherProvider = Provider<FaceMatcher>((ref) => const FaceMatcher());

class FaceMatchResult {
  const FaceMatchResult({
    required this.matched,
    required this.similarity,
    required this.threshold,
  });

  final bool matched;
  final double similarity;
  final double threshold;
}

/// Cosine similarity matching for L2-normalized face embeddings.
class FaceMatcher {
  const FaceMatcher({this.threshold = AppConfig.faceMatchThreshold});

  final double threshold;

  double cosineSimilarity(List<double> a, List<double> b) {
    final len = math.min(a.length, b.length);
    if (len == 0) return 0;

    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;

    for (var i = 0; i < len; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  FaceMatchResult match(List<double> probe, List<double> reference) {
    final similarity = cosineSimilarity(probe, reference);
    return FaceMatchResult(
      matched: similarity >= threshold,
      similarity: similarity,
      threshold: threshold,
    );
  }

  /// Best match from a gallery of embeddings.
  FaceMatchResult matchBest(
    List<double> probe,
    List<List<double>> gallery,
  ) {
    if (gallery.isEmpty) {
      return FaceMatchResult(matched: false, similarity: 0, threshold: threshold);
    }

    var best = -1.0;
    for (final ref in gallery) {
      final s = cosineSimilarity(probe, ref);
      if (s > best) best = s;
    }

    return FaceMatchResult(
      matched: best >= threshold,
      similarity: best,
      threshold: threshold,
    );
  }
}
