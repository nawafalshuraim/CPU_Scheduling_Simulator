import 'package:flutter/material.dart';
import '../models/models.dart';

const List<Color> processColors = [
  Color(0xFF4F8EF7), // P1  blue
  Color(0xFF50C5A0), // P2  teal
  Color(0xFFFF9F43), // P3  orange
  Color(0xFFFF6B6B), // P4  red
  Color(0xFFA29BFE), // P5  purple
  Color(0xFFFD79A8), // P6  pink
  Color(0xFF6C5CE7), // P7  violet
  Color(0xFF00CEC9), // P8  cyan
  Color(0xFFE17055), // P9  coral
  Color(0xFF74B9FF), // P10 sky
];

Color getProcessColor(int pid) {
  if (pid == -1) return const Color(0xFF3A4A6B);
  return processColors[(pid - 1) % processColors.length];
}

class GanttChart extends StatelessWidget {
  final List<GanttEntry> entries;

  const GanttChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox();

    const double unitWidth     = 52;
    const double barHeight     = 54;
    const double timeRowHeight = 28;
    final int    totalTime     = entries.last.end;
    final double totalWidth    = totalTime * unitWidth + 24;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        height: barHeight + timeRowHeight,
        child: CustomPaint(
          painter: _GanttPainter(
            entries:       entries,
            unitWidth:     unitWidth,
            barHeight:     barHeight,
            timeRowHeight: timeRowHeight,
          ),
        ),
      ),
    );
  }
}

class _GanttPainter extends CustomPainter {
  final List<GanttEntry> entries;
  final double unitWidth;
  final double barHeight;
  final double timeRowHeight;

  const _GanttPainter({
    required this.entries,
    required this.unitWidth,
    required this.barHeight,
    required this.timeRowHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint   = Paint();
    final borderPaint = Paint()
      ..color     = Colors.white.withOpacity(0.12)
      ..style     = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final entry in entries) {
      final left  = entry.start * unitWidth;
      final right = entry.end   * unitWidth;
      final rect  = Rect.fromLTWH(left, 0, right - left, barHeight);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

      final color = getProcessColor(entry.pid);
      fillPaint.color =
          entry.pid == -1 ? color.withOpacity(0.25) : color.withOpacity(0.82);

      canvas.drawRRect(rRect, fillPaint);
      canvas.drawRRect(rRect, borderPaint);

      // Label
      final label = entry.pid == -1 ? 'IDLE' : 'P${entry.pid}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color:      entry.pid == -1 ? Colors.white30 : Colors.white,
            fontSize:   13,
            fontWeight: entry.pid == -1 ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final barWidth = right - left;
      if (tp.width <= barWidth - 6) {
        tp.paint(
          canvas,
          Offset(left + (barWidth - tp.width) / 2, (barHeight - tp.height) / 2),
        );
      }
    }

    // Time markers
    final drawn = <int>{};
    for (final e in entries) {
      for (final t in [e.start, e.end]) {
        if (!drawn.contains(t)) {
          drawn.add(t);
          final x = t * unitWidth;

          canvas.drawLine(
            Offset(x, barHeight),
            Offset(x, barHeight + 6),
            Paint()..color = Colors.white24..strokeWidth = 1,
          );

          final tp = TextPainter(
            text: TextSpan(
              text:  '$t',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x - tp.width / 2, barHeight + 8));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
