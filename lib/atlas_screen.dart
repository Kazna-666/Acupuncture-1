import 'package:flutter/material.dart';
import 'l10n.dart';
import 'meridian_data.dart';
import 'points_data.dart';
import 'points_screen.dart';

class _BodyPoint {
  final String code;
  final double x, y; // нормализовано: 0-100 по ширине, 0-140 по высоте
  const _BodyPoint(this.code, this.x, this.y);
}

const List<_BodyPoint> _frontPoints = [
  _BodyPoint('EX-HN3', 50, 9), _BodyPoint('EX-HN5', 44, 12), _BodyPoint('GV26', 50, 15),
  _BodyPoint('LI20', 57, 14), _BodyPoint('ST6', 56, 17), _BodyPoint('CV22', 50, 29),
  _BodyPoint('CV17', 50, 38), _BodyPoint('CV12', 50, 50), _BodyPoint('CV6', 50, 60),
  _BodyPoint('CV4', 50, 66), _BodyPoint('ST25', 38, 56), _BodyPoint('ST21', 40, 44),
  _BodyPoint('LR14', 36, 34), _BodyPoint('LR13', 33, 48), _BodyPoint('SP15', 33, 58),
  _BodyPoint('GB26', 31, 72), _BodyPoint('LU5', 24, 58), _BodyPoint('LU7', 20, 66),
  _BodyPoint('LU9', 18, 69), _BodyPoint('PC6', 26, 60), _BodyPoint('HT7', 28, 64),
  _BodyPoint('LI11', 30, 48), _BodyPoint('LI4', 15, 72), _BodyPoint('TE5', 21, 63),
  _BodyPoint('ST36', 40, 96), _BodyPoint('SP9', 44, 100), _BodyPoint('SP6', 44, 116),
  _BodyPoint('KI3', 44, 124), _BodyPoint('LR3', 45, 131),
];

const List<_BodyPoint> _backPoints = [
  _BodyPoint('GV20', 50, 10), _BodyPoint('GB20', 44, 20), _BodyPoint('GV16', 50, 21),
  _BodyPoint('GV14', 50, 30), _BodyPoint('GB21', 33, 28), _BodyPoint('SI11', 35, 34),
  _BodyPoint('SI14', 37, 30), _BodyPoint('GV9', 50, 40), _BodyPoint('BL13', 42, 32),
  _BodyPoint('BL15', 42, 36), _BodyPoint('BL17', 42, 38), _BodyPoint('BL18', 42, 40),
  _BodyPoint('BL20', 42, 44), _BodyPoint('BL21', 42, 48), _BodyPoint('GV6', 50, 48),
  _BodyPoint('GV4', 50, 54), _BodyPoint('BL23', 42, 54), _BodyPoint('BL25', 42, 62),
  _BodyPoint('BL32', 45, 68), _BodyPoint('GV2', 50, 72), _BodyPoint('GB30', 38, 74),
  _BodyPoint('BL40', 58, 102), _BodyPoint('BL57', 58, 112), _BodyPoint('BL60', 58, 124),
  _BodyPoint('BL62', 57, 126), _BodyPoint('GB34', 55, 100), _BodyPoint('SI3', 83, 70),
];

/// Схема тела спереди/сзади с кликабельными точками
class AtlasScreen extends StatefulWidget {
  const AtlasScreen({Key? key}) : super(key: key);
  @override
  State<AtlasScreen> createState() => _AtlasScreenState();
}

