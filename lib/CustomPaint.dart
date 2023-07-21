import 'package:deep_zoom/main.dart';
import 'package:deep_zoom/object/render_object.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

class MyCustomPainter extends CustomPainter {
  Paint myPaint = Paint();
  PaintObject paintObject;

  MyCustomPainter(this.paintObject);
  @override
  void paint(Canvas canvas, Size size) {
    myPaint.color = Colors.red;
    Rect rect = Rect.fromLTWH(
        paintObject.x, paintObject.y, paintObject.width, paintObject.height);
    canvas.drawRect(rect, myPaint);

    drawImage(canvas, rect, 0);
  }

  void drawImage(Canvas canvas, Rect rect, int i) {
    if (image != null) {
      paintImage(canvas: canvas, rect: rect, image: image!);
    }
    if (i < 10) {
      Rect newRect = Rect.fromLTWH(rect.left + rect.width * 0.4,
          rect.top + rect.height * 0.4, rect.width * 0.2, rect.height * 0.2);
      drawImage(canvas, newRect, ++i);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
