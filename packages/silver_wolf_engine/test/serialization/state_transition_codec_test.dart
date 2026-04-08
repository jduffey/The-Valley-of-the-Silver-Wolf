import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'StateTransitionCodec round-trips transition events and completed schools',
    () {
      const StateTransition transition = StateTransition(
        logEntries: <GameLogEntry>[
          GameLogEntry(
            message:
                'Player 1 saved the Temple of T\'ai Chi Chuan in Leap-Creek!',
            type: 'school_saved',
            metadata: <String, Object?>{
              'schoolId': '#Leap-Creek',
              'defenderIds': <String>['p1', 'p3'],
            },
          ),
          GameLogEntry(
            message:
                'The Silver Wolf has laid siege to the School of Hong Quan in Blackstone.',
            type: 'silver_wolf_school_sieged',
            metadata: <String, Object?>{
              'schoolId': '#Blackstone',
              'whiteDieResult': 5,
            },
          ),
        ],
        completedSchoolIds: <String>['#Leap-Creek'],
      );

      final String encoded = StateTransitionCodec.encode(transition);
      final StateTransition decoded = StateTransitionCodec.decode(encoded);

      expect(
        StateTransitionCodec.toJson(decoded),
        equals(StateTransitionCodec.toJson(transition)),
      );
    },
  );
}
