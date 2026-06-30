import 'package:flutter/material.dart';
import 'package:supervisor_app/features/face/data/liveness_detection_service.dart';

/// Visual guide for active liveness steps over the camera preview.
class LivenessOverlay extends StatelessWidget {
  const LivenessOverlay({
    super.key,
    required this.session,
  });

  final LivenessSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final complete = session.isComplete;
    final faceVerified = session.step == LivenessStep.faceVerified;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final center = Offset(size.width / 2, size.height * 0.4);
          final circleSize = size.width * 0.68;
          final faceRect = Rect.fromCenter(center: center, width: circleSize, height: circleSize);

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _FaceMaskPainter(faceRect: faceRect),
                size: size,
              ),
              CustomPaint(
                painter: _FaceCirclePainter(
                  faceRect: faceRect,
                  color: complete ? Colors.greenAccent : colorScheme.primary,
                  complete: complete,
                ),
                size: size,
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: session.progress,
                        minHeight: 5,
                        backgroundColor: Colors.white24,
                        color: complete ? Colors.greenAccent : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: faceVerified
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  session.instruction,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              session.instruction,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FaceMaskPainter extends CustomPainter {
  _FaceMaskPainter({required this.faceRect});

  final Rect faceRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addOval(faceRect);
    final mask = Path.combine(PathOperation.difference, overlay, cutout);
    canvas.drawPath(
      mask,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _FaceMaskPainter oldDelegate) =>
      oldDelegate.faceRect != faceRect;
}

class _FaceCirclePainter extends CustomPainter {
  _FaceCirclePainter({
    required this.faceRect,
    required this.color,
    required this.complete,
  });

  final Rect faceRect;
  final Color color;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: complete ? 1.0 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = complete ? 4 : 3;
    canvas.drawOval(faceRect, paint);

    if (complete) {
      canvas.drawOval(
        faceRect.inflate(6),
        Paint()
          ..color = Colors.greenAccent.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FaceCirclePainter oldDelegate) =>
      oldDelegate.faceRect != faceRect ||
      oldDelegate.color != color ||
      oldDelegate.complete != complete;
}
