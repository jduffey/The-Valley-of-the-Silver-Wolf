import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/widgets/textured_modal_surface.dart';
import 'package:silver_wolf_flutter/features/combat/presentation/combat_card_widget.dart';
import 'package:silver_wolf_flutter/features/combat/presentation/combat_phase_strip.dart';
import 'package:silver_wolf_flutter/features/combat/presentation/combatant_summary_card.dart';

class CombatDialog extends StatelessWidget {
  const CombatDialog({
    required this.combatState,
    required this.onChooseCard,
    required this.onChooseMode,
    required this.onAdvancePhase,
    required this.onTriggerStumble,
    super.key,
  });

  final CombatState combatState;
  final void Function(String fighterId, String cardId) onChooseCard;
  final void Function(String fighterId, CombatMode mode) onChooseMode;
  final VoidCallback onAdvancePhase;
  final ValueChanged<String> onTriggerStumble;

  @override
  Widget build(BuildContext context) {
    final CombatantState leftCombatant =
        combatState.combatants[combatState.attackerId]!;
    final CombatantState rightCombatant =
        combatState.combatants[combatState.defenderId]!;

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.52),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 900),
              child: Material(
                color: Colors.transparent,
                child: TexturedModalSurface(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Combat Encounter',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          Text('Clash ${combatState.clashNumber}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CombatPhaseStrip(phase: combatState.phase),
                      const SizedBox(height: 18),
                      Expanded(
                        child: LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                if (constraints.maxWidth < 960) {
                                  return ListView(
                                    children: <Widget>[
                                      CombatantSummaryCard(
                                        combatant: leftCombatant,
                                        isAttacker: true,
                                      ),
                                      const SizedBox(height: 12),
                                      _CombatPhaseBody(
                                        combatState: combatState,
                                        leftCombatant: leftCombatant,
                                        rightCombatant: rightCombatant,
                                        onChooseCard: onChooseCard,
                                        onChooseMode: onChooseMode,
                                        onTriggerStumble: onTriggerStumble,
                                      ),
                                      const SizedBox(height: 12),
                                      CombatantSummaryCard(
                                        combatant: rightCombatant,
                                        isAttacker: false,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 270,
                                      child: CombatantSummaryCard(
                                        combatant: leftCombatant,
                                        isAttacker: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _CombatPhaseBody(
                                        combatState: combatState,
                                        leftCombatant: leftCombatant,
                                        rightCombatant: rightCombatant,
                                        onChooseCard: onChooseCard,
                                        onChooseMode: onChooseMode,
                                        onTriggerStumble: onTriggerStumble,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 270,
                                      child: CombatantSummaryCard(
                                        combatant: rightCombatant,
                                        isAttacker: false,
                                      ),
                                    ),
                                  ],
                                );
                              },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _canAdvance(combatState)
                              ? onAdvancePhase
                              : null,
                          child: Text(_buttonLabel(combatState)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canAdvance(CombatState combatState) {
    if (combatState.phase != CombatPhase.selection) {
      return true;
    }

    final CombatantState leftCombatant =
        combatState.combatants[combatState.attackerId]!;
    final CombatantState rightCombatant =
        combatState.combatants[combatState.defenderId]!;
    return leftCombatant.selectedCardId != null &&
        leftCombatant.selectedMode != null &&
        rightCombatant.selectedCardId != null &&
        rightCombatant.selectedMode != null;
  }

  String _buttonLabel(CombatState combatState) {
    if (combatState.phase == CombatPhase.calculation &&
        getCombatLoserId(combatState) != null) {
      return 'Resolve Combat';
    }
    if (combatState.phase == CombatPhase.activation) {
      return 'Next Clash';
    }
    return 'Next Phase';
  }
}

class _CombatPhaseBody extends StatelessWidget {
  const _CombatPhaseBody({
    required this.combatState,
    required this.leftCombatant,
    required this.rightCombatant,
    required this.onChooseCard,
    required this.onChooseMode,
    required this.onTriggerStumble,
  });

  final CombatState combatState;
  final CombatantState leftCombatant;
  final CombatantState rightCombatant;
  final void Function(String fighterId, String cardId) onChooseCard;
  final void Function(String fighterId, CombatMode mode) onChooseMode;
  final ValueChanged<String> onTriggerStumble;

  @override
  Widget build(BuildContext context) {
    return switch (combatState.phase) {
      CombatPhase.selection => _SelectionPhase(
        leftCombatant: leftCombatant,
        rightCombatant: rightCombatant,
        onChooseCard: onChooseCard,
        onChooseMode: onChooseMode,
      ),
      CombatPhase.reveal => _RevealPhase(
        leftCombatant: leftCombatant,
        rightCombatant: rightCombatant,
      ),
      CombatPhase.reaction => _ReactionPhase(
        leftCombatant: leftCombatant,
        rightCombatant: rightCombatant,
        onTriggerStumble: onTriggerStumble,
      ),
      CombatPhase.calculation => _CalculationPhase(
        summary: combatState.resolutionSummary,
      ),
      CombatPhase.activation => _ActivationPhase(
        clashLog: combatState.clashLog,
      ),
    };
  }
}

class _SelectionPhase extends StatelessWidget {
  const _SelectionPhase({
    required this.leftCombatant,
    required this.rightCombatant,
    required this.onChooseCard,
    required this.onChooseMode,
  });

  final CombatantState leftCombatant;
  final CombatantState rightCombatant;
  final void Function(String fighterId, String cardId) onChooseCard;
  final void Function(String fighterId, CombatMode mode) onChooseMode;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _CombatSelectionColumn(
          combatant: leftCombatant,
          onChooseCard: onChooseCard,
          onChooseMode: onChooseMode,
        ),
        const SizedBox(height: 16),
        _CombatSelectionColumn(
          combatant: rightCombatant,
          onChooseCard: onChooseCard,
          onChooseMode: onChooseMode,
        ),
      ],
    );
  }
}

class _CombatSelectionColumn extends StatelessWidget {
  const _CombatSelectionColumn({
    required this.combatant,
    required this.onChooseCard,
    required this.onChooseMode,
  });

  final CombatantState combatant;
  final void Function(String fighterId, String cardId) onChooseCard;
  final void Function(String fighterId, CombatMode mode) onChooseMode;

  @override
  Widget build(BuildContext context) {
    final CombatCard? selectedCard = getCombatCardById(
      combatant,
      combatant.selectedCardId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(combatant.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: combatant.hand
              .map(
                (CombatCard card) => SizedBox(
                  width: 188,
                  child: CombatCardWidget(
                    card: card,
                    cardKey: ValueKey<String>(
                      'combat-card-${combatant.id}-${card.id}',
                    ),
                    isSelected: combatant.selectedCardId == card.id,
                    isEffective:
                        combatant.effectiveCardId == card.id &&
                        combatant.selectedCardId != card.id,
                    onPressed: () => onChooseCard(combatant.id, card.id),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        if (selectedCard != null) ...<Widget>[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: getAvailableModes(selectedCard)
                .map((CombatModeOption option) {
                  final bool disabled =
                      option.cost > combatant.currentFormPoints;

                  return ChoiceChip(
                    key: ValueKey<String>(
                      'combat-mode-${combatant.id}-${option.id.name}',
                    ),
                    label: Text('${option.label} (${option.cost})'),
                    selected: combatant.selectedMode == option.id,
                    onSelected: disabled
                        ? null
                        : (_) => onChooseMode(combatant.id, option.id),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}

class _RevealPhase extends StatelessWidget {
  const _RevealPhase({
    required this.leftCombatant,
    required this.rightCombatant,
  });

  final CombatantState leftCombatant;
  final CombatantState rightCombatant;

  @override
  Widget build(BuildContext context) {
    final EffectiveCombatCard? leftCard = getEffectiveCardForCombatant(
      leftCombatant,
    );
    final EffectiveCombatCard? rightCard = getEffectiveCardForCombatant(
      rightCombatant,
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: _RevealCard(combatant: leftCombatant, effectiveCard: leftCard),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RevealCard(
            combatant: rightCombatant,
            effectiveCard: rightCard,
          ),
        ),
      ],
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({required this.combatant, required this.effectiveCard});

  final CombatantState combatant;
  final EffectiveCombatCard? effectiveCard;

  @override
  Widget build(BuildContext context) {
    if (effectiveCard == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(combatant.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        CombatCardWidget(
          card: effectiveCard!.card,
          isSelected: true,
          isEffective: true,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        Text(
          effectiveCard!.keywordActive
              ? 'Keyword Active: ${effectiveCard!.keyword}'
              : 'Keyword inactive this clash.',
        ),
      ],
    );
  }
}

class _ReactionPhase extends StatelessWidget {
  const _ReactionPhase({
    required this.leftCombatant,
    required this.rightCombatant,
    required this.onTriggerStumble,
  });

  final CombatantState leftCombatant;
  final CombatantState rightCombatant;
  final ValueChanged<String> onTriggerStumble;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ReactionCard(
            combatant: leftCombatant,
            onTriggerStumble: onTriggerStumble,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ReactionCard(
            combatant: rightCombatant,
            onTriggerStumble: onTriggerStumble,
          ),
        ),
      ],
    );
  }
}

class _ReactionCard extends StatelessWidget {
  const _ReactionCard({
    required this.combatant,
    required this.onTriggerStumble,
  });

  final CombatantState combatant;
  final ValueChanged<String> onTriggerStumble;

  @override
  Widget build(BuildContext context) {
    final EffectiveCombatCard? effectiveCard = getEffectiveCardForCombatant(
      combatant,
    );
    final bool canStumble =
        effectiveCard != null &&
        effectiveCard.allowsReactionStumble &&
        !combatant.stumbleTriggered;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(combatant.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              canStumble
                  ? 'Stumble can swap this revealed card for another random card in hand.'
                  : 'No optional reaction remains for this fighter in this clash.',
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: ValueKey<String>('combat-stumble-${combatant.id}'),
              onPressed: canStumble
                  ? () => onTriggerStumble(combatant.id)
                  : null,
              child: const Text('Trigger Stumble'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationPhase extends StatelessWidget {
  const _CalculationPhase({required this.summary});

  final CombatResolutionSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(summary?.leftSummary ?? 'No summary yet.'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(summary?.rightSummary ?? 'No summary yet.'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivationPhase extends StatelessWidget {
  const _ActivationPhase({required this.clashLog});

  final List<String> clashLog;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Technique activation is not implemented yet. The clash loop and deck exhaustion rules still advance exactly like the prototype.',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                clashLog.isEmpty ? 'No clash events yet.' : clashLog.first,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
