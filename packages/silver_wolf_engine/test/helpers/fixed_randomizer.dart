import 'package:silver_wolf_engine/src/random/randomizer.dart';

class FixedRandomizer implements Randomizer {
  FixedRandomizer(this.values);

  final List<int> values;
  int _index = 0;

  @override
  int nextInt(int max) {
    final int value = values[_index];
    _index += 1;
    if (value < 0 || value >= max) {
      throw StateError(
        'FixedRandomizer value $value is outside the range 0..${max - 1}.',
      );
    }
    return value;
  }
}
