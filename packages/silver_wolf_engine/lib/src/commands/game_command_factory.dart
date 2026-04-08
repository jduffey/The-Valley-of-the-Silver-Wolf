import 'package:silver_wolf_engine/src/commands/game_command.dart';

class GameCommandFactory {
  const GameCommandFactory._();

  static const GameCommand travelClockwise = TravelClockwiseCommand();
  static const GameCommand travelCounterClockwise =
      TravelCounterClockwiseCommand();
  static const GameCommand passTurn = PassTurnCommand();
  static const GameCommand healCurrentPlayer = HealCurrentPlayerCommand();
  static const GameCommand saveCurrentSchool = SaveCurrentSchoolCommand();
  static const GameCommand challengeSilverWolf = ChallengeSilverWolfCommand();
  static const GameCommand undoLastAction = UndoLastActionCommand();

  static GameCommand clearCompletedSchoolRescue(String schoolId) {
    return ClearCompletedSchoolRescueCommand(schoolId);
  }
}
