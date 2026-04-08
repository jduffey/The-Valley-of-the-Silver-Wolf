import 'package:silver_wolf_engine/src/enums/location_type.dart';

class Location {
  const Location({
    required this.id,
    required this.name,
    required this.type,
    required this.hue,
    required this.effect,
  });

  final String id;
  final String name;
  final LocationType type;
  final String hue;
  final String effect;
}
