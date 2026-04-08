import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixed_randomizer.dart';

void main() {
  group('non-combat reducer flow', () {
    test('travel moves clockwise and creates an undo snapshot', () {
      final GameState state = InitialStateFactory.create();

      final CommandResult result = GameReducer.reduce(
        state,
        const TravelClockwiseCommand(),
        FixedRandomizer(<int>[1]),
      );

      expect(result.state.players.first.position, 1);
      expect(result.state.actionsRemaining, 1);
      expect(result.state.nextArrivalOrder, 6);
      expect(result.state.undoSnapshot, isNotNull);
    });

    test('travel counter-clockwise wraps around the board', () {
      final GameState state = InitialStateFactory.create();

      final CommandResult result = GameReducer.reduce(
        state,
        const TravelCounterClockwiseCommand(),
        FixedRandomizer(<int>[1]),
      );

      expect(result.state.players.first.position, 9);
    });

    test('travel ends the turn when it spends the final action', () {
      final GameState state = InitialStateFactory.create().copyWith(
        actionsRemaining: 1,
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const TravelClockwiseCommand(),
        FixedRandomizer(<int>[5, 0]),
      );

      expect(result.state.currentPlayerIndex, 1);
      expect(result.state.actionsRemaining, 2);
      expect(result.state.players.first.position, 1);
    });

    test('heal only works for an injured player in a town', () {
      final GameState state = InitialStateFactory.create().copyWith(
        players: <Player>[
          InitialStateFactory.create().players.first.copyWith(injured: true),
          ...InitialStateFactory.create().players.skip(1),
        ],
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const HealCurrentPlayerCommand(),
        FixedRandomizer(<int>[1]),
      );

      expect(result.state.players.first.injured, isFalse);
      expect(result.state.actionsRemaining, 1);
      expect(
        result.transition.logEntries.single.message,
        contains('heals at Leap-Creek'),
      );
    });

    test('heal is ignored when the player is not eligible', () {
      final GameState state = InitialStateFactory.create();

      final CommandResult result = GameReducer.reduce(
        state,
        const HealCurrentPlayerCommand(),
        FixedRandomizer(<int>[1]),
      );

      expect(result.state.players.first.injured, isFalse);
      expect(result.state.actionsRemaining, 2);
      expect(result.transition.logEntries, isEmpty);
    });

    test(
      'save school progresses and completion marks the school as completing',
      () {
        final List<School> schools = InitialStateFactory.create().schools;
        final GameState state = InitialStateFactory.create().copyWith(
          schools: <School>[
            schools.first.copyWith(
              status: SchoolStatus.sieged,
              saveProgress: 2,
            ),
            ...schools.skip(1),
          ],
        );

        final CommandResult result = GameReducer.reduce(
          state,
          const SaveCurrentSchoolCommand(),
          FixedRandomizer(<int>[1]),
        );

        final School school = result.state.schools.first;
        expect(school.status, SchoolStatus.whole);
        expect(school.saveProgress, 3);
        expect(school.isCompletingSave, isTrue);
        expect(result.state.players.first.reputation, 4);
        expect(result.transition.completedSchoolIds, <String>['#Leap-Creek']);
      },
    );

    test('pass turn skips dead players', () {
      final List<Player> players = InitialStateFactory.create().players;
      final GameState state = InitialStateFactory.create().copyWith(
        players: <Player>[
          players[0],
          players[1].copyWith(alive: false),
          players[2],
          players[3],
          players[4],
        ],
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const PassTurnCommand(),
        FixedRandomizer(<int>[5, 0]),
      );

      expect(result.state.currentPlayerIndex, 2);
    });

    test(
      'silver wolf destruction lowers reputation and injures players at the destroyed school',
      () {
        final List<Player> players = InitialStateFactory.create().players;
        final List<School> schools = InitialStateFactory.create().schools;
        final GameState state = InitialStateFactory.create().copyWith(
          schools: <School>[
            schools.first.copyWith(status: SchoolStatus.sieged),
            ...schools.skip(1),
          ],
          players: <Player>[
            players.first.copyWith(position: 0),
            ...players.skip(1),
          ],
        );

        final CommandResult result = GameReducer.reduce(
          state,
          const PassTurnCommand(),
          FixedRandomizer(<int>[0, 0]),
        );

        expect(result.state.schools.first.status, SchoolStatus.destroyed);
        expect(result.state.players.first.reputation, 2);
        expect(result.state.players.first.injured, isTrue);
        expect(
          result.transition.logEntries
              .map((GameLogEntry entry) => entry.message)
              .join(' '),
          contains('The Silver Wolf has destroyed'),
        );
      },
    );

    test('challengeing the silver wolf can produce a win state', () {
      final List<Player> players = InitialStateFactory.create().players;
      final GameState state = InitialStateFactory.create().copyWith(
        players: <Player>[
          players.first.copyWith(
            power: 5,
            stamina: 5,
            agility: 5,
            chi: 5,
            wit: 5,
          ),
          ...players.skip(1),
        ],
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const ChallengeSilverWolfCommand(),
        FixedRandomizer(<int>[0, 0]),
      );

      expect(result.state.winnerId, 'p1');
      expect(result.state.actionsRemaining, 0);
    });

    test(
      'challenging the silver wolf can kill the challenger and leave the turn in progress',
      () {
        final List<Player> players = InitialStateFactory.create().players;
        final GameState state = InitialStateFactory.create().copyWith(
          players: <Player>[
            players.first.copyWith(
              power: 5,
              stamina: 5,
              agility: 5,
              chi: 0,
              wit: 0,
            ),
            ...players.skip(1),
          ],
        );

        final CommandResult result = GameReducer.reduce(
          state,
          const ChallengeSilverWolfCommand(),
          FixedRandomizer(<int>[5, 0, 5]),
        );

        expect(result.state.players.first.alive, isFalse);
        expect(result.state.currentPlayerIndex, 0);
        expect(result.state.actionsRemaining, 1);
      },
    );

    test('undo restores the previous snapshot', () {
      final GameState initialState = InitialStateFactory.create();
      final CommandResult traveledState = GameReducer.reduce(
        initialState,
        const TravelClockwiseCommand(),
        FixedRandomizer(<int>[5, 0]),
      );
      final CommandResult undoneState = GameReducer.reduce(
        traveledState.state,
        const UndoLastActionCommand(),
        FixedRandomizer(<int>[5]),
      );

      expect(
        undoneState.state.players.first.position,
        initialState.players.first.position,
      );
      expect(undoneState.state.actionsRemaining, initialState.actionsRemaining);
      expect(undoneState.state.nextArrivalOrder, initialState.nextArrivalOrder);
      expect(undoneState.state.undoSnapshot, isNull);
    });
  });
}
