import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/widgets/resource_pips.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.player,
    required this.isCurrentPlayer,
    required this.isSelected,
    required this.actionsRemaining,
    required this.onSelect,
    required this.canTravel,
    required this.canHeal,
    required this.canSave,
    required this.canFight,
    required this.canPassTurn,
    required this.canUndo,
    required this.onTravelClockwise,
    required this.onTravelCounterClockwise,
    required this.onHeal,
    required this.onSave,
    required this.onFight,
    required this.onPassTurn,
    required this.onUndo,
    super.key,
  });

  final Player player;
  final bool isCurrentPlayer;
  final bool isSelected;
  final int actionsRemaining;
  final VoidCallback onSelect;
  final bool canTravel;
  final bool canHeal;
  final bool canSave;
  final bool canFight;
  final bool canPassTurn;
  final bool canUndo;
  final VoidCallback onTravelClockwise;
  final VoidCallback onTravelCounterClockwise;
  final VoidCallback onHeal;
  final VoidCallback onSave;
  final VoidCallback onFight;
  final VoidCallback onPassTurn;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF9F2E6) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrentPlayer
              ? const Color(0xFFD6A04B)
              : const Color(0xFFD9D2C3),
          width: isCurrentPlayer ? 2.4 : 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${player.id.toUpperCase()} • ${player.name}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isCurrentPlayer
                        ? const Chip(
                            key: ValueKey<String>('current-player-chip'),
                            label: Text('Current'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: <Widget>[
                  ResourcePips(
                    label: 'Reputation',
                    filled: player.reputation,
                    total: 5,
                    activeColor: const Color(0xFFD6A04B),
                  ),
                  ResourcePips(
                    label: 'Hit Points',
                    filled: player.hitPoints,
                    total: 3,
                    activeColor: const Color(0xFFB5523F),
                  ),
                  ResourcePips(
                    label: 'Form Points',
                    filled: player.formPoints,
                    total: 2,
                    activeColor: const Color(0xFF466A58),
                  ),
                  if (isCurrentPlayer)
                    ResourcePips(
                      label: 'Actions',
                      filled: actionsRemaining,
                      total: 3,
                      activeColor: const Color(0xFF2F4154),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Power ${player.power} • Stamina ${player.stamina} • Agility ${player.agility} • Chi ${player.chi} • Wit ${player.wit}',
                style: theme.textTheme.bodyMedium,
              ),
              if (isCurrentPlayer) ...<Widget>[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton(
                      onPressed: canTravel ? onTravelClockwise : null,
                      child: const Text('Move CW'),
                    ),
                    OutlinedButton(
                      onPressed: canTravel ? onTravelCounterClockwise : null,
                      child: const Text('Move CCW'),
                    ),
                    OutlinedButton(
                      onPressed: canHeal ? onHeal : null,
                      child: const Text('Heal'),
                    ),
                    OutlinedButton(
                      onPressed: canSave ? onSave : null,
                      child: const Text('Save'),
                    ),
                    OutlinedButton(
                      onPressed: canFight ? onFight : null,
                      child: const Text('Challenge'),
                    ),
                    OutlinedButton(
                      onPressed: canPassTurn ? onPassTurn : null,
                      child: const Text('Pass'),
                    ),
                    OutlinedButton(
                      onPressed: canUndo ? onUndo : null,
                      child: const Text('Undo'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
