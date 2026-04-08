import 'package:silver_wolf_engine/src/constants/game_constants.dart';
import 'package:silver_wolf_engine/src/models/player.dart';

int clampStat(int value) {
  if (value < 0) {
    return 0;
  }
  if (value > maxStat) {
    return maxStat;
  }
  return value;
}

List<Player> clonePlayers(List<Player> players) {
  return players
      .map((Player player) => player.copyWith())
      .toList(growable: false);
}

List<Player> getAlivePlayers(List<Player> players) {
  return players.where((Player player) => player.alive).toList(growable: false);
}

int getTotalStats(Player player) {
  return player.power +
      player.stamina +
      player.agility +
      player.chi +
      player.wit;
}

String getPlayerDisplayName(Player player) {
  final RegExpMatch? match = RegExp(
    r'^p(\d+)$',
    caseSensitive: false,
  ).firstMatch(player.id);
  if (match == null) {
    return 'Player';
  }
  return 'Player ${match.group(1)}';
}

int getActionsForPlayer(Player player) {
  final int baseActions = player.injured ? 1 : 2;
  return baseActions + player.bonusActionsNextTurn;
}

({List<Player> players, int actions, int consumedBonusActions})
consumeNextTurnActionBonus(List<Player> players, int playerIndex) {
  final Player player = players[playerIndex];
  final int consumedBonusActions = player.bonusActionsNextTurn;

  if (consumedBonusActions == 0) {
    return (
      players: players,
      actions: getActionsForPlayer(player),
      consumedBonusActions: 0,
    );
  }

  final List<Player> updatedPlayers = <Player>[
    ...players.take(playerIndex),
    player.copyWith(bonusActionsNextTurn: 0),
    ...players.skip(playerIndex + 1),
  ];

  return (
    players: updatedPlayers,
    actions: getActionsForPlayer(player),
    consumedBonusActions: consumedBonusActions,
  );
}

List<Player> grantSingleUseActionForNextTurn(
  List<Player> players,
  String playerId,
) {
  return players
      .map(
        (Player player) => player.id == playerId
            ? player.copyWith(
                bonusActionsNextTurn: player.bonusActionsNextTurn + 1,
              )
            : player,
      )
      .toList(growable: false);
}

int getNextLivingIndex(List<Player> players, int currentIndex) {
  for (int offset = 1; offset <= players.length; offset += 1) {
    final int candidateIndex = (currentIndex + offset) % players.length;
    if (players[candidateIndex].alive) {
      return candidateIndex;
    }
  }

  return currentIndex;
}

Player lowerReputation(Player player, [int amount = 1]) {
  return player.copyWith(reputation: clampStat(player.reputation - amount));
}

Player injurePlayer(Player player) {
  return player.copyWith(injured: true);
}

Player healPlayer(Player player) {
  return player.copyWith(injured: false);
}

Player raiseReputation(Player player, [int amount = 1]) {
  return player.copyWith(reputation: clampStat(player.reputation + amount));
}
