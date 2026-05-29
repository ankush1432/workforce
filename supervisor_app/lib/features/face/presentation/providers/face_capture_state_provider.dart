import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the latest face scan embedding for optional hand-off between screens.
final lastFaceEmbeddingProvider = StateProvider<({List<double> embedding, double quality})?>(
  (ref) => null,
);
