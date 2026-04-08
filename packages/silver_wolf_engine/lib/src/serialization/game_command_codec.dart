import 'dart:convert';

import 'package:silver_wolf_engine/src/commands/game_command.dart';
import 'package:silver_wolf_engine/src/enums/combat_mode.dart';

class GameCommandCodec {
  const GameCommandCodec._();

  static const int schemaVersion = 1;

  static String encode(GameCommand command) => jsonEncode(toJson(command));

  static GameCommand decode(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Expected a JSON object for a GameCommand.');
    }

    return fromJson(
      decoded.map(
        (Object? key, Object? value) =>
            MapEntry<String, Object?>(key as String, value),
      ),
    );
  }

  static Map<String, Object?> toJson(GameCommand command) {
    return switch (command) {
      OpenChallengeCommand() => _baseJson('open_challenge'),
      ChooseChallengeTargetCommand(:final targetId) => <String, Object?>{
        ..._baseJson('choose_challenge_target'),
        'targetId': targetId,
      },
      AcceptChallengeCommand() => _baseJson('accept_challenge'),
      DeclineChallengeCommand() => _baseJson('decline_challenge'),
      TravelClockwiseCommand() => _baseJson('travel_clockwise'),
      TravelCounterClockwiseCommand() => _baseJson('travel_counter_clockwise'),
      PassTurnCommand() => _baseJson('pass_turn'),
      HealCurrentPlayerCommand() => _baseJson('heal_current_player'),
      SaveCurrentSchoolCommand() => _baseJson('save_current_school'),
      ChallengeSilverWolfCommand() => _baseJson('challenge_silver_wolf'),
      UndoLastActionCommand() => _baseJson('undo_last_action'),
      ClearCompletedSchoolRescueCommand(:final schoolId) => <String, Object?>{
        ..._baseJson('clear_completed_school_rescue'),
        'schoolId': schoolId,
      },
      SelectCombatCardCommand(:final fighterId, :final cardId) =>
        <String, Object?>{
          ..._baseJson('select_combat_card'),
          'fighterId': fighterId,
          'cardId': cardId,
        },
      SelectCombatModeCommand(:final fighterId, :final mode) =>
        <String, Object?>{
          ..._baseJson('select_combat_mode'),
          'fighterId': fighterId,
          'mode': mode.name,
        },
      TriggerCombatStumbleCommand(:final fighterId) => <String, Object?>{
        ..._baseJson('trigger_combat_stumble'),
        'fighterId': fighterId,
      },
      AdvanceCombatPhaseCommand() => _baseJson('advance_combat_phase'),
    };
  }

  static GameCommand fromJson(Map<String, Object?> json) {
    _validateSchema(json);
    final String type = _asString(json['type'], fieldName: 'type');

    return switch (type) {
      'open_challenge' => const OpenChallengeCommand(),
      'choose_challenge_target' => ChooseChallengeTargetCommand(
        _asString(json['targetId'], fieldName: 'targetId'),
      ),
      'accept_challenge' => const AcceptChallengeCommand(),
      'decline_challenge' => const DeclineChallengeCommand(),
      'travel_clockwise' => const TravelClockwiseCommand(),
      'travel_counter_clockwise' => const TravelCounterClockwiseCommand(),
      'pass_turn' => const PassTurnCommand(),
      'heal_current_player' => const HealCurrentPlayerCommand(),
      'save_current_school' => const SaveCurrentSchoolCommand(),
      'challenge_silver_wolf' => const ChallengeSilverWolfCommand(),
      'undo_last_action' => const UndoLastActionCommand(),
      'clear_completed_school_rescue' => ClearCompletedSchoolRescueCommand(
        _asString(json['schoolId'], fieldName: 'schoolId'),
      ),
      'select_combat_card' => SelectCombatCardCommand(
        _asString(json['fighterId'], fieldName: 'fighterId'),
        _asString(json['cardId'], fieldName: 'cardId'),
      ),
      'select_combat_mode' => SelectCombatModeCommand(
        _asString(json['fighterId'], fieldName: 'fighterId'),
        CombatMode.values.byName(_asString(json['mode'], fieldName: 'mode')),
      ),
      'trigger_combat_stumble' => TriggerCombatStumbleCommand(
        _asString(json['fighterId'], fieldName: 'fighterId'),
      ),
      'advance_combat_phase' => const AdvanceCombatPhaseCommand(),
      _ => throw FormatException('Unknown GameCommand type: $type'),
    };
  }

  static Map<String, Object?> _baseJson(String type) {
    return <String, Object?>{'schemaVersion': schemaVersion, 'type': type};
  }

  static void _validateSchema(Map<String, Object?> json) {
    final int version = (json['schemaVersion'] as int?) ?? schemaVersion;
    if (version != schemaVersion) {
      throw FormatException('Unsupported GameCommand schemaVersion: $version.');
    }
  }

  static String _asString(Object? value, {required String fieldName}) {
    if (value is! String) {
      throw FormatException('Expected "$fieldName" to be a string.');
    }
    return value;
  }
}
