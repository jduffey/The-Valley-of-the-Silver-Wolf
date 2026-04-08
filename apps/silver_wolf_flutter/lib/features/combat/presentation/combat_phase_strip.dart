import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';

class CombatPhaseStrip extends StatelessWidget {
  const CombatPhaseStrip({required this.phase, super.key});

  final CombatPhase phase;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CombatPhase.values
          .map((CombatPhase value) {
            final bool isActive = value == phase;
            final bool isComplete = value.index < phase.index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2F4154)
                    : isComplete
                    ? const Color(0xFFD6A04B)
                    : const Color(0xFFF4EBDD),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                value.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF1E2430),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
