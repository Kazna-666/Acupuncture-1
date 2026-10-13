import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n.dart';
import 'pdf_export.dart';

class SessionRecord {
  final DateTime date;
  final String points;
  final int feeling; // 1..5
  final String notes;
  SessionRecord({required this.date, required this.points, required this.feeling, required this.notes});

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'points': points,
        'feeling': feeling,
        'notes': notes,
      };

  static SessionRecord fromMap(Map<String, dynamic> m) => SessionRecord(
        date: DateTime.parse(m['date'] as String),
        points: m['points'] as String,
        feeling: (m['feeling'] as num?)?.toInt() ?? 3,
        notes: m['notes'] as String,
      );
}

/// Единое хранилище дневника (используется и таймером)
class DiaryStore {
  static List<SessionRecord> items = [];
  static final ValueNotifier<int> version = ValueNotifier(0);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('sessions');
    if (raw != null && raw.isNotEmpty) {
      items = (jsonDecode(raw) as List)
          .map((e) => SessionRecord.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    version.value++;
  }

  static Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('sessions', jsonEncode(items.map((e) => e.toMap()).toList()));
  }

  static Future<void> add(SessionRecord r) async {
    items.insert(0, r);
    await _save();
    version.value++;
  }

  static Future<void> removeAt(int i) async {
    items.removeAt(i);
    await _save();
    version.value++;
  }
}

/// Экран дневника сеансов
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  void initState() {
    super.initState();
    DiaryStore.load();
  }

  Future<void> _add() async {
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final pointsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    int feeling = 3;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(tNewSession), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(controller: dateCtrl, decoration: _dec(tr(tDate)), keyboardType: TextInputType.datetime),
            const SizedBox(height: 10),
            TextField(controller: pointsCtrl, decoration: _dec('${tr(tPointsUsed)}: ST36, PC6'), keyboardType: TextInputType.text),
            const SizedBox(height: 10),
            Text(tr(tFeeling), style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Row(children: [
              for (int i = 1; i <= 5; i++)
                IconButton(
                    onPressed: () => setSheet(() => feeling = i),
                    icon: Icon(i <= feeling ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 26)),
            ]),
            TextField(controller: notesCtrl, decoration: _dec(tr(tNotes)), maxLines: 3),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                icon: const Icon(Icons.save),
                label: Text(tr(tSave)),
                onPressed: () async {
                  final d = DateTime.tryParse(dateCtrl.text) ?? DateTime.now();
                  await DiaryStore.add(SessionRecord(
                      date: d, points: pointsCtrl.text.trim(), feeling: feeling, notes: notesCtrl.text.trim()));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ),
          ],
        )),
      ),
    );
    if (mounted) setState(() {});
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF232323),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add),
          label: Text(tr(tNewSession)),
          onPressed: _add),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
            child: Row(children: [
              Text('${tr(tDiary)} • ${DiaryStore.items.length} ${tr(tSessions)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFD4AF37)),
                  tooltip: tr(tExportPdf),
                  onPressed: () => exportDiaryPdf(context, DiaryStore.items)),
            ])),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: DiaryStore.version,
            builder: (context, _, __) => DiaryStore.items.isEmpty
                ? Center(child: Text(tr(tEmpty), style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                    itemCount: DiaryStore.items.length,
                    itemBuilder: (context, i) {
                      final r = DiaryStore.items[i];
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          leading: Text('★${r.feeling}',
                              style: const TextStyle(
                                  color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                          title: Text(r.points,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(DateFormat('yyyy.MM.dd HH:mm').format(r.date),
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (r.notes.isNotEmpty)
                              Text(r.notes, style: const TextStyle(fontSize: 13)),
                          ]),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        backgroundColor: const Color(0xFF1E1E1E),
                                        title: Text(tr(tDelete)),
                                        actions: [
                                          TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: Text(tr(tCancel))),
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                await DiaryStore.removeAt(i);
                                              },
                                              child: const Text('OK')),
                                        ],
                                      ))),
                        ),
                      );
                    }),
          ),
        ),
      ]),
    );
  }
}
