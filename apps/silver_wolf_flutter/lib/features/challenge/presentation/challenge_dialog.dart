import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';

class ChallengeDialog extends StatelessWidget {
  const ChallengeDialog({
    required this.challengeState,
    required this.players,
    required this.onChooseTarget,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final ChallengeState challengeState;
  final List<Player> players;
  final ValueChanged<String> onChooseTarget;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final Player challenger = players.firstWhere(
      (Player player) => player.id == challengeState.challengerId,
    );
    final List<Player> opponents = players
        .where(
          (Player player) => challengeState.opponentIds.contains(player.id),
        )
        .toList(growable: false);
    final Player? target = challengeState.targetId == null
        ? null
        : players.firstWhere(
            (Player player) => player.id == challengeState.targetId,
          );

    return _OverlayShell(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Combat Challenge',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Player ${challenger.id.substring(1)} is calling out a rival.',
                ),
                const SizedBox(height: 18),
                Text(
                  target == null
                      ? 'Choose a rival to face.'
                      : 'Selected opponent: Player ${target.id.substring(1)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: opponents
                      .map(
                        (Player opponent) => ChoiceChip(
                          key: ValueKey<String>(
                            'challenge-target-${opponent.id}',
                          ),
                          label: Text('Player ${opponent.id.substring(1)}'),
                          selected: opponent.id == challengeState.targetId,
                          onSelected: (_) => onChooseTarget(opponent.id),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: target == null ? null : onDecline,
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: target == null ? null : onAccept,
                        child: const Text('Accept Challenge'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayShell extends StatelessWidget {
  const _OverlayShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}
