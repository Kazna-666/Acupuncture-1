import 'package:flutter/material.dart';
import 'l10n.dart';
import 'meridian_data.dart';
import 'points_data.dart';
import 'points_screen.dart';

class _ZonePoint {
  final String code;
  final double x, y; // 0-100 / 0-140 внутри зоны
  const _ZonePoint(this.code, this.x, this.y);
}

const Map<int, List<_ZonePoint>> _zonePoints = {
  0: [
    _ZonePoint('EX-HN3', 50, 36), _ZonePoint('EX-HN5', 36, 40), _ZonePoint('GV20', 50, 18),
    _ZonePoint('GV24', 50, 26), _ZonePoint('GV26', 50, 47), _ZonePoint('LI20', 58, 46),
    _ZonePoint('ST6', 68, 52), _ZonePoint('TE21', 30, 40), _ZonePoint('TE17', 32, 68),
    _ZonePoint('GB20', 32, 62), _ZonePoint('GB21', 26, 88), _ZonePoint('LI18', 60, 64),
    _ZonePoint('CV23', 50, 58), _ZonePoint('GV16', 50, 60),
  ],
  1: [
    _ZonePoint('CV22', 50, 24), _ZonePoint('CV17', 50, 34), _ZonePoint('CV12', 50, 52),
    _ZonePoint('CV9', 50, 58), _ZonePoint('CV6', 50, 66), _ZonePoint('CV4', 50, 74),
    _ZonePoint('ST25', 40, 58), _ZonePoint('ST21', 42, 46), _ZonePoint('LR14', 36, 30),
    _ZonePoint('LR13', 34, 54), _ZonePoint('SP15', 34, 62), _ZonePoint('GB26', 33, 80),
  ],
  2: [
    _ZonePoint('GV14', 50, 22), _ZonePoint('GV9', 50, 34), _ZonePoint('GV6', 50, 44),
    _ZonePoint('GV4', 50, 52), _ZonePoint('GV3', 50, 58), _ZonePoint('GV2', 50, 72),
    _ZonePoint('BL13', 42, 26), _ZonePoint('BL15', 42, 30), _ZonePoint('BL17', 42, 34),
    _ZonePoint('BL18', 42, 38), _ZonePoint('BL20', 42, 44), _ZonePoint('BL21', 42, 48),
    _ZonePoint('BL23', 42, 54), _ZonePoint('BL25', 42, 64), _ZonePoint('BL32', 44, 72),
    _ZonePoint('SI11', 36, 30), _ZonePoint('SI14', 38, 26), _ZonePoint('GB21', 38, 16),
    _ZonePoint('GB30', 38, 84),
  ],
  3: [
    _ZonePoint('LI15', 52, 14), _ZonePoint('LI14', 54, 20), _ZonePoint('LI11', 46, 38),
    _ZonePoint('LI10', 46, 44), _ZonePoint('LU5', 46, 58), _ZonePoint('LU7', 46, 72),
    _ZonePoint('LU9', 47, 78), _ZonePoint('PC6', 54, 64), _ZonePoint('HT7', 52, 74),
    _ZonePoint('TE5', 48, 68), _ZonePoint('SI3', 50, 96), _ZonePoint('LI4', 50, 104),
    _ZonePoint('PC8', 51, 100),
  ],
  4: [
    _ZonePoint('SP10', 53, 56), _ZonePoint('ST36', 47, 64), _ZonePoint('ST40', 52, 70),
    _ZonePoint('SP9', 53, 72), _ZonePoint('LR8', 52, 86), _ZonePoint('ST35', 50, 90),
    _ZonePoint('GB34', 54, 88), _ZonePoint('SP6', 53, 92), _ZonePoint('GB39', 46, 96),
    _ZonePoint('ST41', 47, 100), _ZonePoint('KI3', 46, 102), _ZonePoint('GB40', 52, 108),
    _ZonePoint('BL60', 46, 108), _ZonePoint('BL57', 47, 78), _ZonePoint('KI6', 45, 106),
    _ZonePoint('LR3', 48, 122), _ZonePoint('ST44', 50, 120), _ZonePoint('KI1', 50, 126),
  ],
};

