import 'dart:math';

import 'package:flutter/material.dart';

class CircularBorder extends StatelessWidget {
  final Color color;
  final double size;
  final double? width;
  final Widget? icon;

  const CircularBorder({
    Key? key,
    this.color = Colors.blue,
    this.size = 70,
    this.width = 7.0,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (icon != null) icon!,
          CustomPaint(
            size: Size(size, size),
            painter: MyPainter(
              completeColor: color,
              width: width!,
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Color completeColor;
  final double width;

  MyPainter({
    required this.completeColor,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final percent = (size.width * 0.001) / 2;

    final arcAngle = 2 * pi * percent;
    print('$radius - radius');
    print('$arcAngle - arcAngle');
    print('${radius / arcAngle} - divider');

    for (var i = 0; i < 8; i++) {
      final init = (-pi / 2) * (i / 2);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        init,
        arcAngle,
        false,
        complete,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
