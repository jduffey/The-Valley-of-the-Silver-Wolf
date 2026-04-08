import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_controller.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';
import 'package:silver_wolf_flutter/features/roster/presentation/player_card.dart';

class RosterSidebar extends StatelessWidget {
  const RosterSidebar({
    required this.viewState,
    required this.controller,
    super.key,
  });

  final GameSessionViewState viewState;
  final GameSessionController controller;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Roster',
      subtitle:
          'Animated roster cards stay ordered from the current player outward.',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Column(
          key: ValueKey<String>(viewState.currentPlayer.id),
          children: viewState.playersInTurnOrder
              .map((Player player) {
                final bool isCurrentPlayer =
                    player.id == viewState.currentPlayer.id;

                return PlayerCard(
                  key: ValueKey<String>('player-card-${player.id}'),
                  player: player,
                  isCurrentPlayer: isCurrentPlayer,
                  isSelected: player.id == viewState.selectedProfilePlayer.id,
                  actionsRemaining: viewState.gameState.actionsRemaining,
                  onSelect: () => controller.selectProfilePlayer(player.id),
                  canTravel: isCurrentPlayer && viewState.canTravel,
                  canHeal: isCurrentPlayer && viewState.canHealCurrentPlayer,
                  canSave: isCurrentPlayer && viewState.canSaveCurrentSchool,
                  canFight: isCurrentPlayer && viewState.canChallengeRival,
                  canPassTurn: isCurrentPlayer && viewState.canPassTurn,
                  canUndo: isCurrentPlayer && viewState.canUndo,
                  onTravelClockwise: () =>
                      controller.dispatch(GameCommandFactory.travelClockwise),
                  onTravelCounterClockwise: () => controller.dispatch(
                    GameCommandFactory.travelCounterClockwise,
                  ),
                  onHeal: () =>
                      controller.dispatch(GameCommandFactory.healCurrentPlayer),
                  onSave: () =>
                      controller.dispatch(GameCommandFactory.saveCurrentSchool),
                  onFight: () =>
                      controller.dispatch(GameCommandFactory.openChallenge),
                  onPassTurn: () =>
                      controller.dispatch(GameCommandFactory.passTurn),
                  onUndo: () =>
                      controller.dispatch(GameCommandFactory.undoLastAction),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
