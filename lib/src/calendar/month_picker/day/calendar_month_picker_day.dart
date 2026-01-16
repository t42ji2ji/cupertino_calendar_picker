// Copyright (c) 2024 Philip Softworks. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:cupertino_calendar_picker/src/src.dart';
import 'package:flutter/material.dart';

class CalendarMonthPickerDay extends StatelessWidget {
  const CalendarMonthPickerDay({
    required this.dayDate,
    required this.style,
    required this.backgroundCircleSize,
    this.onDaySelected,
    this.hasMarker = false,
    this.markerColor,
    this.hasDraftMarker = false,
    this.draftMarkerColor,
    this.usePawForCurrentDay = false,
    super.key,
  });

  final DateTime dayDate;
  final CalendarMonthPickerDayStyle style;
  final double backgroundCircleSize;
  final ValueChanged<DateTime>? onDaySelected;
  final bool hasMarker;
  final Color? markerColor;
  final bool hasDraftMarker;
  final Color? draftMarkerColor;
  final bool usePawForCurrentDay;

  @override
  Widget build(BuildContext context) {
    final CalendarMonthPickerDayStyle dayStyle = style;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDaySelected != null ? () => onDaySelected?.call(dayDate) : null,
      child: CustomPaint(
        painter: CalendarMonthPickerDayPainter(
          day: '${dayDate.day}',
          textScaler: context.textScaler,
          style: style.textStyle,
          backgroundCircleColor:
              dayStyle is CalendarMonthPickerBackgroundCircledDayStyle
                  ? dayStyle.backgroundCircleColor
                  : null,
          backgroundCircleSize: backgroundCircleSize,
          hasMarker: hasMarker,
          markerColor: markerColor,
          hasDraftMarker: hasDraftMarker,
          draftMarkerColor: draftMarkerColor,
          usePawForCurrentDay: usePawForCurrentDay,
        ),
      ),
    );
  }
}

class CalendarMonthPickerDayPainter extends CustomPainter {
  const CalendarMonthPickerDayPainter({
    required this.day,
    required this.textScaler,
    required this.style,
    required this.backgroundCircleSize,
    this.backgroundCircleColor,
    this.hasMarker = false,
    this.markerColor,
    this.hasDraftMarker = false,
    this.draftMarkerColor,
    this.usePawForCurrentDay = false,
  });

  final TextScaler textScaler;
  final String day;
  final TextStyle style;
  final Color? backgroundCircleColor;
  final double backgroundCircleSize;
  final bool hasMarker;
  final Color? markerColor;
  final bool hasDraftMarker;
  final Color? draftMarkerColor;
  final bool usePawForCurrentDay;

  @override
  void paint(Canvas canvas, Size size) {
    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      style.getParagraphStyle(textAlign: TextAlign.center),
    )
      ..pushStyle(style.getTextStyle(textScaler: textScaler))
      ..addText(day);

