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

  Location get currentLocation => trackDetails[currentPlayer.position];

  School? get currentSchool {
    final int schoolIndex = gameState.schools.indexWhere(
      (School school) => school.id == currentLocation.id,
    );
    if (schoolIndex == -1) {
      return null;
    }
    return gameState.schools[schoolIndex];
  }

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

  List<Player> get playersInTurnOrder {
    final List<Player> players = <Player>[];

    for (int offset = 0; offset < gameState.players.length; offset += 1) {
      final int index =
          (gameState.currentPlayerIndex + offset) % gameState.players.length;
      players.add(gameState.players[index]);
    }

    return players;
  }

  List<Player> get currentPlayerRivals {
    return getRivalsAtPosition(gameState.players, gameState.currentPlayerIndex);
  }

  bool get isTurnLocked {
    return gameState.challengeState != null ||
        gameState.combatState != null ||
        gameState.winnerId != null ||
        gameState.gameOverReason != null;
  }

  bool get canTravel =>
      !isTurnLocked && currentPlayer.alive && gameState.actionsRemaining > 0;

  bool get canPassTurn => !isTurnLocked && currentPlayer.alive;

  bool get canHealCurrentPlayer =>
      canTravel &&
      currentPlayer.injured &&
      currentLocation.type == LocationType.town;

  bool get canSaveCurrentSchool =>
      canTravel &&
      currentSchool != null &&
      currentSchool!.status == SchoolStatus.sieged &&
      !currentSchool!.isCompletingSave;

  bool get canChallengeRival => canTravel && currentPlayerRivals.isNotEmpty;

  bool get canChallengeSilverWolfNow =>
      canTravel &&
      gameState.pendingRoll == null &&
      canChallengeSilverWolf(currentPlayer);

  bool get canUndo =>
      !isTurnLocked &&
      currentPlayer.alive &&
      gameState.undoSnapshot != null &&
      gameState.undoSnapshot!.playerId == currentPlayer.id;

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
