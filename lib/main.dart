import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'l10n.dart';
import 'meridian_data.dart';
import 'points_screen.dart';
import 'atlas_hub.dart';
import 'clinic_screen.dart';
import 'timer_screen.dart';
import 'diary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChronoApp());
}

class ChronoApp extends StatelessWidget {
  const ChronoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Lang.notifier,
      builder: (context, _) => MaterialApp(
        title: 'Хронопунктура ТКМ',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37), // Золотой акцент
            secondary: Color(0xFF27AE60), // Зелёный пик Ци
          ),
        ),
        locale: Locale(Lang.code),
        supportedLocales: const [Locale('ru'), Locale('en'), Locale('zh')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({Key? key}) : super(key: key);
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    Lang.load().then((_) {
      if (!Lang.asked && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _askLanguage());
      }
      setState(() {});
    });
  }

  void _askLanguage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(tr(tLangTitle)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final l in AppLang.values)
            ListTile(
              title: Text(switch (l) {
                AppLang.ru => 'Русский',
                AppLang.en => 'English',
                AppLang.zh => '中文',
              }),
              leading: Text(
                  switch (l) { AppLang.ru => '🇷🇺', AppLang.en => '🇬🇧', AppLang.zh => '🇨🇳' },
                  style: const TextStyle(fontSize: 22)),
              onTap: () async {
                await Lang.set(l);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 6, child: _HomeScaffold(onPickLang: _askLanguage));
  }
}

