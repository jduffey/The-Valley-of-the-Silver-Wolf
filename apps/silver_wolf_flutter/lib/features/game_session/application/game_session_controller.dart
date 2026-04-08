import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/services/app_randomizer.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

class GameSessionController extends Notifier<GameSessionViewState> {
  @override
  GameSessionViewState build() {
    final GameState initialState = InitialStateFactory.create();
    return GameSessionViewState(
      gameState: initialState,
      selectedProfilePlayerId: initialState.currentPlayer.id,
      openDialog: _dialogForState(initialState),
      isAnimatingSaveCompletion: false,
    );
  }

  void dispatch(GameCommand command) {
    final Randomizer randomizer = ref.read(appRandomizerProvider);
    final CommandResult result = GameReducer.reduce(
      state.gameState,
      command,
      randomizer,
    );
    final GameState nextState = result.state;

    state = state.copyWith(
      gameState: nextState,
      selectedProfilePlayerId: _resolveSelectedProfilePlayerId(nextState),
      openDialog: _dialogForState(nextState),
    );
  }

  void selectProfilePlayer(String playerId) {
    if (!state.gameState.players.any(
      (Player player) => player.id == playerId,
    )) {
      return;
    }

    state = state.copyWith(selectedProfilePlayerId: playerId);
  }

  void resetSession() {
    final GameState nextState = InitialStateFactory.create();
    state = GameSessionViewState(
      gameState: nextState,
      selectedProfilePlayerId: nextState.currentPlayer.id,
      openDialog: null,
      isAnimatingSaveCompletion: false,
    );
  }

  String _resolveSelectedProfilePlayerId(GameState nextState) {
    final String? existingId = state.selectedProfilePlayerId;
    if (existingId != null &&
        nextState.players.any((Player player) => player.id == existingId)) {
      return existingId;
    }

    return nextState.currentPlayer.id;
  }

  GameSessionDialog? _dialogForState(GameState gameState) {
    if (gameState.combatState != null) {
      return GameSessionDialog.combat;
    }
    if (gameState.challengeState != null) {
      return GameSessionDialog.challenge;
    }
    return null;
  }
}
