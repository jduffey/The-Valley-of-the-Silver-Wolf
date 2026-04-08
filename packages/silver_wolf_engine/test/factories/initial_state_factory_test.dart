import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

void main() {
  group('InitialStateFactory', () {
    final GameState state = InitialStateFactory.create();

    test('creates the expected player count and starting turn', () {
      expect(state.players, hasLength(5));
      expect(state.currentPlayerIndex, 0);
      expect(state.actionsRemaining, 2);
      expect(state.currentTurnBonusActionsRemaining, 0);
      expect(state.nextArrivalOrder, 5);
    });

    test('creates the expected starting player identities and positions', () {
      expect(state.players.map((Player player) => player.id), <String>[
        'p1',
        'p2',
        'p3',
        'p4',
        'p5',
      ]);
      expect(state.players.map((Player player) => player.position), <int>[
        0,
        2,
        4,
        6,
        8,
      ]);
      expect(state.players.map((Player player) => player.name), <String>[
        'Leap-Creek',
        'Blackstone',
        'Fangmarsh',
        'Underclaw',
        'Pouch',
      ]);
    });

    test('creates the expected starting player stats', () {
      final Player leapCreek = state.players[0];
      final Player blackstone = state.players[1];
      final Player fangmarsh = state.players[2];
      final Player underclaw = state.players[3];
      final Player pouch = state.players[4];

      expect(
        (
          leapCreek.power,
          leapCreek.stamina,
          leapCreek.agility,
          leapCreek.chi,
          leapCreek.wit,
        ),
        (0, 0, 1, 2, 0),
      );
      expect(
        (
          blackstone.power,
          blackstone.stamina,
          blackstone.agility,
          blackstone.chi,
          blackstone.wit,
        ),
        (1, 2, 0, 0, 0),
      );
      expect(
        (
          fangmarsh.power,
          fangmarsh.stamina,
          fangmarsh.agility,
          fangmarsh.chi,
          fangmarsh.wit,
        ),
        (2, 0, 0, 0, 1),
      );
      expect(
        (
          underclaw.power,
          underclaw.stamina,
          underclaw.agility,
          underclaw.chi,
          underclaw.wit,
        ),
        (0, 0, 2, 1, 0),
      );
      expect(
        (pouch.power, pouch.stamina, pouch.agility, pouch.chi, pouch.wit),
        (0, 1, 0, 0, 2),
      );
    });

    test('creates players with the expected shared starting resources', () {
      for (final Player player in state.players) {
        expect(player.reputation, initialReputation);
        expect(player.hitPoints, initialHitPoints);
        expect(player.formPoints, initialFormPoints);
        expect(player.bonusActionsNextTurn, 0);
        expect(player.injured, isFalse);
        expect(player.alive, isTrue);
        expect(
          (
            player.techniques.black,
            player.techniques.brown,
            player.techniques.gold,
          ),
          (0, 0, 0),
        );
      }
    });

    test('creates one whole school for each town on the track', () {
      expect(state.schools, hasLength(5));
      expect(state.schools.map((School school) => school.id), <String>[
        '#Leap-Creek',
        '#Blackstone',
        '#Fangmarsh',
        '#Underclaw',
        '#Pouch',
      ]);

      for (final School school in state.schools) {
        expect(school.status, SchoolStatus.whole);
        expect(school.saveProgress, 0);
        expect(school.isCompletingSave, isFalse);
        expect(school.defenders, isEmpty);
      }
    });

    test('creates an empty event log and no open encounters', () {
      expect(state.eventLog, isEmpty);
      expect(state.pendingRoll, isNull);
      expect(state.winnerId, isNull);
      expect(state.gameOverReason, isNull);
      expect(state.challengeState, isNull);
      expect(state.combatState, isNull);
      expect(state.undoSnapshot, isNull);
    });
  });
}
