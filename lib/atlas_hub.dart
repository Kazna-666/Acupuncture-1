import 'package:flutter/material.dart';
import 'l10n.dart';
import 'atlas_screen.dart';
import 'zones_screen.dart';

/// Переключатель: схема тела / крупные зоны
class AtlasHub extends StatefulWidget {
  const AtlasHub({Key? key}) : super(key: key);
  @override
  State<AtlasHub> createState() => _AtlasHubState();
}

class _AtlasHubState extends State<AtlasHub> {
  bool _zones = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ChoiceChip(
            label: Text(tr(tBody)),
            selected: !_zones,
            selectedColor: const Color(0xFFD4AF37),
            labelStyle: TextStyle(color: !_zones ? Colors.black : Colors.white),
            onSelected: (_) => setState(() => _zones = false)),
        const SizedBox(width: 10),
        ChoiceChip(
            label: Text(tr(tZones)),
            selected: _zones,
            selectedColor: const Color(0xFFD4AF37),
            labelStyle: TextStyle(color: _zones ? Colors.black : Colors.white),
            onSelected: (_) => setState(() => _zones = true)),
      ]),
      Expanded(child: _zones ? const ZonesScreen() : const AtlasScreen()),
    ]);
  }
}
