import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/extensions/hex_color.dart';
import 'package:silver_wolf_flutter/core/services/asset_catalog.dart';
import 'package:silver_wolf_flutter/core/widgets/sigil_medallion.dart';
import 'package:silver_wolf_flutter/core/widgets/textured_modal_surface.dart';

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
    final String? challengerSigil = AssetCatalog.sigilForTownName(
      challenger.name,
    );

    return _OverlayShell(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: TexturedModalSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SigilMedallion(
                    assetPath: challengerSigil,
                    accent: challenger.color.toColor(),
                    size: 72,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Combat Challenge',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Player ${challenger.id.substring(1)} from ${challenger.name} is calling out a rival.',
                        ),
                      ],
                    ),
                  ),
                ],
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
                        avatar: CircleAvatar(
                          backgroundColor: opponent.color.toColor().withValues(
                            alpha: 0.2,
                          ),
                          child: Text(opponent.id.substring(1)),
                        ),
                        label: Text(opponent.name),
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