/// 5 крупных зон тела с кликабельными точками
class ZonesScreen extends StatefulWidget {
  const ZonesScreen({Key? key}) : super(key: key);
  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  int _zone = 0;
  static const _zoneNames = [tHeadZ, tTorsoZ, tBackZ, tArmZ, tLegZ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 6),
      Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            for (int i = 0; i < 5; i++)
              ChoiceChip(
                  label: Text(tr(_zoneNames[i]), style: const TextStyle(fontSize: 12)),
                  selected: _zone == i,
                  selectedColor: const Color(0xFFD4AF37),
                  labelStyle:
                      TextStyle(color: _zone == i ? Colors.black : Colors.white),
                  onSelected: (_) => setState(() => _zone = i)),
          ]),
      Expanded(
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth.clamp(0.0, 340.0);
          final h = w * 1.4;
          return Center(child: GestureDetector(
            onTapUp: (d) => _tap(context, d.localPosition, Size(w, h)),
            child: CustomPaint(size: Size(w, h), painter: _ZonePainter(_zone))));
        }),
      ),
      Padding(padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: Text(tr(tSymmetry),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 11))),
    ]);
  }

  void _tap(BuildContext context, Offset local, Size size) {
    final fx = local.dx / size.width * 100;
    final fy = local.dy / size.height * 140;
    _ZonePoint? best;
    double bestD2 = 4.5 * 4.5;
    for (final p in _zonePoints[_zone]!) {
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

class _ZonePainter extends CustomPainter {
  final int zone;
  const _ZonePainter(this.zone);

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
      ..color = const Color(0xFFD4AF37).withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (zone == 0) {
      // Голова и шея
      canvas.drawCircle(f(50, 40), 30 * sx, body);
      canvas.drawCircle(f(50, 40), 30 * sx, edge);
      canvas.drawRect(Rect.fromLTWH(42 * sx, 66 * sy, 16 * sx, 30 * sy), body);
      canvas.drawLine(f(10, 96), f(90, 96), body..strokeWidth = 9 * sx);
      canvas.drawLine(f(10, 96), f(90, 96), edge..strokeWidth = 9 * sx);
      canvas.drawLine(f(50, 16), f(50, 62), mid);
    } else if (zone == 1) {
      // Грудь и живот
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(32 * sx, 18 * sy, 36 * sx, 88 * sy), Radius.circular(9 * sx)),
          body);
      canvas.drawRect(Rect.fromLTWH(42 * sx, 6 * sy, 16 * sx, 14 * sy), body);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(32 * sx, 18 * sy, 36 * sx, 88 * sy), Radius.circular(9 * sx)),
          edge);
      canvas.drawLine(f(50, 20), f(50, 82), mid);
    } else if (zone == 2) {
      // Спина и поясница
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(32 * sx, 18 * sy, 36 * sx, 92 * sy), Radius.circular(9 * sx)),
          body);
      canvas.drawRect(Rect.fromLTWH(42 * sx, 6 * sy, 16 * sx, 14 * sy), body);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(32 * sx, 18 * sy, 36 * sx, 92 * sy), Radius.circular(9 * sx)),
          edge);
      canvas.drawLine(f(50, 20), f(50, 110), mid);
    } else if (zone == 3) {
      // Рука и кисть
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(44 * sx, 8 * sy, 12 * sx, 80 * sy), Radius.circular(6 * sx)),
          body);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(44 * sx, 8 * sy, 12 * sx, 80 * sy), Radius.circular(6 * sx)),
          edge);
      canvas.drawCircle(f(50, 100), 13 * sx, body);
      canvas.drawCircle(f(50, 100), 13 * sx, edge);
      canvas.drawLine(f(50, 12), f(50, 86), mid);
    } else {
      // Нога и стопа
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(45 * sx, 10 * sy, 10 * sx, 88 * sy), Radius.circular(5 * sx)),
          body);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(45 * sx, 10 * sy, 10 * sx, 88 * sy), Radius.circular(5 * sx)),
          edge);
      canvas.drawOval(
          Rect.fromCenter(center: f(50, 112), width: 28 * sx, height: 34 * sy), body);
      canvas.drawOval(
          Rect.fromCenter(center: f(50, 112), width: 28 * sx, height: 34 * sy), edge);
      canvas.drawLine(f(50, 14), f(50, 94), mid);
    }

    for (final p in _zonePoints[zone]!) {
      final c = f(p.x, p.y);
      canvas.drawCircle(c, 6.5 * sx, Paint()..color = const Color(0xFF27AE60).withOpacity(0.25));
      canvas.drawCircle(c, 3.2 * sx, Paint()..color = const Color(0xFF27AE60));
    }
  }

  @override
  bool shouldRepaint(_ZonePainter old) => old.zone != zone;
}
