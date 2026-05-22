import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/utils/weather_theme.dart';

class SunriseSunsetWidget extends StatelessWidget {
  final DateTime sunrise;
  final DateTime sunset;

  const SunriseSunsetWidget({
    super.key,
    required this.sunrise,
    required this.sunset,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDayMs = sunset.millisecondsSinceEpoch - sunrise.millisecondsSinceEpoch;
    final elapsedMs = now.millisecondsSinceEpoch - sunrise.millisecondsSinceEpoch;
    final progress = (elapsedMs / totalDayMs).clamp(0.0, 1.0);
    final fmt = DateFormat('h:mm a');

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeLabel(Icons.wb_twilight_rounded, 'Sunrise', fmt.format(sunrise)),
              _timeLabel(Icons.nightlight_round, 'Sunset', fmt.format(sunset),
                  alignRight: true),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: CustomPaint(
              painter: _SunArcPainter(progress),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _dayLengthLabel(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeLabel(IconData icon, String label, String time,
      {bool alignRight = false}) {
    final children = [
      Icon(icon, color: Colors.amber.shade300, size: 18),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 11)),
          Text(time,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    ];
    return Row(
      children: alignRight ? children.reversed.toList() : children,
    );
  }

  String _dayLengthLabel() {
    final mins = sunset.difference(sunrise).inMinutes;
    return 'Daylight: ${mins ~/ 60}h ${mins % 60}m';
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  _SunArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background arc
    canvas.drawArc(
      rect,
      pi,
      pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        pi,
        pi * progress,
        false,
        Paint()
          ..color = Colors.amber.shade300
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Sun position
    final angle = pi + pi * progress;
    final sx = cx + r * cos(angle);
    final sy = cy + r * sin(angle);

    // Glow
    canvas.drawCircle(
      Offset(sx, sy),
      10,
      Paint()
        ..color = Colors.amber.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Sun dot
    canvas.drawCircle(
      Offset(sx, sy),
      5,
      Paint()..color = Colors.amber.shade300,
    );
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}
