import 'dart:convert';

import 'package:silver_wolf_engine/src/results/state_transition.dart';
import 'package:silver_wolf_engine/src/serialization/game_state_codec.dart';

class StateTransitionCodec {
  const StateTransitionCodec._();

  static const int schemaVersion = 1;

  static String encode(StateTransition transition) {
    return jsonEncode(toJson(transition));
  }

  static StateTransition decode(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException(
        'Expected a JSON object for a StateTransition.',
      );
    }

    return fromJson(
      decoded.map(
        (Object? key, Object? value) =>
            MapEntry<String, Object?>(key as String, value),
      ),
    );
  }

  static Map<String, Object?> toJson(StateTransition transition) {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'logEntries': transition.logEntries
          .map(GameStateCodec.encodeLogEntry)
          .toList(growable: false),
      'completedSchoolIds': List<String>.from(transition.completedSchoolIds),
    };
  }

  static StateTransition fromJson(Map<String, Object?> json) {
    final int version = (json['schemaVersion'] as int?) ?? schemaVersion;
    if (version != schemaVersion) {
      throw FormatException(
        'Unsupported StateTransition schemaVersion: $version.',
      );
    }

    final List<Object?> logEntries = _asList(
      json['logEntries'],
      fieldName: 'logEntries',
    );
    final List<Object?> completedSchoolIds = _asList(
      json['completedSchoolIds'],
      fieldName: 'completedSchoolIds',
    );

    return StateTransition(
      logEntries: logEntries
          .map((Object? entry) => GameStateCodec.decodeLogEntry(_asMap(entry)))
          .toList(growable: false),
      completedSchoolIds: completedSchoolIds
          .map((Object? value) {
            if (value is! String) {
              throw const FormatException(
                'Expected a string in "completedSchoolIds".',
              );
            }
            return value;
          })
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _asMap(
    Object? value, {
    String fieldName = 'value',
  }) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (Object? key, Object? nestedValue) =>
            MapEntry<String, Object?>(key as String, nestedValue),
      );
    }
    throw FormatException('Expected "$fieldName" to be a JSON object.');
  }

  static List<Object?> _asList(Object? value, {required String fieldName}) {
    if (value is List<Object?>) {
      return value;
    }
    if (value is List) {
      return List<Object?>.from(value);
    }
    throw FormatException('Expected "$fieldName" to be a JSON array.');
  }
}
