import 'dart:convert';

import 'package:silver_wolf_engine/src/enums/combat_lane.dart';
import 'package:silver_wolf_engine/src/enums/combat_mode.dart';
import 'package:silver_wolf_engine/src/enums/combat_phase.dart';
import 'package:silver_wolf_engine/src/enums/location_type.dart';
import 'package:silver_wolf_engine/src/enums/school_status.dart';
import 'package:silver_wolf_engine/src/models/challenge_state.dart';
import 'package:silver_wolf_engine/src/models/combat_card.dart';
import 'package:silver_wolf_engine/src/models/combat_resolution_summary.dart';
import 'package:silver_wolf_engine/src/models/combat_state.dart';
import 'package:silver_wolf_engine/src/models/combatant_state.dart';
import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/game_state.dart';
import 'package:silver_wolf_engine/src/models/location.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/models/school.dart';
import 'package:silver_wolf_engine/src/models/technique_counts.dart';
import 'package:silver_wolf_engine/src/models/undo_snapshot.dart';

class GameStateCodec {
  const GameStateCodec._();

  static const int schemaVersion = 1;

  static String encode(GameState state) => jsonEncode(toJson(state));

  static GameState decode(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Expected a JSON object for a GameState.');
    }

    return fromJson(
      decoded.map(
        (Object? key, Object? value) =>
            MapEntry<String, Object?>(key as String, value),
      ),
    );
  }

  static Map<String, Object?> toJson(GameState state) {
    final List<MapEntry<String, Object?>> combatants = state.combatState == null
        ? const <MapEntry<String, Object?>>[]
        : (state.combatState!.combatants.entries.toList(growable: false)
                ..sort((left, right) => left.key.compareTo(right.key)))
              .map(
                (MapEntry<String, CombatantState> entry) =>
                    MapEntry<String, Object?>(
                      entry.key,
                      _combatantToJson(entry.value),
                    ),
              )
              .toList(growable: false);

    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'players': state.players.map(_playerToJson).toList(growable: false),
      'schools': state.schools.map(_schoolToJson).toList(growable: false),
      'currentPlayerIndex': state.currentPlayerIndex,
      'actionsRemaining': state.actionsRemaining,
      'currentTurnBonusActionsRemaining':
          state.currentTurnBonusActionsRemaining,
      'nextArrivalOrder': state.nextArrivalOrder,
      'pendingRoll': state.pendingRoll,
      'eventLog': state.eventLog.map(encodeLogEntry).toList(growable: false),
      'winnerId': state.winnerId,
      'gameOverReason': state.gameOverReason,
      'challengeState': state.challengeState == null
          ? null
          : _challengeStateToJson(state.challengeState!),
      'combatState': state.combatState == null
          ? null
          : <String, Object?>{
              'attackerId': state.combatState!.attackerId,
              'defenderId': state.combatState!.defenderId,
              'clashNumber': state.combatState!.clashNumber,
              'phase': state.combatState!.phase.name,
              'clashLog': List<String>.from(state.combatState!.clashLog),
              'combatants': Map<String, Object?>.fromEntries(combatants),
              'resolutionSummary': state.combatState!.resolutionSummary == null
                  ? null
                  : _combatResolutionSummaryToJson(
                      state.combatState!.resolutionSummary!,
                    ),
            },
      'undoSnapshot': state.undoSnapshot == null
          ? null
          : _undoSnapshotToJson(state.undoSnapshot!),
    };
  }

  static GameState fromJson(Map<String, Object?> json) {
    _validateSchema(json);

    return GameState(
      players: _asList(json['players'], fieldName: 'players')
          .map((Object? value) => _playerFromJson(_asMap(value)))
          .toList(growable: false),
      schools: _asList(json['schools'], fieldName: 'schools')
          .map((Object? value) => _schoolFromJson(_asMap(value)))
          .toList(growable: false),
      currentPlayerIndex: _asInt(
        json['currentPlayerIndex'],
        fieldName: 'currentPlayerIndex',
      ),
      actionsRemaining: _asInt(
        json['actionsRemaining'],
        fieldName: 'actionsRemaining',
      ),
      currentTurnBonusActionsRemaining: _asInt(
        json['currentTurnBonusActionsRemaining'],
        fieldName: 'currentTurnBonusActionsRemaining',
      ),
      nextArrivalOrder: _asInt(
        json['nextArrivalOrder'],
        fieldName: 'nextArrivalOrder',
      ),
      pendingRoll: _asNullableInt(json['pendingRoll']),
      eventLog: _asList(json['eventLog'], fieldName: 'eventLog')
          .map((Object? value) => decodeLogEntry(_asMap(value)))
          .toList(growable: false),
      winnerId: _asNullableString(json['winnerId']),
      gameOverReason: _asNullableString(json['gameOverReason']),
      challengeState: json['challengeState'] == null
          ? null
          : _challengeStateFromJson(_asMap(json['challengeState'])),
      combatState: json['combatState'] == null
          ? null
          : _combatStateFromJson(_asMap(json['combatState'])),
      undoSnapshot: json['undoSnapshot'] == null
          ? null
          : _undoSnapshotFromJson(_asMap(json['undoSnapshot'])),
    );
  }

  static Map<String, Object?> encodeLogEntry(GameLogEntry entry) {
    return <String, Object?>{
      'message': entry.message,
      'type': entry.type,
      'metadata': entry.metadata.map(
        (String key, Object? value) =>
            MapEntry<String, Object?>(key, _cloneJsonValue(value)),
      ),
    };
  }

  static GameLogEntry decodeLogEntry(Map<String, Object?> json) {
    return GameLogEntry(
      message: _asString(json['message'], fieldName: 'message'),
      type: _asString(json['type'] ?? 'info', fieldName: 'type'),
      metadata: json['metadata'] == null
          ? const <String, Object?>{}
          : _asMap(json['metadata']).map(
              (String key, Object? value) =>
                  MapEntry<String, Object?>(key, _cloneJsonValue(value)),
            ),
    );
  }

  static Map<String, Object?> _playerToJson(Player player) {
    return <String, Object?>{
      'id': player.id,
      'name': player.name,
      'color': player.color,
      'position': player.position,
      'power': player.power,
      'stamina': player.stamina,
      'agility': player.agility,
      'chi': player.chi,
      'wit': player.wit,
      'reputation': player.reputation,
      'techniques': _techniqueCountsToJson(player.techniques),
      'hitPoints': player.hitPoints,
      'formPoints': player.formPoints,
      'bonusActionsNextTurn': player.bonusActionsNextTurn,
      'injured': player.injured,
      'arrivalOrder': player.arrivalOrder,
      'alive': player.alive,
    };
  }

  static Player _playerFromJson(Map<String, Object?> json) {
    return Player(
      id: _asString(json['id'], fieldName: 'id'),
      name: _asString(json['name'], fieldName: 'name'),
      color: _asString(json['color'], fieldName: 'color'),
      position: _asInt(json['position'], fieldName: 'position'),
      power: _asInt(json['power'], fieldName: 'power'),
      stamina: _asInt(json['stamina'], fieldName: 'stamina'),
      agility: _asInt(json['agility'], fieldName: 'agility'),
      chi: _asInt(json['chi'], fieldName: 'chi'),
      wit: _asInt(json['wit'], fieldName: 'wit'),
      reputation: _asInt(json['reputation'], fieldName: 'reputation'),
      techniques: _techniqueCountsFromJson(
        _asMap(json['techniques'], fieldName: 'techniques'),
      ),
      hitPoints: _asInt(json['hitPoints'], fieldName: 'hitPoints'),
      formPoints: _asInt(json['formPoints'], fieldName: 'formPoints'),
      bonusActionsNextTurn: _asInt(
        json['bonusActionsNextTurn'],
        fieldName: 'bonusActionsNextTurn',
      ),
      injured: _asBool(json['injured'], fieldName: 'injured'),
      arrivalOrder: _asInt(json['arrivalOrder'], fieldName: 'arrivalOrder'),
      alive: _asBool(json['alive'], fieldName: 'alive'),
    );
  }

  static Map<String, Object?> _schoolToJson(School school) {
    return <String, Object?>{
      'id': school.id,
      'name': school.name,
      'status': school.status.name,
      'saveProgress': school.saveProgress,
      'isCompletingSave': school.isCompletingSave,
      'defenders': List<String>.from(school.defenders),
    };
  }

  static School _schoolFromJson(Map<String, Object?> json) {
    return School(
      id: _asString(json['id'], fieldName: 'id'),
      name: _asString(json['name'], fieldName: 'name'),
      status: SchoolStatus.values.byName(
        _asString(json['status'], fieldName: 'status'),
      ),
      saveProgress: _asInt(json['saveProgress'], fieldName: 'saveProgress'),
      isCompletingSave: _asBool(
        json['isCompletingSave'],
        fieldName: 'isCompletingSave',
      ),
      defenders: _asList(json['defenders'], fieldName: 'defenders')
          .map((Object? value) => _asString(value, fieldName: 'defenderId'))
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _challengeStateToJson(ChallengeState challenge) {
    return <String, Object?>{
      'challengerId': challenge.challengerId,
      'opponentIds': List<String>.from(challenge.opponentIds),
      'targetId': challenge.targetId,
    };
  }

  static ChallengeState _challengeStateFromJson(Map<String, Object?> json) {
    return ChallengeState(
      challengerId: _asString(json['challengerId'], fieldName: 'challengerId'),
      opponentIds: _asList(json['opponentIds'], fieldName: 'opponentIds')
          .map((Object? value) => _asString(value, fieldName: 'opponentId'))
          .toList(growable: false),
      targetId: _asNullableString(json['targetId']),
    );
  }

  static CombatState _combatStateFromJson(Map<String, Object?> json) {
    final Map<String, Object?> combatantsJson = _asMap(
      json['combatants'],
      fieldName: 'combatants',
    );

    return CombatState(
      attackerId: _asString(json['attackerId'], fieldName: 'attackerId'),
      defenderId: _asString(json['defenderId'], fieldName: 'defenderId'),
      clashNumber: _asInt(json['clashNumber'], fieldName: 'clashNumber'),
      phase: CombatPhase.values.byName(
        _asString(json['phase'], fieldName: 'phase'),
      ),
      clashLog: _asList(json['clashLog'], fieldName: 'clashLog')
          .map((Object? value) => _asString(value, fieldName: 'clashLogItem'))
          .toList(growable: false),
      combatants: combatantsJson.map(
        (String key, Object? value) => MapEntry<String, CombatantState>(
          key,
          _combatantFromJson(_asMap(value)),
        ),
      ),
      resolutionSummary: json['resolutionSummary'] == null
          ? null
          : _combatResolutionSummaryFromJson(_asMap(json['resolutionSummary'])),
    );
  }

  static Map<String, Object?> _combatantToJson(CombatantState combatant) {
    return <String, Object?>{
      'id': combatant.id,
      'name': combatant.name,
      'displayName': combatant.displayName,
      'hometownName': combatant.hometownName,
      'keyword': combatant.keyword,
      'maxHitPoints': combatant.maxHitPoints,
      'currentHitPoints': combatant.currentHitPoints,
      'maxFormPoints': combatant.maxFormPoints,
      'currentFormPoints': combatant.currentFormPoints,
      'drawPile': combatant.drawPile
          .map(_combatCardToJson)
          .toList(growable: false),
      'hand': combatant.hand.map(_combatCardToJson).toList(growable: false),
      'discard': combatant.discard
          .map(_combatCardToJson)
          .toList(growable: false),
      'selectedCardId': combatant.selectedCardId,
      'selectedMode': combatant.selectedMode?.name,
      'effectiveCardId': combatant.effectiveCardId,
      'stumbleTriggered': combatant.stumbleTriggered,
      'reactionLocked': combatant.reactionLocked,
    };
  }

  static CombatantState _combatantFromJson(Map<String, Object?> json) {
    return CombatantState(
      id: _asString(json['id'], fieldName: 'id'),
      name: _asString(json['name'], fieldName: 'name'),
      displayName: _asString(json['displayName'], fieldName: 'displayName'),
      hometownName: _asString(json['hometownName'], fieldName: 'hometownName'),
      keyword: _asString(json['keyword'], fieldName: 'keyword'),
      maxHitPoints: _asInt(json['maxHitPoints'], fieldName: 'maxHitPoints'),
      currentHitPoints: _asInt(
        json['currentHitPoints'],
        fieldName: 'currentHitPoints',
      ),
      maxFormPoints: _asInt(json['maxFormPoints'], fieldName: 'maxFormPoints'),
      currentFormPoints: _asInt(
        json['currentFormPoints'],
        fieldName: 'currentFormPoints',
      ),
      drawPile: _asList(json['drawPile'], fieldName: 'drawPile')
          .map((Object? value) => _combatCardFromJson(_asMap(value)))
          .toList(growable: false),
      hand: _asList(json['hand'], fieldName: 'hand')
          .map((Object? value) => _combatCardFromJson(_asMap(value)))
          .toList(growable: false),
      discard: _asList(json['discard'], fieldName: 'discard')
          .map((Object? value) => _combatCardFromJson(_asMap(value)))
          .toList(growable: false),
      selectedCardId: _asNullableString(json['selectedCardId']),
      selectedMode: _asNullableString(json['selectedMode']) == null
          ? null
          : CombatMode.values.byName(
              _asString(json['selectedMode'], fieldName: 'selectedMode'),
            ),
      effectiveCardId: _asNullableString(json['effectiveCardId']),
      stumbleTriggered: _asBool(
        json['stumbleTriggered'],
        fieldName: 'stumbleTriggered',
      ),
      reactionLocked: _asBool(
        json['reactionLocked'],
        fieldName: 'reactionLocked',
      ),
    );
  }

  static Map<String, Object?> _combatCardToJson(CombatCard card) {
    return <String, Object?>{
      'id': card.id,
      'attack': card.attack.name,
      'defense': card.defense.name,
      'swapLane': card.swapLane.name,
      'isSpecial': card.isSpecial,
      'title': card.title,
    };
  }

  static CombatCard _combatCardFromJson(Map<String, Object?> json) {
    return CombatCard(
      id: _asString(json['id'], fieldName: 'id'),
      attack: CombatLane.values.byName(
        _asString(json['attack'], fieldName: 'attack'),
      ),
      defense: CombatLane.values.byName(
        _asString(json['defense'], fieldName: 'defense'),
      ),
      swapLane: CombatLane.values.byName(
        _asString(json['swapLane'], fieldName: 'swapLane'),
      ),
      isSpecial: _asBool(json['isSpecial'], fieldName: 'isSpecial'),
      title: _asString(json['title'], fieldName: 'title'),
    );
  }

  static Map<String, Object?> _combatResolutionSummaryToJson(
    CombatResolutionSummary summary,
  ) {
    return <String, Object?>{
      'leftSummary': summary.leftSummary,
      'rightSummary': summary.rightSummary,
    };
  }

  static CombatResolutionSummary _combatResolutionSummaryFromJson(
    Map<String, Object?> json,
  ) {
    return CombatResolutionSummary(
      leftSummary: _asString(json['leftSummary'], fieldName: 'leftSummary'),
      rightSummary: _asString(json['rightSummary'], fieldName: 'rightSummary'),
    );
  }

  static Map<String, Object?> _undoSnapshotToJson(UndoSnapshot snapshot) {
    return <String, Object?>{
      'playerId': snapshot.playerId,
      'players': snapshot.players.map(_playerToJson).toList(growable: false),
      'schools': snapshot.schools.map(_schoolToJson).toList(growable: false),
      'actionsRemaining': snapshot.actionsRemaining,
      'currentTurnBonusActionsRemaining':
          snapshot.currentTurnBonusActionsRemaining,
      'nextArrivalOrder': snapshot.nextArrivalOrder,
      'eventLog': snapshot.eventLog.map(encodeLogEntry).toList(growable: false),
      'pendingRoll': snapshot.pendingRoll,
    };
  }

  static UndoSnapshot _undoSnapshotFromJson(Map<String, Object?> json) {
    return UndoSnapshot(
      playerId: _asString(json['playerId'], fieldName: 'playerId'),
      players: _asList(json['players'], fieldName: 'players')
          .map((Object? value) => _playerFromJson(_asMap(value)))
          .toList(growable: false),
      schools: _asList(json['schools'], fieldName: 'schools')
          .map((Object? value) => _schoolFromJson(_asMap(value)))
          .toList(growable: false),
      actionsRemaining: _asInt(
        json['actionsRemaining'],
        fieldName: 'actionsRemaining',
      ),
      currentTurnBonusActionsRemaining: _asInt(
        json['currentTurnBonusActionsRemaining'],
        fieldName: 'currentTurnBonusActionsRemaining',
      ),
      nextArrivalOrder: _asInt(
        json['nextArrivalOrder'],
        fieldName: 'nextArrivalOrder',
      ),
      eventLog: _asList(json['eventLog'], fieldName: 'eventLog')
          .map((Object? value) => decodeLogEntry(_asMap(value)))
          .toList(growable: false),
      pendingRoll: _asNullableInt(json['pendingRoll']),
    );
  }

  static Map<String, Object?> _techniqueCountsToJson(TechniqueCounts counts) {
    return <String, Object?>{
      'black': counts.black,
      'brown': counts.brown,
      'gold': counts.gold,
    };
  }

  static TechniqueCounts _techniqueCountsFromJson(Map<String, Object?> json) {
    return TechniqueCounts(
      black: _asInt(json['black'], fieldName: 'black'),
      brown: _asInt(json['brown'], fieldName: 'brown'),
      gold: _asInt(json['gold'], fieldName: 'gold'),
    );
  }

  static Map<String, Object?> encodeLocation(Location location) {
    return <String, Object?>{
      'id': location.id,
      'name': location.name,
      'type': location.type.name,
      'hue': location.hue,
      'effect': location.effect,
    };
  }

  static Location decodeLocation(Map<String, Object?> json) {
    return Location(
      id: _asString(json['id'], fieldName: 'id'),
      name: _asString(json['name'], fieldName: 'name'),
      type: LocationType.values.byName(
        _asString(json['type'], fieldName: 'type'),
      ),
      hue: _asString(json['hue'], fieldName: 'hue'),
      effect: _asString(json['effect'], fieldName: 'effect'),
    );
  }

  static void _validateSchema(Map<String, Object?> json) {
    final int version = (json['schemaVersion'] as int?) ?? schemaVersion;
    if (version != schemaVersion) {
      throw FormatException('Unsupported GameState schemaVersion: $version.');
    }
  }

  static Object? _cloneJsonValue(Object? value) {
    if (value is List<Object?>) {
      return value.map(_cloneJsonValue).toList(growable: false);
    }
    if (value is List) {
      return value.map(_cloneJsonValue).toList(growable: false);
    }
    if (value is Map<String, Object?>) {
      return value.map(
        (String key, Object? nestedValue) =>
            MapEntry<String, Object?>(key, _cloneJsonValue(nestedValue)),
      );
    }
    if (value is Map) {
      return value.map(
        (Object? key, Object? nestedValue) => MapEntry<String, Object?>(
          key as String,
          _cloneJsonValue(nestedValue),
        ),
      );
    }
    return value;
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

  static int _asInt(Object? value, {required String fieldName}) {
    if (value is! int) {
      throw FormatException('Expected "$fieldName" to be an int.');
    }
    return value;
  }

  static int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! int) {
      throw const FormatException('Expected a nullable int value.');
    }
    return value;
  }

  static bool _asBool(Object? value, {required String fieldName}) {
    if (value is! bool) {
      throw FormatException('Expected "$fieldName" to be a bool.');
    }
    return value;
  }

  static String _asString(Object? value, {required String fieldName}) {
    if (value is! String) {
      throw FormatException('Expected "$fieldName" to be a string.');
    }
    return value;
  }

  static String? _asNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw const FormatException('Expected a nullable string value.');
    }
    return value;
  }
}
