import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(.2)
      ..strokeWidth = 1;

    double cellSize = size.width / 4;

    /// خطوط عمودية
    for (int i = 1; i < 4; i++) {
      double dx = cellSize * i;
      canvas.drawLine(
        Offset(dx, 0),
        Offset(dx, size.height),
        paint,
      );
    }

    /// خطوط أفقية
    for (int i = 1; i < 4; i++) {
      double dy = cellSize * i;
      canvas.drawLine(
        Offset(0, dy),
        Offset(size.width, dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}