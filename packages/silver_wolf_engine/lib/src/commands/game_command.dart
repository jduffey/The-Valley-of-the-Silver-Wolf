sealed class GameCommand {
  const GameCommand();
}

final class TravelClockwiseCommand extends GameCommand {
  const TravelClockwiseCommand();
}

final class TravelCounterClockwiseCommand extends GameCommand {
  const TravelCounterClockwiseCommand();
}

final class PassTurnCommand extends GameCommand {
  const PassTurnCommand();
}

final class HealCurrentPlayerCommand extends GameCommand {
  const HealCurrentPlayerCommand();
}

final class SaveCurrentSchoolCommand extends GameCommand {
  const SaveCurrentSchoolCommand();
}

final class ChallengeSilverWolfCommand extends GameCommand {
  const ChallengeSilverWolfCommand();
}

final class UndoLastActionCommand extends GameCommand {
  const UndoLastActionCommand();
}

final class ClearCompletedSchoolRescueCommand extends GameCommand {
  const ClearCompletedSchoolRescueCommand(this.schoolId);

  final String schoolId;
}
