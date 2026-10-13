import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'l10n.dart';
import 'diary_screen.dart';

/// Экспорт дневника в PDF (встроенные шрифты: кириллица + иероглифы)
Future<void> exportDiaryPdf(BuildContext context, List<SessionRecord> items) async {
  if (items.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr(tEmpty))));
    return;
  }
  pw.Font base;
  pw.Font? cjk;
  try {
    base = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
  } catch (_) {
    base = pw.Font.helvetica();
  }
  try {
    cjk = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'));
  } catch (_) {}

  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(
            font: base, fontFallback: [if (cjk != null) cjk])),
    build: (ctx) => [
      pw.Text(tr(const T3('Дневник сеансов', 'Session diary', '治疗日志')),
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.Text(
          '${tr(tSessions)}: ${items.length} • ${DateFormat('yyyy.MM.dd').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      pw.SizedBox(height: 12),
      ...items.map((r) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(DateFormat('yyyy.MM.dd HH:mm').format(r.date),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('★' * r.feeling,
                            style: const pw.TextStyle(color: PdfColors.amber800)),
                      ]),
                  pw.SizedBox(height: 4),
                  pw.Text(r.points,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, color: PdfColors.brown)),
                  if (r.notes.isNotEmpty)
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(r.notes)),
                ]))),
    ],
  ));
  await Printing.layoutPdf(onLayout: (_) => doc.save());
}
