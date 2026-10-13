import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Трёхъязычная строка: рус / eng / 中文
class T3 {
  final String ru;
  final String en;
  final String zh;
  const T3(this.ru, this.en, this.zh);
}

/// Алиас для краткости: T(...) == T3(...)
typedef T = T3;

enum AppLang { ru, en, zh }

class Lang {
  static AppLang current = AppLang.ru;
  static bool asked = false;
  static final ValueNotifier<AppLang> notifier = ValueNotifier(AppLang.ru);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final i = p.getInt('lang');
    if (i != null && i >= 0 && i < AppLang.values.length) {
      current = AppLang.values[i];
      asked = true;
      notifier.value = current;
    }
  }

  static Future<void> set(AppLang l) async {
    current = l;
    asked = true;
    notifier.value = l;
    final p = await SharedPreferences.getInstance();
    await p.setInt('lang', l.index);
  }

  static String get code => switch (current) {
        AppLang.ru => 'ru',
        AppLang.en => 'en',
        AppLang.zh => 'zh',
      };
}

String tr(T3 t) => switch (Lang.current) {
      AppLang.ru => t.ru,
      AppLang.en => t.en,
      AppLang.zh => t.zh,
    };

// ── Общие строки интерфейса ──
const tLangTitle = T3('Выберите язык', 'Choose language', '选择语言');
const tChrono = T3('Хроно', 'Chrono', '时辰');
const tAtlas = T3('Атлас', 'Body map', '身体图');
const tPoints = T3('Точки', 'Points', '穴位');
const tClinic = T3('Клиника', 'Clinic', '临床');
const tDiary = T3('Дневник', 'Diary', '日志');
const tTimer = T3('Таймер', 'Timer', '计时');
const tBody = T3('Тело', 'Body', '身体');
const tZones = T3('Зоны', 'Zones', '分区');
const tSync = T3('Синхронизировать с GPS спутниками', 'Sync with GPS satellites', 'GPS卫星同步');
const tManual = T3('Ввести координаты вручную', 'Enter coordinates manually', '手动输入坐标');
const tLocation = T3('Локация:', 'Location:', '位置：');
const tNoon = T3('Истинный Солнечный Полдень:', 'True Solar Noon:', '真太阳正午：');
const tDayEnergy = T3('Управитель текущего дня:', 'Ruler of the day:', '当日日柱：');
const tHourBranch = T3('Часовой знак (солнечный):', 'Hour branch (solar):', '时辰地支：');
const tHourPillar = T3('Часовой столп:', 'Hour pillar:', '时柱：');
const tTide = T3('Суточный прилив Ци (Цзы-У):', 'Daily Qi tide (Zi-Wu):', '子午流注：');
const tPeakNow = T3('ПИК ЦИ СЕЙЧАС', 'QI PEAK NOW', '气血正旺');
const tUntilEnd = T3('до конца окна', 'until window ends', '距本时辰结束');
const tPeak = T3('ПИК ЦИ', 'QI PEAK', '气血旺');
const tPointsCount = T3('точек', 'points', '穴');
const tElement = T3('стихия', 'element', '五行');
const tSearchAll = T3('Поиск точки: код (LU7) или название (Ле-цюэ)',
    'Search point: code (LU7) or name (Lieque)', '搜索穴位：代码(LU7)或名称(列缺)');
const tMeridians = T3('меридианов', 'meridians', '经脉');
const tMeridian = T3('Меридиан:', 'Meridian:', '经脉：');
const tCanonName = T3('Каноническое имя:', 'Canonical name:', '经名：');
const tHanzi = T3('Иероглифы канала:', 'Channel hanzi:', '经脉汉字：');
const tRules = T3(
    'Правило Цзы-У Лю-Чжу: время указано по истинному солнечному времени.\nНажмите на меридиан, чтобы открыть его точки.',
    'Zi-Wu Liu-Zhu rule: times are given in true solar time.\nTap a meridian to open its points.',
    '子午流注：时间为真太阳时。\n点击经脉查看穴位。');
