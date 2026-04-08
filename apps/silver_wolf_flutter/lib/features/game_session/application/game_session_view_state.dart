import 'package:silver_wolf_engine/silver_wolf_engine.dart';

enum GameSessionDialog { challenge, combat, hometown }

class GameSessionViewState {
  const GameSessionViewState({
    required this.gameState,
    required this.selectedProfilePlayerId,
    required this.openDialog,
    required this.isAnimatingSaveCompletion,
  });

  final GameState gameState;
  final String? selectedProfilePlayerId;
  final GameSessionDialog? openDialog;
  final bool isAnimatingSaveCompletion;

  Player get currentPlayer => gameState.currentPlayer;

  Player get selectedProfilePlayer {
    final String resolvedId = selectedProfilePlayerId ?? currentPlayer.id;
    final int playerIndex = gameState.players.indexWhere(
      (Player player) => player.id == resolvedId,
    );
    if (playerIndex == -1) {
      return currentPlayer;
    }
    return gameState.players[playerIndex];
  }

  List<Player> get playersInArrivalOrder {
    final List<Player> players = List<Player>.from(gameState.players);
    players.sort(
      (Player left, Player right) =>
          left.arrivalOrder.compareTo(right.arrivalOrder),
    );
    return players;
  }

  GameSessionViewState copyWith({
    GameState? gameState,
    String? selectedProfilePlayerId,
    bool clearSelectedProfile = false,
    GameSessionDialog? openDialog,
    bool clearOpenDialog = false,
    bool? isAnimatingSaveCompletion,
  }) {
    return GameSessionViewState(
      gameState: gameState ?? this.gameState,
      selectedProfilePlayerId: clearSelectedProfile
          ? null
          : selectedProfilePlayerId ?? this.selectedProfilePlayerId,
      openDialog: clearOpenDialog ? null : openDialog ?? this.openDialog,
      isAnimatingSaveCompletion:
          isAnimatingSaveCompletion ?? this.isAnimatingSaveCompletion,
    );
  }
}
