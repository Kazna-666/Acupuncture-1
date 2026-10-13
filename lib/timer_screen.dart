import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemSound, SystemSoundType;
import 'package:vibration/vibration.dart';
import 'l10n.dart';
import 'diary_screen.dart';

/// Таймер сеанса: обратный отсчёт, вибрация, звук, авто-сохранение в дневник
class SessionTimerScreen extends StatefulWidget {
  const SessionTimerScreen({Key? key}) : super(key: key);
  @override
  State<SessionTimerScreen> createState() => _SessionTimerScreenState();
}

class _SessionTimerScreenState extends State<SessionTimerScreen> {
  int _minutes = 20;
  int _left = 20 * 60;
  bool _running = false;
  Timer? _t;
  final TextEditingController _pointsCtrl = TextEditingController();

  @override
  void dispose() {
    _t?.cancel();
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _setMinutes(int m) {
    _t?.cancel();
    setState(() {
      _minutes = m;
      _left = m * 60;
      _running = false;
    });
  }

  void _toggle() {
    if (_running) {
      _t?.cancel();
      setState(() => _running = false);
    } else {
      _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      setState(() => _running = true);
    }
  }

  void _tick() {
    if (_left <= 0) {
      _finish();
      return;
    }
    setState(() => _left--);
    if (_left == 60) {
      _buzz([0, 200, 150, 200]);
      _beep();
    }
  }

  void _finish() {
    _t?.cancel();
    _buzz([0, 500, 200, 500, 200, 500]);
    _beep();
    final pts = _pointsCtrl.text.trim();
    if (pts.isNotEmpty) {
      DiaryStore.add(SessionRecord(
          date: DateTime.now(), points: pts, feeling: 3, notes: ''));
    }
    setState(() {
      _running = false;
      _left = _minutes * 60;
    });
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(tr(tTimerDone)),
              content: Text(pts.isEmpty ? '' : tr(tSavedDiary)),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(ctx), child: Text(tr(tClose))),
              ],
            ));
  }

  void _reset() {
    _t?.cancel();
    setState(() {
      _running = false;
      _left = _minutes * 60;
    });
  }

  void _buzz(List<int> pattern) {
    Vibration.hasVibrator().then((ok) {
      if (ok == true) {
        try {
          Vibration.vibrate(pattern: pattern);
        } catch (_) {}
      }
    }).catchError((_) {});
  }

  void _beep() {
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  String get _mmss =>
      '${(_left ~/ 60).toString().padLeft(2, '0')}:${(_left % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final total = _minutes * 60;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                    value: total == 0 ? 0 : _left / total,
                    strokeWidth: 10,
                    backgroundColor: Colors.white10,
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF27AE60)))),
            Column(children: [
              Text(_mmss,
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('$_minutes ${tr(tMinutes)}',
                  style: const TextStyle(color: Colors.grey)),
            ]),
          ]),
          const SizedBox(height: 20),
          Wrap(spacing: 8, children: [10, 15, 20, 30, 45]
              .map((m) => ChoiceChip(
                  label: Text('$m'),
                  selected: _minutes == m,
                  selectedColor: const Color(0xFFD4AF37),
                  labelStyle:
                      TextStyle(color: _minutes == m ? Colors.black : Colors.white),
                  onSelected: (_) => _setMinutes(m)))
              .toList()),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _running ? Colors.orange : const Color(0xFF27AE60),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14)),
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? tr(tPause) : tr(tStart)),
                onPressed: _toggle),
            const SizedBox(width: 12),
            OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: Text(tr(tReset)),
                onPressed: _reset),
          ]),
          const SizedBox(height: 20),
          TextField(
              controller: _pointsCtrl,
              decoration: InputDecoration(
                labelText: tr(const T3(
                    'Точки сеанса (необязательно)',
                    'Session points (optional)',
                    '治疗穴位（可选）')),
                hintText: 'ST36, PC6, LR3',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              )),
          const SizedBox(height: 16),
          Text(
              tr(const T3(
                  'По окончании запись автоматически попадёт в дневник.',
                  'On completion the record is saved to the diary automatically.',
                  '结束后自动存入日志。')),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ),
    );
  }
}
