import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';

class AppRandomizer implements Randomizer {
  AppRandomizer({int? seed})
    : _random = seed == null ? math.Random() : math.Random(seed);

  final math.Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}

final appRandomizerProvider = Provider<Randomizer>((Ref ref) {
  return AppRandomizer();
});
