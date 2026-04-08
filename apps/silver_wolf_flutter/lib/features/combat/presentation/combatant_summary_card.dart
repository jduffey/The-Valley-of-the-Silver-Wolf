import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/core/widgets/resource_pips.dart';

class CombatantSummaryCard extends StatelessWidget {
  const CombatantSummaryCard({
    required this.combatant,
    required this.isAttacker,
    super.key,
  });

  final CombatantState combatant;
  final bool isAttacker;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: combatant.name,
      subtitle:
          '${combatant.hometownName} • ${isAttacker ? 'Attacker' : 'Defender'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Keyword: ${combatant.keyword}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: <Widget>[
              ResourcePips(
                label: 'Hit Points',
                filled: combatant.currentHitPoints,
                total: combatant.maxHitPoints,
                activeColor: const Color(0xFFB5523F),
              ),
              ResourcePips(
                label: 'Form Points',
                filled: combatant.currentFormPoints,
                total: combatant.maxFormPoints,
                activeColor: const Color(0xFF466A58),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
