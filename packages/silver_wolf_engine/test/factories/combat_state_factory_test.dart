import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixed_randomizer.dart';

void main() {
  group('CombatStateFactory', () {
    test('creates hometown combatants with opening hands and keywords', () {
      final GameState state = InitialStateFactory.create();

      final CombatState? combatState = CombatStateFactory.create(
        state.players,
        'p1',
        'p2',
        FixedRandomizer(List<int>.filled(20, 0)),
      );

      expect(combatState, isNotNull);
      expect(combatState!.phase, CombatPhase.selection);
      expect(combatState.clashNumber, 1);

      final CombatantState attacker = combatState.combatants['p1']!;
      final CombatantState defender = combatState.combatants['p2']!;

      expect(attacker.hometownName, 'Leap-Creek');
      expect(attacker.keyword, 'Reversal');
      expect(attacker.hand, hasLength(5));
      expect(attacker.drawPile, hasLength(5));

      expect(defender.hometownName, 'Blackstone');
      expect(defender.keyword, 'Endure');
      expect(defender.hand, hasLength(5));
      expect(defender.drawPile, hasLength(5));
    });
  });
}