    final Paragraph dayPragrapth = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: size.width));

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double dayHalfHeight = dayPragrapth.height / 2;

    if (backgroundCircleColor != null) {
      if (usePawForCurrentDay) {
        _drawPawPrint(
          canvas,
          Offset(centerX, centerY),
          backgroundCircleColor!,
        );
      } else {
        _drawBackgroundCircle(
          canvas,
          Offset(centerX, centerY),
          backgroundCircleColor!,
        );
      }
    }

    final double dayBottomY = centerY - dayHalfHeight;
    _drawDayParagraph(
      canvas,
      Offset(0.0, dayBottomY),
      dayPragrapth,
    );

    // Draw marker dot below the day number
    if (hasMarker) {
      _drawMarker(
        canvas,
        Offset(centerX, centerY + dayHalfHeight + 4),
        markerColor ?? const Color(0xFF007AFF),
      );
    } else if (hasDraftMarker) {
      _drawHollowMarker(
        canvas,
        Offset(centerX, centerY + dayHalfHeight + 4),
        draftMarkerColor ?? const Color(0xFF007AFF),
      );
    }
  }

  void _drawMarker(Canvas canvas, Offset offset, Color color) {
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(offset, 3.0, paint);
  }

  void _drawHollowMarker(Canvas canvas, Offset offset, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(offset, 3.0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final CalendarMonthPickerDayPainter oldPainter =
        oldDelegate as CalendarMonthPickerDayPainter;
    return style != oldPainter.style ||
        backgroundCircleColor != oldPainter.backgroundCircleColor ||
        day != oldPainter.day ||
        backgroundCircleSize != oldPainter.backgroundCircleSize ||
        textScaler != oldPainter.textScaler ||
        hasMarker != oldPainter.hasMarker ||
        markerColor != oldPainter.markerColor ||
        hasDraftMarker != oldPainter.hasDraftMarker ||
        draftMarkerColor != oldPainter.draftMarkerColor ||
        usePawForCurrentDay != oldPainter.usePawForCurrentDay;
  }

  void _drawDayParagraph(Canvas canvas, Offset offset, Paragraph day) {
    canvas.drawParagraph(day, offset);
  }

  void _drawBackgroundCircle(Canvas canvas, Offset offset, Color color) {
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(
      offset,
      backgroundCircleSize / 2,
      paint,
    );
  }

  void _drawPawPrint(Canvas canvas, Offset offset, Color color) {
    final Paint paint = Paint()..color = color;

    // SVG original bounds: roughly 540x510, centered around (28, 1105)
    // Scale to fit backgroundCircleSize (larger divisor = smaller paw)
    final double scale = backgroundCircleSize / 700;

    // Translate to center the paw at offset
    canvas.save();
    canvas.translate(offset.dx - 28 * scale, offset.dy - 1145 * scale);
    canvas.scale(scale);

    final Path path = Path();

    // Left outer toe
    path.moveTo(-126.267, 1038.85);
    path.cubicTo(-103.53, 1089.29, -110.475, 1141.6, -141.777, 1155.72);
    path.cubicTo(-173.08, 1169.84, -216.887, 1140.41, -239.622, 1089.98);
    path.cubicTo(-262.359, 1039.55, -255.415, 987.235, -224.112, 973.117);
    path.cubicTo(-192.809, 959.003, -149.004, 988.434, -126.267, 1038.85);
    path.close();

    // Right outer toe
    path.moveTo(183.155, 1038.85);
    path.cubicTo(160.417, 1089.29, 167.362, 1141.6, 198.667, 1155.72);
    path.cubicTo(229.97, 1169.84, 273.773, 1140.41, 296.513, 1089.98);
    path.cubicTo(319.247, 1039.55, 312.302, 987.235, 281.0, 973.117);
    path.cubicTo(249.699, 959.003, 206.047, 988.434, 183.155, 1038.85);
    path.close();

    // Left inner toe
    path.moveTo(6.7856, 937.757);
    path.cubicTo(18.4404, 991.826, 0.6748, 1041.52, -32.8931, 1048.76);
    path.cubicTo(-66.4585, 1055.99, -103.118, 1018.02, -114.771, 963.956);
    path.cubicTo(-126.424, 909.888, -108.659, 860.192, -75.092, 852.959);
    path.cubicTo(-41.5251, 845.723, -5.0918, 883.688, 6.7856, 937.757);
    path.close();

    // Right inner toe
    path.moveTo(49.2676, 937.803);
    path.cubicTo(37.623, 991.871, 55.376, 1041.57, 88.9414, 1048.8);
    path.cubicTo(122.509, 1056.04, 159.167, 1018.07, 170.819, 964.003);
    path.cubicTo(182.473, 909.934, 164.71, 860.238, 131.141, 853.005);
    path.cubicTo(97.5732, 845.771, 60.9162, 883.734, 49.2676, 937.803);
    path.close();

    // Main pad
    path.moveTo(-35.2275, 1118.5);
    path.cubicTo(-43.4199, 1132.65, -81.3838, 1179.49, -107.642, 1195.47);
    path.cubicTo(-133.898, 1211.45, -166.434, 1234.85, -160.974, 1288.58);
    path.cubicTo(-155.517, 1342.32, -100.399, 1365.32, -64.1148, 1363.28);
    path.cubicTo(-27.8281, 1361.25, 40.5845, 1354.57, 89.4282, 1361.34);
    path.cubicTo(138.2695, 1368.11, 199.9145, 1362.98, 214.3505, 1311.53);
    path.cubicTo(228.7865, 1260.08, 196.5005, 1227.3, 171.3065, 1208.7);
    path.cubicTo(146.1135, 1190.11, 104.0415, 1134.5, 91.0796, 1108.97);
    path.cubicTo(78.1196, 1083.45, 12.1528, 1036.71, -35.2275, 1118.5);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }
}
