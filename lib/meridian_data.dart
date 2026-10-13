import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'points_data.dart';

// Общее состояние (долгота и полдень, полученные на экране хроно)
class AppSession {
  static double lon = 0.0;
  static double noonMinutes = 720.0;
}

class SolarTime {
  /// Истинный солнечный полдень в минутах от местной полуночи
  static double noonMinutes(DateTime now, double lon) {
    final dayOfYear = int.parse(DateFormat('D').format(now));
    final b = (360 / 365) * (dayOfYear - 81) * (pi / 180);
    final eq = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);
    final tz = now.timeZoneOffset.inMinutes / 60.0;
    return 720 + (tz * 15 - lon) * 4 - eq;
  }

  static String fmt(int t) =>
      '${(t ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}';

  static List<int> windowBounds(MeridianInfo m, double noonMinutes) {
    final start = (((noonMinutes - 720 + m.offset! * 60).round() % 1440) + 1440) % 1440;
    final end = (start + 120) % 1440;
    return [start, end];
  }

  static bool isActive(MeridianInfo m, double noonMinutes, DateTime now) {
    if (!m.inCycle) return false;
    final w = windowBounds(m, noonMinutes);
    final cur = now.hour * 60 + now.minute;
    return w[0] < w[1] ? (cur >= w[0] && cur < w[1]) : (cur >= w[0] || cur < w[1]);
  }

  static String windowText(MeridianInfo m, double noonMinutes) {
    if (!m.inCycle) return 'вне цикла Цзы-У';
    final w = windowBounds(m, noonMinutes);
    return '${fmt(w[0])} – ${fmt(w[1])}';
  }
}

class MeridianInfo {
  final String code;
  final String name;
  final String fullName;
  final String cn;
  final int? offset; // час от солнечной полуночи; null — вне цикла Цзы-У
  final String element;
  final Color color;
  const MeridianInfo({
    required this.code,
    required this.name,
    required this.fullName,
    required this.cn,
    required this.offset,
    required this.element,
    required this.color,
  });
  bool get inCycle => offset != null;
  List<AcuPoint> get points => PointsData.byMeridian[code] ?? const [];
}

const List<MeridianInfo> kMeridians = [
  MeridianInfo(code: 'LU', name: 'Лёгкие', fullName: 'Шоу тайинь — меридиан лёгких', cn: '手太阴肺经', offset: 3, element: 'Металл', color: Color(0xFFCFD8DC)),
  MeridianInfo(code: 'LI', name: 'Толстая кишка', fullName: 'Шоу янмин — меридиан толстой кишки', cn: '手阳明大肠经', offset: 5, element: 'Металл', color: Color(0xFFCFD8DC)),
  MeridianInfo(code: 'ST', name: 'Желудок', fullName: 'Цзу янмин — меридиан желудка', cn: '足阳明胃经', offset: 7, element: 'Земля', color: Color(0xFFD9A441)),
  MeridianInfo(code: 'SP', name: 'Селезёнка', fullName: 'Цзу тайинь — меридиан селезёнки', cn: '足太阴脾经', offset: 9, element: 'Земля', color: Color(0xFFD9A441)),
  MeridianInfo(code: 'HT', name: 'Сердце', fullName: 'Шоу шаоинь — меридиан сердца', cn: '手少阴心经', offset: 11, element: 'Огонь', color: Color(0xFFE74C3C)),
  MeridianInfo(code: 'SI', name: 'Тонкая кишка', fullName: 'Шоу тайян — меридиан тонкой кишки', cn: '手太阳小肠经', offset: 13, element: 'Огонь', color: Color(0xFFE74C3C)),
  MeridianInfo(code: 'BL', name: 'Мочевой пузырь', fullName: 'Цзу тайян — меридиан мочевого пузыря', cn: '足太阳膀胱经', offset: 15, element: 'Вода', color: Color(0xFF5DADE2)),
  MeridianInfo(code: 'KI', name: 'Почки', fullName: 'Цзу шаоинь — меридиан почек', cn: '足少阴肾经', offset: 17, element: 'Вода', color: Color(0xFF5DADE2)),
  MeridianInfo(code: 'PC', name: 'Перикард', fullName: 'Шоу цзюэинь — меридиан перикарда', cn: '手厥阴心包经', offset: 19, element: 'Огонь', color: Color(0xFFEC7063)),
  MeridianInfo(code: 'TE', name: 'Три обогревателя', fullName: 'Шоу шаоян — меридиан трёх обогревателей', cn: '手少阳三焦经', offset: 21, element: 'Огонь', color: Color(0xFFEC7063)),
  MeridianInfo(code: 'GB', name: 'Желчный пузырь', fullName: 'Цзу шаоян — меридиан желчного пузыря', cn: '足少阳胆经', offset: 23, element: 'Дерево', color: Color(0xFF52BE80)),
  MeridianInfo(code: 'LR', name: 'Печень', fullName: 'Цзу цзюэинь — меридиан печени', cn: '足厥阴肝经', offset: 25, element: 'Дерево', color: Color(0xFF52BE80)),
  MeridianInfo(code: 'GV', name: 'Ду-май', fullName: 'Заднесрединный меридиан', cn: '督脉', offset: null, element: '—', color: Color(0xFFB39DDB)),
  MeridianInfo(code: 'CV', name: 'Жэнь-май', fullName: 'Переднесрединный меридиан', cn: '任脉', offset: null, element: '—', color: Color(0xFF48C9B0)),
  MeridianInfo(code: 'EX', name: 'Внемеридианные', fullName: 'Вне-точки (экстра-меридианные)', cn: '经外奇穴', offset: null, element: '—', color: Color(0xFFE59866)),
];

/// Определяет меридиан по коду точки (например LU7 -> LU, EX-HN3 -> EX)
MeridianInfo meridianOfCode(String code) {
  final m = RegExp(r'^([A-Z]+)').firstMatch(code)?.group(1) ?? '';
  for (final k in kMeridians) {
    if (k.code == m) return k;
  }
  return kMeridians.first;
}
