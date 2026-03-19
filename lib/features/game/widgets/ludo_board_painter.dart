import 'package:flutter/material.dart';

class LudoBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double width = size.width;
    final double height = size.height;

    // Colors
    final Color red = Colors.red.shade400;
    final Color green = Colors.green.shade400;
    final Color yellow = Colors.yellow.shade400;
    final Color blue = Colors.blue.shade400;
    final Color white = Colors.white;

    // Draw the main colored areas
    paint.color = green;
    canvas.drawRect(Rect.fromLTWH(0, 0, width * 0.4, height * 0.4), paint);

    paint.color = red;
    canvas.drawRect(Rect.fromLTWH(width * 0.6, 0, width * 0.4, height * 0.4), paint);

    paint.color = blue;
    canvas.drawRect(Rect.fromLTWH(0, width * 0.6, width * 0.4, height * 0.4), paint);

    paint.color = yellow;
    canvas.drawRect(Rect.fromLTWH(width * 0.6, height * 0.6, width * 0.4, height * 0.4), paint);

    // Draw the center paths
    paint.color = white;
    canvas.drawRect(Rect.fromLTWH(width * 0.4, 0, width * 0.2, height), paint);
    canvas.drawRect(Rect.fromLTWH(0, height * 0.4, width, height * 0.2), paint);

    // Draw colored home paths
    paint.color = red;
    canvas.drawRect(Rect.fromLTWH(width * 0.6, height * 0.4, width * 0.4, height * 0.066), paint);
    paint.color = green;
    canvas.drawRect(Rect.fromLTWH(0, height * 0.4, width * 0.4, height * 0.066), paint);
    paint.color = blue;
    canvas.drawRect(Rect.fromLTWH(width * 0.4, height * 0.6, width * 0.066, height * 0.4), paint);
    paint.color = yellow;
    canvas.drawRect(Rect.fromLTWH(width * 0.4, 0, width * 0.066, height * 0.4), paint);

    // Draw the home triangles
    final pathRed = Path();
    pathRed.moveTo(width * 0.6, 0);
    pathRed.lineTo(width * 0.5, height * 0.5);
    pathRed.lineTo(width, height * 0.6);
    pathRed.close();
    paint.color = red;
    //canvas.drawPath(pathRed, paint);

    // Draw grid lines
    paint.color = Colors.black.withOpacity(0.2);
    paint.strokeWidth = 1.0;
    final double step = width / 15;
    for (int i = 0; i < 15; i++) {
      canvas.drawLine(Offset(i * step, 0), Offset(i * step, height), paint);
      canvas.drawLine(Offset(0, i * step), Offset(width, i * step), paint);
    }

    // Draw home icons
    _drawStar(canvas, size, paint, width*0.2, height*0.1);
    _drawStar(canvas, size, paint, width*0.1, height*0.2);
  }

  void _drawStar(Canvas canvas, Size size, Paint paint, double x, double y) {
    final path = Path();
    final double outerRadius = size.width / 30;
    final double innerRadius = outerRadius / 2;
    path.moveTo(size.width * 0.5 + x, size.height * 0.5 + y - outerRadius);

    for (int i = 0; i < 5; i++) {
      path.lineTo(
        size.width * 0.5 + x + innerRadius * cos((2 * pi / 5) * i + pi / 2),
        size.height * 0.5 + y - innerRadius * sin((2 * pi / 5) * i + pi / 2),
      );
      path.lineTo(
        size.width * 0.5 + x + outerRadius * cos((2 * pi / 5) * (i + 0.5) + pi / 2),
        size.height * 0.5 + y - outerRadius * sin((2 * pi / 5) * (i + 0.5) + pi / 2),
      );
    }
    path.close();
    paint.color = Colors.white;
    canvas.drawPath(path, paint);
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
