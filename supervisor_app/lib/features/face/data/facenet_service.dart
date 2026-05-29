import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final facenetServiceProvider = Provider<FacenetService>((ref) {
  final service = FacenetService();
  ref.onDispose(service.dispose);
  return service;
});

/// Loads and runs the FaceNet TFLite model from [AppConfig.facenetModelPath].
class FacenetService {
  static const String _assetPath = AppConfig.facenetModelPath;

  Interpreter? _interpreter;
  bool _loading = false;

  int _inputHeight = AppConfig.facenetInputSize;
  int _inputWidth = AppConfig.facenetInputSize;
  int _outputSize = AppConfig.embeddingSize;

  bool get isLoaded => _interpreter != null;

  int get inputHeight => _inputHeight;
  int get inputWidth => _inputWidth;
  int get outputSize => _outputSize;

  Future<void> load() async {
    if (_interpreter != null || _loading) return;
    _loading = true;
    try {
      final options = InterpreterOptions()..threads = 2;
      if (!kIsWeb) {
        options.useNnApiForAndroid = true;
      }
      _interpreter = await Interpreter.fromAsset(_assetPath, options: options);
      _readTensorShapes();
    } on PlatformException catch (e) {
      debugPrint('FacenetService: model load failed ($_assetPath): $e');
      rethrow;
    } finally {
      _loading = false;
    }
  }

  void _readTensorShapes() {
    final interpreter = _interpreter;
    if (interpreter == null) return;

    final inputShape = interpreter.getInputTensor(0).shape;
    if (inputShape.length >= 3) {
      _inputHeight = inputShape[inputShape.length - 3];
      _inputWidth = inputShape[inputShape.length - 2];
    }

    final outputShape = interpreter.getOutputTensor(0).shape;
    if (outputShape.isNotEmpty) {
      _outputSize = outputShape.last;
    }
  }

  /// Input: RGB float32 flattened [height * width * 3], normalized to [-1, 1].
  Future<List<double>> runInference(Float32List input) async {
    await load();
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('FaceNet model not loaded. Add $_assetPath to assets.');
    }

    final expected = _inputHeight * _inputWidth * 3;
    if (input.length != expected) {
      throw ArgumentError('Expected $expected input values, got ${input.length}');
    }

    final input4d = _reshapeInput(input);
    final output = List.generate(
      1,
      (_) => List<double>.filled(_outputSize, 0),
    );

    interpreter.run(input4d, output);

    return _normalizeEmbedding(List<double>.from(output[0]));
  }

  List<List<List<List<double>>>> _reshapeInput(Float32List flat) {
    var i = 0;
    return List.generate(
      1,
      (_) => List.generate(
        _inputHeight,
        (y) => List.generate(
          _inputWidth,
          (x) {
            final r = flat[i++];
            final g = flat[i++];
            final b = flat[i++];
            return [r, g, b];
          },
        ),
      ),
    );
  }

  List<double> _normalizeEmbedding(List<double> raw) {
    var vector = raw;
    final target = AppConfig.embeddingSize;

    if (vector.length > target) {
      vector = vector.sublist(0, target);
    } else if (vector.length < target) {
      vector = [...vector, ...List.filled(target - vector.length, 0.0)];
    }

    var sumSq = 0.0;
    for (final v in vector) {
      sumSq += v * v;
    }
    if (sumSq == 0) return vector;

    final norm = math.sqrt(sumSq);
    return vector.map((v) => v / norm).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