class _AtlasScreenState extends State<AtlasScreen> {
  bool _front = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ChoiceChip(
              label: Text(tr(tFront)),
              selected: _front,
              selectedColor: const Color(0xFFD4AF37),
              labelStyle: TextStyle(color: _front ? Colors.black : Colors.white),
              onSelected: (_) => setState(() => _front = true)),
          const SizedBox(width: 10),
          ChoiceChip(
              label: Text(tr(tBack)),
              selected: !_front,
              selectedColor: const Color(0xFFD4AF37),
              labelStyle: TextStyle(color: !_front ? Colors.black : Colors.white),
              onSelected: (_) => setState(() => _front = false)),
        ]),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth.clamp(0.0, 340.0);
            final h = w * 1.4;
            final points = _front ? _frontPoints : _backPoints;
            return Center(
              child: GestureDetector(
                onTapUp: (d) => _tap(context, d.localPosition, Size(w, h), points),
                child: CustomPaint(
                    size: Size(w, h), painter: _BodyPainter(_front, points)),
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
          child: Text(tr(tSymmetry),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ),
      ]),
    );
  }

  void _tap(BuildContext context, Offset local, Size size, List<_BodyPoint> points) {
    final fx = local.dx / size.width * 100;
    final fy = local.dy / size.height * 140;
    _BodyPoint? best;
    double bestD2 = 4.5 * 4.5;
    for (final p in points) {
      final dx = p.x - fx, dy = p.y - fy;
      final d2 = dx * dx + dy * dy;
      if (d2 < bestD2) {
        bestD2 = d2;
        best = p;
      }
    }
    if (best == null) return;
    final m = meridianOfCode(best.code);
    final p = PointsData.find(best.code);
    if (p != null) showPointSheet(context, m, p);
  }
}

class _BodyPainter extends CustomPainter {
  final bool front;
  final List<_BodyPoint> points;
  const _BodyPainter(this.front, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100.0, sy = size.height / 140.0;
    Offset f(double x, double y) => Offset(x * sx, y * sy);
    final body = Paint()..color = const Color(0xFF26313A);
    final edge = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final mid = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Голова и шея
    canvas.drawCircle(f(50, 12), 9.5 * sx, body);
    canvas.drawCircle(f(50, 12), 9.5 * sx, edge);
    canvas.drawRect(Rect.fromLTWH(46 * sx, 21 * sy, 8 * sx, 6 * sy), body);
    // Торс
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(30 * sx, 26 * sy, 40 * sx, 52 * sy), Radius.circular(10 * sx)),
        body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(30 * sx, 26 * sy, 40 * sx, 52 * sy), Radius.circular(10 * sx)),
        edge);
    // Руки
    if (front) {
      canvas.drawLine(f(31, 30), f(17, 70), body..strokeWidth = 9 * sx);
      canvas.drawLine(f(31, 30), f(17, 70), edge..strokeWidth = 9 * sx);
      canvas.drawLine(f(69, 30), f(83, 70), body..strokeWidth = 9 * sx);
      canvas.drawLine(f(69, 30), f(83, 70), edge..strokeWidth = 9 * sx);
    } else {
      canvas.drawLine(f(31, 30), f(17, 70), body..strokeWidth = 9 * sx);
      canvas.drawLine(f(31, 30), f(17, 70), edge..strokeWidth = 9 * sx);
      canvas.drawLine(f(69, 30), f(83, 70), body..strokeWidth = 9 * sx);
      canvas.drawLine(f(69, 30), f(83, 70), edge..strokeWidth = 9 * sx);
    }
    // Ноги
    for (final lx in [39.0, 61.0]) {
      canvas.drawLine(f(lx, 78), f(lx, 126), body..strokeWidth = 10 * sx);
      canvas.drawLine(f(lx, 78), f(lx, 126), edge..strokeWidth = 10 * sx);
    }
    // Срединная линия (Ду-май / Жэнь-май)
    canvas.drawLine(f(50, 26), f(50, 76), mid);

    for (final p in points) {
      final c = f(p.x, p.y);
      canvas.drawCircle(c, 6.0 * sx, Paint()..color = const Color(0xFF27AE60).withOpacity(0.28));
      canvas.drawCircle(c, 3.0 * sx, Paint()..color = const Color(0xFF27AE60));
      canvas.drawCircle(c, 3.0 * sx,
          Paint()..color = Colors.black.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.front != front || old.points != points;
}
