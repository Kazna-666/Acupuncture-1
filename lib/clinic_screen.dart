import 'package:flutter/material.dart';
import 'l10n.dart';
import 'clinical_data.dart';
import 'meridian_data.dart';
import 'points_data.dart';
import 'points_screen.dart';

/// Вкладка «Клиника»: каталог болезней и лекарств ТКМ
class ClinicScreen extends StatelessWidget {
  const ClinicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        Material(
          color: Colors.black,
          child: TabBar(
            indicatorColor: const Color(0xFFD4AF37),
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: const Icon(Icons.medical_services, size: 20), text: tr(tDiseases)),
              Tab(icon: const Icon(Icons.local_florist, size: 20), text: tr(tFormulas)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(children: [
            _DiseaseList(),
            _FormulaList(),
          ]),
        ),
      ]),
    );
  }
}

class _DiseaseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      itemCount: ClinicalData.syndromes.length,
      itemBuilder: (context, i) {
        final s = ClinicalData.syndromes[i];
        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: const Icon(Icons.healing, color: Color(0xFFE74C3C)),
            title: Text(tr(s.name), style: const TextStyle(fontSize: 15)),
            subtitle: Text(s.points.join(', '),
                style: const TextStyle(fontSize: 12, color: Color(0xFF27AE60))),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DiseaseDetailScreen(syndrome: s))),
          ),
        );
      },
    );
  }
}

class DiseaseDetailScreen extends StatelessWidget {
  final TcmSyndrome syndrome;
  const DiseaseDetailScreen({Key? key, required this.syndrome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TcmFormula? formula;
    if (syndrome.formulaId != null) {
      for (final f in ClinicalData.formulas) {
        if (f.id == syndrome.formulaId) {
          formula = f;
          break;
        }
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
          title: Text(tr(syndrome.name),
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          backgroundColor: Colors.black),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(tr(tSyndrome), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr(syndrome.name), style: const TextStyle(fontSize: 16)),
          const Divider(height: 26),
          Text(tr(tManifest), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr(syndrome.manifest), style: const TextStyle(fontSize: 14, height: 1.45)),
          const Divider(height: 26),
          Text(tr(tRecipe), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final code in syndrome.points)
                ActionChip(
                  backgroundColor: const Color(0xFF1F3325),
                  side: const BorderSide(color: Color(0xFF27AE60)),
                  label: Text(code,
                      style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final m = meridianOfCode(code);
                    final p = PointsData.find(code);
                    if (p != null) showPointSheet(context, m, p);
                  },
                ),
            ],
          ),
          const Divider(height: 26),
          if (formula != null) ...[
            Text(tr(tFormulaRef), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white10)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${formula.hanzi} — ${tr(formula.name)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('${tr(tComposition)} ${formula.composition}',
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                  const SizedBox(height: 6),
                  Text('${tr(tAction)} ${tr(formula.action)}',
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                ]),
              ),
            ),
          ] else
            Text(tr(tFormulaRef),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 14),
          Text(tr(tSafety), style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }
}

class _FormulaList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      itemCount: ClinicalData.formulas.length,
      itemBuilder: (context, i) {
        final f = ClinicalData.formulas[i];
        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: const Icon(Icons.local_florist, color: Color(0xFF52BE80)),
            title: Text(f.hanzi, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Text(tr(f.name), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => FormulaDetailScreen(formula: f))),
          ),
        );
      },
    );
  }
}

class FormulaDetailScreen extends StatelessWidget {
  final TcmFormula formula;
  const FormulaDetailScreen({Key? key, required this.formula}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
          title: Text(formula.hanzi,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          backgroundColor: Colors.black),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('${formula.hanzi}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr(formula.name),
              style: const TextStyle(fontSize: 15, color: Colors.grey)),
          const Divider(height: 26),
          Text(tr(tComposition), style: const TextStyle(color: Color(0xFF52BE80), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(formula.composition, style: const TextStyle(fontSize: 14, height: 1.5)),
          const Divider(height: 26),
          Text(tr(tAction), style: const TextStyle(color: Color(0xFF52BE80), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr(formula.action), style: const TextStyle(fontSize: 14, height: 1.45)),
          const SizedBox(height: 14),
          Text(tr(tSafety), style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }
}