class _HomeScaffold extends StatelessWidget {
  final VoidCallback onPickLang;
  const _HomeScaffold({Key? key, required this.onPickLang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tc = DefaultTabController.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Акупунктура • Хроно',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.language, color: Colors.white70),
              onPressed: onPickLang),
        ],
      ),
      body: IndexedStack(index: tc.index, children: const [
        ChronoScreen(),
        AtlasHub(),
        AllPointsSearchScreen(),
        ClinicScreen(),
        SessionTimerScreen(),
        DiaryScreen(),
      ]),
      bottomNavigationBar: AnimatedBuilder(
        animation: tc,
        builder: (context, _) => BottomNavigationBar(
          currentIndex: tc.index,
          onTap: tc.animateTo,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.schedule), label: tr(tChrono)),
            BottomNavigationBarItem(icon: const Icon(Icons.accessibility_new), label: tr(tAtlas)),
            BottomNavigationBarItem(icon: const Icon(Icons.list_alt), label: tr(tPoints)),
            BottomNavigationBarItem(icon: const Icon(Icons.medical_services), label: tr(tClinic)),
            BottomNavigationBarItem(icon: const Icon(Icons.timer), label: tr(tTimer)),
            BottomNavigationBarItem(icon: const Icon(Icons.menu_book), label: tr(tDiary)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════ Хроно-калькулятор ══════════════════

class ChronoScreen extends StatefulWidget {
  const ChronoScreen({Key? key}) : super(key: key);
  @override
  State<ChronoScreen> createState() => _ChronoScreenState();
}

class _ChronoScreenState extends State<ChronoScreen> {
  double _lat = 0.0;
  double _lon = 0.0;
  bool _gpsSet = false;
  String _solarNoonStr = '--:--';
  double _noonMinutes = 720.0;
  List<Map<String, dynamic>> _calculatedSchedule = [];
  Timer? _clock;

  static const List<String> _stems = ['Цзя', 'И', 'Бин', 'Дин', 'У', 'Цзи', 'Гэн', 'Синь', 'Жэнь', 'Гуй'];
  static const List<String> _stemEl = [
    'Дерево Ян', 'Дерево Инь', 'Огонь Ян', 'Огонь Инь', 'Земля Ян',
    'Земля Инь', 'Металл Ян', 'Металл Инь', 'Вода Ян', 'Вода Инь',
  ];
  static const List<String> _branches = [
    'Цзы', 'Чоу', 'Инь', 'Мао', 'Чэнь', 'Сы', 'У', 'Вэй', 'Шэнь', 'Ю', 'Сюй', 'Хай',
  ];
  static const List<String> _branchAnimals = [
    'Крыса', 'Бык', 'Тигр', 'Кролик', 'Дракон', 'Змея',
    'Лошадь', 'Овца', 'Обезьяна', 'Петух', 'Собака', 'Свинья',
  ];

  static const List<T3> _hourAdvice = [
    T3('Час Цзы (23–01), желчный пузырь: ложитесь спать до полуночи — желчь обновляется.',
        'Zi hour (23–01), Gallbladder: sleep before midnight; bile renews.', '子时（23–01）胆经当令：应在午夜前入睡。'),
    T3('Час Чоу (01–03), печень: глубокий сон очищает кровь. Поздний ужин и спиртное мешают.',
        'Chou hour (01–03), Liver: deep sleep detoxifies blood; avoid late meals and alcohol.', '丑时（01–03）肝经当令：熟睡养血，忌熬夜饮酒。'),
    T3('Час Инь (03–05), лёгкие: время самого глубокого сна — дыхание распределяет ци.',
        'Yin hour (03–05), Lungs: deepest sleep; breathing distributes qi.', '寅时（03–05）肺经当令：宜深睡，肺布输气血。'),
    T3('Час Мао (05–07), толстая кишка: пробуждение и освобождение кишечника; стакан тёплой воды.',
        'Mao hour (05–07), Large Intestine: wake, move bowels; a glass of warm water.', '卯时（05–07）大肠经当令：晨起排便，饮温水。'),
    T3('Час Чэнь (07–09), желудок: завтракайте плотно и тепло — энергия на весь день.',
        'Chen hour (07–09), Stomach: a warm solid breakfast fuels the day.', '辰时（07–09）胃经当令：宜吃温热早餐。'),
    T3('Час Сы (09–11), селезёнка: пик умственной работы и усвоения.',
        'Si hour (09–11), Spleen: peak mental focus and digestion.', '巳时（09–11）脾经当令：头脑最清醒，宜工作。'),
    T3('Час У (11–13), сердце: короткий дневной отдых (20–30 мин) укрепляет сердце.',
        'Wu hour (11–13), Heart: a 20–30 min midday nap strengthens the heart.', '午时（11–13）心经当令：小憩20–30分钟养心。'),
    T3('Час Вэй (13–15), тонкая кишка: обед лёгкий — идёт сортировка и усвоение.',
        'Wei hour (13–15), Small Intestine: keep lunch light; absorption under way.', '未时（13–15）小肠经当令：午餐宜清淡。'),
    T3('Час Шэнь (15–17), мочевой пузырь: пейте воду, двигайтесь — вывод излишков.',
        'Shen hour (15–17), Bladder: drink water, keep moving.', '申时（15–17）膀胱经当令：宜多饮水、多运动。'),
    T3('Час Ю (17–19), почки: лёгкий тёплый ужин; берегите поясницу, тёплые ноги.',
        'You hour (17–19), Kidneys: light warm dinner; keep back and feet warm.', '酉时（17–19）肾经当令：晚餐清淡，护腰暖足。'),
    T3('Час Сюй (19–21), перикард: спокойная прогулка; не переедайте и не ссорьтесь.',
        'Xu hour (19–21), Pericardium: calm stroll; no heavy food or quarrels.', '戌时（19–21）心包经当令：宜散步放松，忌暴食。'),
    T3('Час Хай (21–23), три обогревателя: готовьтесь ко сну — тёплая ванна, без экранов.',
        'Hai hour (21–23), Triple Burner: prepare for sleep — warm bath, no screens.', '亥时（21–23）三焦经当令：温水泡脚，准备入睡。'),
  ];

  @override
  void initState() {
    super.initState();
    _calculateSolarGrid();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _calculateSolarGrid());
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  // Расчёт Уравнения Времени и солнечного полдня
  void _calculateSolarGrid() {
    final now = DateTime.now();
    _noonMinutes = SolarTime.noonMinutes(now, _lon);
    final h = (_noonMinutes ~/ 60) % 24;
    final m = (_noonMinutes.round() % 60);
    _solarNoonStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    _buildMeridianTimeline();
    if (mounted) setState(() {});
  }

  void _buildMeridianTimeline() {
    final now = DateTime.now();
    final cur = now.hour * 60 + now.minute;
    final tempGrid = <Map<String, dynamic>>[];
    for (final m in kMeridians) {
      if (!m.inCycle) continue;
      final w = SolarTime.windowBounds(m, _noonMinutes);
      final active = SolarTime.isActive(m, _noonMinutes, now);
      final relStart = ((w[0] - cur) % 1440 + 1440) % 1440;
      tempGrid.add({
        'meridian': m,
        'time': SolarTime.windowText(m, _noonMinutes),
        'start': w[0],
        'active': active,
        'relStart': relStart,
      });
    }
    tempGrid.sort((a, b) => (a['relStart'] as int).compareTo(b['relStart'] as int));
    _calculatedSchedule = tempGrid;
  }

  Future<void> _requestGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr(const T3('Включите GPS в настройках телефона',
                'Enable GPS in phone settings', '请在手机设置中开启GPS')))));
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(tr(tGpsDenied))));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr(tGpsDenied))));
        await Geolocator.openAppSettings();
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
        _gpsSet = true;
      });
      AppSession.lon = _lon;
      _calculateSolarGrid();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr(const T3('Ошибка получения геопозиции',
              'Failed to get location', '获取定位失败')))));
    }
  }

  Future<void> _manualCoords() async {
    final latCtrl = TextEditingController(text: _lat == 0 ? '' : _lat.toStringAsFixed(4));
    final lonCtrl = TextEditingController(text: _lon == 0 ? '' : _lon.toStringAsFixed(4));
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(tr(tManual)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: latCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: '${tr(tLat)} (55.75)')),
          TextField(
              controller: lonCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: '${tr(tLon)} (37.61)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr(tCancel))),
          FilledButton(
              onPressed: () {
                final la = double.tryParse(latCtrl.text.replaceAll(',', '.')) ?? 0;
                final lo = double.tryParse(lonCtrl.text.replaceAll(',', '.')) ?? 0;
                setState(() {
                  _lat = la;
                  _lon = lo;
                  _gpsSet = true;
                });
                AppSession.lon = _lon;
                _calculateSolarGrid();
                Navigator.pop(ctx);
              },
              child: Text(tr(tApply))),
        ],
      ),
    );
  }

  // ── Бацзы: столп дня и часовой столп (солнечное время) ──
  int get _dayStemIdx {
    final now = DateTime.now();
    final diff = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(1900, 2, 20))
        .inDays; // 1900-02-20 — день Цзя-Цзы
    return ((diff % 10) + 10) % 10;
  }

  int get _dayBranchIdx {
    final now = DateTime.now();
    final diff = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(1900, 2, 20))
        .inDays;
    return ((diff % 12) + 12) % 12;
  }

  int get _solarMinutes {
    final now = DateTime.now();
    final lm = now.hour * 60 + now.minute;
    return ((lm + (_noonMinutes - 720).round()) % 1440 + 1440) % 1440;
  }

  int get _hourBranchIdx => (((_solarMinutes + 60) ~/ 120) % 12 + 12) % 12;

  int get _hourStemIdx => (((_dayStemIdx % 5) * 2 + _hourBranchIdx) % 10 + 10) % 10;

  int get _adviceIndex => _hourBranchIdx;

  Widget _adviceCard() => Card(
        color: const Color(0xFF2A2A2A),
        child: ListTile(
          leading: const Icon(Icons.bedtime, color: Color(0xFFB39DDB)),
          title: Text(tr(tAdvice),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(tr(_hourAdvice[_adviceIndex]),
              style: const TextStyle(fontSize: 12.5, height: 1.4)),
        ),
      );

  Widget _peakCard() {
    final active = _calculatedSchedule.where((e) => e['active'] == true).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    final item = active.first;
    final m = item['meridian'] as MeridianInfo;
    final now = DateTime.now();
    final cur = now.hour * 60 + now.minute;
    final w = SolarTime.windowBounds(m, _noonMinutes);
    final remain = ((w[1] - cur) % 1440 + 1440) % 1440;
    return Card(
      color: const Color(0xFF1F3325),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF27AE60), width: 1.4)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: m.color.withOpacity(0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: m.color)),
          child: Text(m.code,
              style: TextStyle(
                  color: m.color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        title: Text('${tr(tPeakNow)} — ${m.name}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item['time']}'),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(tr(tUntilEnd), style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text('${remain ~/ 60}h ${remain % 60}m',
              style: const TextStyle(
                  color: Color(0xFF27AE60), fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _tile(Map<String, dynamic> item) {
    final m = item['meridian'] as MeridianInfo;
    final bool act = item['active'] == true;
    return Card(
      color: act ? const Color(0xFF1F3325) : Theme.of(context).cardColor,
      elevation: act ? 6 : 1,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: act ? const Color(0xFF27AE60) : Colors.white10,
              width: act ? 1.4 : 1)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PointsListScreen(meridian: m))),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: m.color.withOpacity(act ? 0.22 : 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: m.color.withOpacity(act ? 0.9 : 0.3))),
          child: Text(m.code,
              style: TextStyle(
                  color: m.color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        title: Text(m.name,
            style: TextStyle(
                fontWeight: act ? FontWeight.bold : FontWeight.w500,
                color: act ? Colors.white : Colors.white70)),
        subtitle: Text(
            '${m.cn}\n${item['time']} • ${m.element} • ${m.points.length} ${tr(tPointsCount)}',
            style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: act ? Colors.white60 : Colors.grey)),
        isThreeLine: true,
        trailing: act
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(tr(tPeak),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)))
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.location_on),
                  label: Text(tr(tSync),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _requestGPS,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  icon: const Icon(Icons.edit_location_alt,
                      color: Color(0xFFD4AF37)),
                  label: Text(tr(tManual),
                      style: const TextStyle(color: Color(0xFFD4AF37))),
                  onPressed: _manualCoords,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr(tLocation),
                        style: const TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(
                          _gpsSet
                              ? '${tr(tLat)}: ${_lat.toStringAsFixed(3)}, ${tr(tLon)}: ${_lon.toStringAsFixed(3)}'
                              : tr(const T3('Координаты не определены',
                                  'Coordinates not set', '坐标未确定')),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const Divider(height: 25, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr(tNoon),
                        style: const TextStyle(
                            fontSize: 15, color: Colors.amber)),
                    Text(_solarNoonStr,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber)),
                  ],
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Text(tr(tDayEnergy),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF2A2A2A),
            child: ListTile(
              leading: const Icon(Icons.blur_on, color: Colors.redAccent),
              title: Text(
                  '${_stems[_dayStemIdx]}-${_branches[_dayBranchIdx]} (${_stemEl[_dayStemIdx]} / ${_branchAnimals[_dayBranchIdx]})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(
                  '${tr(tHourPillar)} ${_stems[_hourStemIdx]}-${_branches[_hourBranchIdx]} • ${tr(tHourBranch)} ${_branchAnimals[_hourBranchIdx]}',
                  style: const TextStyle(fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 12),
          _adviceCard(),
          const SizedBox(height: 12),
          _peakCard(),
          const SizedBox(height: 20),
          Text(tr(tTide),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 10),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _calculatedSchedule.length,
              itemBuilder: (context, index) => _tile(_calculatedSchedule[index])),
          const SizedBox(height: 14),
          Text(tr(tRules),
              style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.45)),
          const SizedBox(height: 8),
          Text(tr(tSafety),
              style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
