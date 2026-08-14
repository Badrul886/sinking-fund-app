import 'dart:math';
import 'package:flutter/material.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/money.dart';
import '../../../domain/trajectory.dart';

class TrajectoryChart extends StatelessWidget {
  final CalendarDate startDate;
  final CalendarDate targetDate;
  final CalendarDate currentDate;
  final Money targetAmount;
  final Trajectory trajectory;
  final String semanticsLabel;

  const TrajectoryChart({
    super.key,
    required this.startDate,
    required this.targetDate,
    required this.currentDate,
    required this.targetAmount,
    required this.trajectory,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _TrajectoryPainter(
          startDate: startDate,
          targetDate: targetDate,
          currentDate: currentDate,
          targetAmount: targetAmount,
          trajectory: trajectory,
          theme: Theme.of(context),
        ),
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  final CalendarDate startDate;
  final CalendarDate targetDate;
  final CalendarDate currentDate;
  final Money targetAmount;
  final Trajectory trajectory;
  final ThemeData theme;

  _TrajectoryPainter({
    required this.startDate,
    required this.targetDate,
    required this.currentDate,
    required this.targetAmount,
    required this.trajectory,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final startMs = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    ).millisecondsSinceEpoch;
    final targetMs = DateTime.utc(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    ).millisecondsSinceEpoch;
    final durationMs = targetMs - startMs;

    // Avoid division by zero if start == target
    final effectiveDuration = max(durationMs, 86400000);

    // Find max Y
    double maxY = targetAmount.minorUnits.toDouble();

    for (final p in trajectory.historicalPoints) {
      maxY = max(maxY, p.balance.minorUnits.toDouble());
    }
    for (final p in trajectory.futurePoints) {
      maxY = max(maxY, p.projectedBalance.minorUnits.toDouble());
    }

    final effectiveMaxY = max(maxY, 1.0); // avoid division by zero

    double getX(CalendarDate date) {
      final ms = DateTime.utc(
        date.year,
        date.month,
        date.day,
      ).millisecondsSinceEpoch;
      final progress = (ms - startMs) / effectiveDuration;
      // Clamp between 0 and 1
      return min(max(progress * size.width, 0.0), size.width);
    }

    double getY(Money money) {
      final val = money.minorUnits.toDouble();
      final progress = val / effectiveMaxY;
      // Invert Y so 0 is at bottom
      return size.height - (progress * size.height);
    }

    // 1. Draw Target Line
    final targetY = getY(targetAmount);
    final targetPaint = Paint()
      ..color = theme.colorScheme.onSurfaceVariant.withValues(alpha: 128 / 255)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw dashed line
    double dashWidth = 5, dashSpace = 5, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(startX + dashWidth, targetY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 2. Draw Current Date Marker
    final currentX = getX(currentDate);
    final currentPaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 77 / 255)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, size.height),
      currentPaint,
    );

    // 3. Draw Historical Path
    if (trajectory.historicalPoints.isNotEmpty) {
      final histPath = Path();

      // Start from start date with initial balance 0, or link the points.
      // The requirement doesn't say to invent a 0 point.
      // Just render the points exactly as provided.
      for (int i = 0; i < trajectory.historicalPoints.length; i++) {
        final p = trajectory.historicalPoints[i];
        final x = getX(p.date);
        final y = getY(p.balance);

        if (i == 0) {
          histPath.moveTo(x, y);
        } else {
          histPath.lineTo(x, y);
        }
      }

      final histPaint = Paint()
        ..color = theme.colorScheme.primary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(histPath, histPaint);
    }

    // 4. Draw Future Path
    if (trajectory.futurePoints.isNotEmpty) {
      final futPath = Path();

      // Start from the last historical point if exists, else start from current date at 0
      double lastX;
      double lastY;

      if (trajectory.historicalPoints.isNotEmpty) {
        final lastPoint = trajectory.historicalPoints.last;
        lastX = getX(lastPoint.date);
        lastY = getY(lastPoint.balance);
      } else {
        lastX = currentX;
        lastY = size.height; // Y at 0 balance
      }

      futPath.moveTo(lastX, lastY);

      for (final p in trajectory.futurePoints) {
        futPath.lineTo(getX(p.date), getY(p.projectedBalance));
      }

      final futPaint = Paint()
        ..color = theme.colorScheme.primary.withValues(alpha: 128 / 255)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      // Quick dash path for future
      // Alternatively, use path_drawing if available, but native says no packages.
      // A dashed stroke can be approximated by drawing lines manually or just using a lighter stroke.
      // The plan states "dashed, semi-transparent stroke". We can do a basic dashed line over the path segments.

      // For simplicity in native Flutter without dashed path packages:
      // We will draw it as a solid semi-transparent line first.
      // To strictly follow "dashed", we can manually subdivide the lines.
      _drawDashedPath(canvas, futPath, futPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? 6.0 : 6.0;
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) {
    return oldDelegate.trajectory != trajectory ||
        oldDelegate.currentDate != currentDate ||
        oldDelegate.startDate != startDate ||
        oldDelegate.targetDate != targetDate ||
        oldDelegate.targetAmount != targetAmount;
  }
}
