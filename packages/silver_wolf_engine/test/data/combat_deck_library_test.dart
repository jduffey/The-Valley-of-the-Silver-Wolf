import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('every hometown has a ten-card combat deck', () {
    for (final MapEntry<String, List<CombatCard>> entry
        in combatDeckLibrary.entries) {
      expect(
        entry.value,
        hasLength(10),
        reason: '${entry.key} should have ten combat cards',
      );
    }
  });

  test('special combat card titles match the current prototype canon', () {
    expect(combatDeckLibrary['Leap-Creek']!.last.title, 'Hidden Whirlpool');
    expect(combatDeckLibrary['Fangmarsh']!.last.title, 'Billowing Rush');
    expect(combatDeckLibrary['Blackstone']!.last.title, 'Tempered Veil');
    expect(combatDeckLibrary['Underclaw']!.last.title, 'Smothering Soil');
    expect(combatDeckLibrary['Pouch']!.last.title, 'Splintered Step');
  });
}
