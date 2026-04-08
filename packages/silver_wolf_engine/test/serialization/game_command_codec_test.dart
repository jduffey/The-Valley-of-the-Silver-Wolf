import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('GameCommandCodec round-trips every command shape through JSON', () {
    final List<GameCommand> commands = <GameCommand>[
      GameCommandFactory.openChallenge,
      GameCommandFactory.chooseChallengeTarget('p3'),
      GameCommandFactory.acceptChallenge,
      GameCommandFactory.declineChallenge,
      GameCommandFactory.travelClockwise,
      GameCommandFactory.travelCounterClockwise,
      GameCommandFactory.passTurn,
      GameCommandFactory.healCurrentPlayer,
      GameCommandFactory.saveCurrentSchool,
      GameCommandFactory.challengeSilverWolf,
      GameCommandFactory.undoLastAction,
      GameCommandFactory.clearCompletedSchoolRescue('#Leap-Creek'),
      GameCommandFactory.selectCombatCard('p1', 'card-1'),
      GameCommandFactory.selectCombatMode('p1', CombatMode.swapDefense),
      GameCommandFactory.triggerCombatStumble('p2'),
      GameCommandFactory.advanceCombatPhase,
    ];

    for (final GameCommand command in commands) {
      final Map<String, Object?> json = GameCommandCodec.toJson(command);
      final GameCommand decoded = GameCommandCodec.fromJson(json);

      expect(GameCommandCodec.toJson(decoded), equals(json));
    }
  });

  test('GameCommandCodec round-trips a command through string encoding', () {
    const GameCommand command = SelectCombatModeCommand(
      'p2',
      CombatMode.swapAttack,
    );

    final String encoded = GameCommandCodec.encode(command);
    final GameCommand decoded = GameCommandCodec.decode(encoded);

    expect(
      GameCommandCodec.toJson(decoded),
      equals(GameCommandCodec.toJson(command)),
    );
  });
}
