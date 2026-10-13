import 'package:flutter/material.dart';
import 'l10n.dart';
import 'meridian_data.dart';
import 'points_data.dart';
import 'point_details.dart';

/// Глобальный поиск по всем 364 точкам
class AllPointsSearchScreen extends StatefulWidget {
  const AllPointsSearchScreen({Key? key}) : super(key: key);
  @override
  State<AllPointsSearchScreen> createState() => _AllPointsSearchScreenState();
}

class _AllPointsSearchScreenState extends State<AllPointsSearchScreen> {
  String _query = '';

  List<(AcuPoint, MeridianInfo)> get _results {
    final q = _query.trim().toLowerCase();
    final out = <(AcuPoint, MeridianInfo)>[];
    for (final m in kMeridians) {
      for (final p in m.points) {
        if (q.isEmpty ||
            p.code.toLowerCase().contains(q) ||
            p.name.toLowerCase().contains(q) ||
            p.cn.contains(q) ||
            m.name.toLowerCase().contains(q)) {
          out.add((p, m));
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final res = _results;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
              hintText: tr(tSearchAll),
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              filled: true, fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${res.length} ${tr(tPointsCount)} • ${kMeridians.length} ${tr(tMeridians)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ),
        Expanded(
          child: res.isEmpty
              ? Center(child: Text(tr(tNothingFound), style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: res.length,
                  itemBuilder: (context, i) {
                    final (p, m) = res[i];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                          side: BorderSide(color: m.color.withOpacity(0.25))),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        onTap: () => showPointSheet(context, m, p),
                        leading: _codeBadge(m, p.code),
                        title: Text(p.name, style: const TextStyle(fontSize: 15)),
                        subtitle: Text('${p.cn} • ${m.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                    );
                  }),
        ),
      ]),
    );
  }
}

/// Список точек одного меридиана
class PointsListScreen extends StatelessWidget {
  final MeridianInfo meridian;
  const PointsListScreen({Key? key, required this.meridian}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('${meridian.name} • ${meridian.cn}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.all(12),
          child: Text(
            '${meridian.fullName}\n${tr(tWindow)} ${SolarTime.windowText(meridian, AppSession.noonMinutes)} • ${tr(tElement)}: ${meridian.element} • ${meridian.points.length} ${tr(tPointsCount)}',
            style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.grey)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            itemCount: meridian.points.length,
            itemBuilder: (context, i) {
              final p = meridian.points[i];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: BorderSide(color: meridian.color.withOpacity(0.25))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  onTap: () => showPointSheet(context, meridian, p),
                  leading: _codeBadge(meridian, p.code),
                  title: Text(p.name, style: const TextStyle(fontSize: 15)),
                  subtitle: Text(p.cn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

Widget _codeBadge(MeridianInfo m, String code) => Container(
      width: 62,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: m.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: m.color.withOpacity(0.45)),
      ),
      child: Text(code,
          style: TextStyle(color: m.color, fontWeight: FontWeight.bold, fontSize: 11)),
    );

/// Карточка точки: топография, показания, игла, мокса
void showPointSheet(BuildContext context, MeridianInfo m, AcuPoint p) {
  final d = PointDetails.find(p.code);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: m.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: m.color),
              ),
              child: Text(p.code,
                  style: TextStyle(color: m.color, fontWeight: FontWeight.bold, fontSize: 17)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                Text(p.cn, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ]),
            ),
          ]),
          const Divider(height: 26),
          _sheetRow(tr(tMeridian), '${m.name} (${m.code}) — ${m.cn}'),
          _sheetRow(tr(tCanonName), m.fullName),
          _sheetRow(tr(tElement), m.element),
          _sheetRow(tr(tWindow), SolarTime.windowText(m, AppSession.noonMinutes)),
          if (d != null) ...[
            const Divider(height: 24),
            _section(tr(tTopo), d.loc),
            _section(tr(tInd), d.ind),
            _section(tr(tNeedle), d.need),
            if (d.moxa != null) _section(tr(tMoxa), d.moxa!, Colors.orange),
          ],
          const SizedBox(height: 14),
          Text(tr(tSafety), style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text(tr(tClose))),
          ),
        ],
      ),
    ),
  );
}

Widget _section(String title, T3 body, [Color color = const Color(0xFFD4AF37)]) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(tr(body), style: const TextStyle(fontSize: 14, height: 1.4)),
      ]),
    );

Widget _sheetRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, height: 1.3))),
      ]),
    );
