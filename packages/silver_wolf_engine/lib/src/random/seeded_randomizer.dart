import 'dart:math';

import 'package:silver_wolf_engine/src/random/randomizer.dart';

class SeededRandomizer implements Randomizer {
  SeededRandomizer([int? seed])
    : _random = seed == null ? Random() : Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}
