import 'dart:math';

import 'package:flutter/material.dart';

class ProgressPath extends StatelessWidget {
  const ProgressPath({
    super.key,
    required this.progress,
    this.size = 220,
    this.enable3d = false,
  });

  final double progress;
  final double size;
  final bool enable3d;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressPainter(progress: progress, enable3d: enable3d),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({required this.progress, required this.enable3d});

  final double progress;
  final bool enable3d;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint track = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = enable3d ? 7 : 6
      ..strokeCap = StrokeCap.round;

    final Paint fill = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.lightBlueAccent.shade100,
          Colors.blueAccent.shade200,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = enable3d ? 9 : 8
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    final start = pi * 0.9;
    final sweep = pi * 1.2;

    Path path = Path()
      ..addArc(Rect.fromCircle(center: center, radius: radius), start, sweep);

    if (enable3d) {
      final m = Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateX(0.9)
        ..scale(1.05, 1.05);
      path = path.transform(m.storage);
    }

    // Slight shadow below to emphasize depth.
    if (enable3d) {
      final shadow = Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      canvas.save();
      canvas.translate(0, 6);
      canvas.drawPath(path, shadow);
      canvas.restore();
    }

    canvas.drawPath(path, track);

    final PathMetric? metric = path.computeMetrics().first;
    final double len = metric.length * progress.clamp(0, 1);
    final Path extract = metric.extractPath(0, len);
    canvas.drawPath(extract, fill);

    final tangent = metric.getTangentForOffset(len);
    if (tangent != null) {
      final planePaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: tangent.position, radius: 18));

      canvas.save();

      if (enable3d) {
        final tilt = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(-0.35)
          ..rotateZ(tangent.angle);
        canvas.transform(tilt.storage);
      } else {
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(tangent.angle);
      }

      if (enable3d) {
        // Reposition after perspective transform
        canvas.translate(tangent.position.dx, tangent.position.dy);
      }

      final body = Path()
        ..moveTo(10, 0)
        ..quadraticBezierTo(-6, -8, -18, 0)
        ..quadraticBezierTo(-6, 8, 10, 0)
        ..close();
      canvas.drawShadow(body, Colors.black45, 4, false);
      canvas.drawPath(body, planePaint);

      final wing = Path()
        ..moveTo(-6, 0)
        ..lineTo(-2, -10)
        ..lineTo(12, 0)
        ..close();
      canvas.drawPath(wing, Paint()..color = Colors.white.withOpacity(0.85));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.enable3d != enable3d;
}
