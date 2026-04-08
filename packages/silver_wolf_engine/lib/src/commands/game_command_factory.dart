import 'package:silver_wolf_engine/src/commands/game_command.dart';
import 'package:silver_wolf_engine/src/enums/combat_mode.dart';

class GameCommandFactory {
  const GameCommandFactory._();

  static const GameCommand openChallenge = OpenChallengeCommand();
  static const GameCommand acceptChallenge = AcceptChallengeCommand();
  static const GameCommand declineChallenge = DeclineChallengeCommand();
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

  static GameCommand chooseChallengeTarget(String targetId) {
    return ChooseChallengeTargetCommand(targetId);
  }

  static GameCommand selectCombatCard(String fighterId, String cardId) {
    return SelectCombatCardCommand(fighterId, cardId);
  }

  static GameCommand selectCombatMode(String fighterId, CombatMode mode) {
    return SelectCombatModeCommand(fighterId, mode);
  }

  static GameCommand triggerCombatStumble(String fighterId) {
    return TriggerCombatStumbleCommand(fighterId);
  }

  static const GameCommand advanceCombatPhase = AdvanceCombatPhaseCommand();
}
