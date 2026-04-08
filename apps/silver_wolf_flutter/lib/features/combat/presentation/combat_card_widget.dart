import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';

class CombatCardWidget extends StatelessWidget {
  const CombatCardWidget({
    required this.card,
    required this.isSelected,
    required this.isEffective,
    required this.onPressed,
    this.cardKey,
    super.key,
  });

  final CombatCard card;
  final bool isSelected;
  final bool isEffective;
  final VoidCallback onPressed;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final Color accent = card.isSpecial
        ? const Color(0xFFD6A04B)
        : const Color(0xFF2F4154);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: cardKey,
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? accent : const Color(0xFFD9D2C3),
              width: isSelected ? 2.4 : 1.2,
            ),
            boxShadow: <BoxShadow>[
              if (isEffective)
                BoxShadow(
                  color: accent.withValues(alpha: 0.24),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(card.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Attack: ${card.attack.name}'),
              Text('Defense: ${card.defense.name}'),
              Text('Swap: ${card.swapLane.name}'),
              const SizedBox(height: 8),
              Text(
                card.isSpecial ? 'Special card' : 'Base technique',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
