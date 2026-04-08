import 'package:silver_wolf_engine/src/enums/combat_mode.dart';

sealed class GameCommand {
  const GameCommand();
}

final class OpenChallengeCommand extends GameCommand {
  const OpenChallengeCommand();
}

final class ChooseChallengeTargetCommand extends GameCommand {
  const ChooseChallengeTargetCommand(this.targetId);

  final String targetId;
}

final class AcceptChallengeCommand extends GameCommand {
  const AcceptChallengeCommand();
}

final class DeclineChallengeCommand extends GameCommand {
  const DeclineChallengeCommand();
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

final class SelectCombatCardCommand extends GameCommand {
  const SelectCombatCardCommand(this.fighterId, this.cardId);

  final String fighterId;
  final String cardId;
}

final class SelectCombatModeCommand extends GameCommand {
  const SelectCombatModeCommand(this.fighterId, this.mode);

  final String fighterId;
  final CombatMode mode;
}

final class TriggerCombatStumbleCommand extends GameCommand {
  const TriggerCombatStumbleCommand(this.fighterId);

  final String fighterId;
}

final class AdvanceCombatPhaseCommand extends GameCommand {
  const AdvanceCombatPhaseCommand();
}