const tTopo = T3('Топография (где искать):', 'Location (how to find):', '定位：');
const tInd = T3('Показания / действие:', 'Indications / actions:', '主治：');
const tNeedle = T3('Игла и глубина:', 'Needling & depth:', '针刺与深度：');
const tMoxa = T3('Мокса (прижигание):', 'Moxibustion:', '艾灸：');
const tWindow = T3('Окно Цзы-У:', 'Zi-Wu window:', '子午流注时辰：');
const tSafety = T3(
    '⚠️ Приложение носит информационный характер и не заменяет врача. '
    'При беременности запрещены SP6, LI4, BL32, точки живота. '
    'Точки спины и груди колоть только косо и неглубоко (риск пневмоторакса). '
    'GB20, GB21, GV16 — только неглубоко. Стерильность игл обязательна.',
    '⚠️ This app is informational and does not replace a physician. '
    'SP6, LI4, BL32 and abdominal points are contraindicated in pregnancy. '
    'Needle back/chest points obliquely and superficially (pneumothorax risk). '
    'GB20, GB21, GV16 — superficial only. Sterile needles are mandatory.',
    '⚠️本应用仅供信息参考，不能替代医生。孕妇禁用三阴交、合谷、次髎及腹部穴。'
    '背胸部穴位只可斜刺浅刺（防气胸）。风池、肩井、风府只可浅刺。须使用无菌针具。');
const tNewSession = T3('Новый сеанс', 'New session', '新记录');
const tDate = T3('Дата', 'Date', '日期');
const tPointsUsed = T3('Точки (коды через запятую)', 'Points (codes, comma-separated)', '穴位（逗号分隔代码）');
const tFeeling = T3('Самочувствие', 'Well-being', '自我感觉');
const tNotes = T3('Заметки', 'Notes', '备注');
const tSave = T3('Сохранить', 'Save', '保存');
const tDelete = T3('Удалить?', 'Delete?', '删除？');
const tEmpty = T3('Пока нет записей', 'No records yet', '暂无记录');
const tSessions = T3('сеансов', 'sessions', '次治疗');
const tDiseases = T3('Каталог болезней (синдромы ТКМ)', 'Disease catalog (TCM patterns)', '病症目录');
const tFormulas = T3('Лекарства ТКМ (классические формулы)', 'TCM remedies (classic formulas)', '中药方剂');
const tSyndrome = T3('Синдром:', 'Pattern:', '证型：');
const tManifest = T3('Проявления:', 'Manifestations:', '表现：');
const tRecipe = T3('Рецепт точек:', 'Point prescription:', '穴位处方：');
const tComposition = T3('Состав:', 'Composition:', '组成：');
const tAction = T3('Действие:', 'Action:', '功效：');
const tFormulaRef = T3('Рекомендуемая формула ТКМ:', 'Recommended TCM formula:', '推荐方剂：');
const tNothingFound = T3('Ничего не найдено', 'Nothing found', '未找到');
const tFront = T3('Спереди', 'Front', '正面');
const tBack = T3('Сзади', 'Back', '背面');
const tSeeDetails = T3('Подробности — во вкладке «Точки»', 'Details — see the Points tab', '详情见「穴位」页');
const tExportPdf = T3('Экспорт PDF', 'Export PDF', '导出PDF');
const tStart = T3('Старт', 'Start', '开始');
const tPause = T3('Пауза', 'Pause', '暂停');
const tReset = T3('Сброс', 'Reset', '重置');
const tTimerDone = T3('Сеанс завершён!', 'Session complete!', '治疗完成！');
const tSavedDiary = T3('Сохранено в дневник', 'Saved to diary', '已存入日志');
const tMinutes = T3('минуты', 'minutes', '分钟');
const tHeadZ = T3('Голова и шея', 'Head & neck', '头颈部');
const tTorsoZ = T3('Грудь и живот', 'Chest & abdomen', '胸腹部');
const tBackZ = T3('Спина и поясница', 'Back & lumbar', '背腰部');
const tArmZ = T3('Рука и кисть', 'Arm & hand', '上肢部');
const tLegZ = T3('Нога и стопа', 'Leg & foot', '下肢部');
const tAdvice = T3('Совет по часу Цзы-У', 'Zi-Wu hour advice', '时辰养生提示');
const tClose = T3('Закрыть', 'Close', '关闭');
const tCancel = T3('Отмена', 'Cancel', '取消');
const tApply = T3('Применить', 'Apply', '确定');
const tLat = T3('Широта', 'Latitude', '纬度');
const tLon = T3('Долгота', 'Longitude', '经度');
const tGpsDenied = T3('Доступ к геолокации запрещён', 'Location permission denied', '定位权限被拒绝');
const tAll = T3('Все', 'All', '全部');
const tSymmetry = T3(
    'Симметричные точки есть с обеих сторон тела. Подробности — во вкладке «Точки».',
    'Symmetric points exist on both sides. Details — see the Points tab.',
    '对称穴位于身体两侧。详情见「穴位」页。');
