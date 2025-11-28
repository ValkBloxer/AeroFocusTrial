import 'dart:math';

import 'package:flutter/material.dart';

class ProgressPath extends StatelessWidget {
  const ProgressPath({super.key, required this.progress, this.size = 220});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressPainter(progress: progress),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint track = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final Paint fill = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.lightBlueAccent.shade100,
          Colors.blueAccent.shade200,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    path.addArc(Rect.fromCircle(center: center, radius: radius), pi * 0.9, pi * 1.2);

    canvas.drawPath(path, track);

    final PathMetric? metric = path.computeMetrics().first;
    final double len = metric.length * progress.clamp(0, 1);
    final Path extract = metric.extractPath(0, len);
    canvas.drawPath(extract, fill);

    final tangent = metric.getTangentForOffset(len);
    if (tangent != null) {
      final planePaint = Paint()..color = Colors.white;
      canvas.drawCircle(tangent.position, 8, planePaint);
      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(tangent.angle);
      final triangle = Path()
        ..moveTo(0, 0)
        ..lineTo(-12, -8)
        ..lineTo(-12, 8)
        ..close();
      canvas.drawPath(triangle, planePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
