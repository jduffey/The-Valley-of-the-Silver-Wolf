import 'package:silver_wolf_engine/src/commands/game_command.dart';
import 'package:silver_wolf_engine/src/constants/game_constants.dart';
import 'package:silver_wolf_engine/src/models/game_state.dart';
import 'package:silver_wolf_engine/src/random/randomizer.dart';
import 'package:silver_wolf_engine/src/reducers/turn_reducer.dart';
import 'package:silver_wolf_engine/src/results/command_result.dart';

class GameReducer {
  const GameReducer._();

  static CommandResult reduce(
    GameState state,
    GameCommand command,
    Randomizer randomizer,
  ) {
    return switch (command) {
      TravelClockwiseCommand() => TurnReducer.travel(
        state,
        clockwiseDirection,
        randomizer,
      ),
      TravelCounterClockwiseCommand() => TurnReducer.travel(
        state,
        counterClockwiseDirection,
        randomizer,
      ),
      PassTurnCommand() => TurnReducer.passTurn(state, randomizer),
      HealCurrentPlayerCommand() => TurnReducer.healCurrentPlayer(
        state,
        randomizer,
      ),
      SaveCurrentSchoolCommand() => TurnReducer.saveCurrentSchool(
        state,
        randomizer,
      ),
      ChallengeSilverWolfCommand() => TurnReducer.challengeSilverWolf(
        state,
        randomizer,
      ),
      UndoLastActionCommand() => TurnReducer.undoLastAction(state),
      ClearCompletedSchoolRescueCommand(:final schoolId) =>
        TurnReducer.clearCompletedSchoolRescue(state, schoolId),
    };
  }
}
