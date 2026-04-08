import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('player rules', () {
    test('clampStat constrains values into the prototype range', () {
      expect(clampStat(-3), 0);
      expect(clampStat(3), 3);
      expect(clampStat(99), 5);
    });

    test('getTotalStats sums all five combat stats', () {
      final Player player = InitialStateFactory.create().players.first.copyWith(
        power: 1,
        stamina: 2,
        agility: 3,
        chi: 4,
        wit: 5,
      );

      expect(getTotalStats(player), 15);
    });

    test('getNextLivingIndex skips defeated players', () {
      final List<Player> players = <Player>[
        const Player(
          id: 'p1',
          name: 'One',
          color: '#000000',
          position: 0,
          power: 1,
          stamina: 1,
          agility: 1,
          chi: 1,
          wit: 1,
          reputation: 3,
          techniques: TechniqueCounts(),
          hitPoints: 3,
          formPoints: 2,
          bonusActionsNextTurn: 0,
          injured: false,
          arrivalOrder: 1,
          alive: true,
        ),
        const Player(
          id: 'p2',
          name: 'Two',
          color: '#111111',
          position: 1,
          power: 1,
          stamina: 1,
          agility: 1,
          chi: 1,
          wit: 1,
          reputation: 3,
          techniques: TechniqueCounts(),
          hitPoints: 3,
          formPoints: 2,
          bonusActionsNextTurn: 0,
          injured: false,
          arrivalOrder: 2,
          alive: false,
        ),
        const Player(
          id: 'p3',
          name: 'Three',
          color: '#222222',
          position: 2,
          power: 1,
          stamina: 1,
          agility: 1,
          chi: 1,
          wit: 1,
          reputation: 3,
          techniques: TechniqueCounts(),
          hitPoints: 3,
          formPoints: 2,
          bonusActionsNextTurn: 0,
          injured: false,
          arrivalOrder: 3,
          alive: true,
        ),
      ];

      expect(getNextLivingIndex(players, 0), 2);
    });
  });
}
