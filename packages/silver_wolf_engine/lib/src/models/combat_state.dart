import 'package:silver_wolf_engine/src/enums/combat_phase.dart';
import 'package:silver_wolf_engine/src/models/combat_resolution_summary.dart';
import 'package:silver_wolf_engine/src/models/combatant_state.dart';

class CombatState {
  static const Object _sentinel = Object();

  const CombatState({
    required this.attackerId,
    required this.defenderId,
    required this.clashNumber,
    required this.phase,
    required this.clashLog,
    required this.combatants,
    required this.resolutionSummary,
  });

  final String attackerId;
  final String defenderId;
  final int clashNumber;
  final CombatPhase phase;
  final List<String> clashLog;
  final Map<String, CombatantState> combatants;
  final CombatResolutionSummary? resolutionSummary;

  CombatState copyWith({
    String? attackerId,
    String? defenderId,
    int? clashNumber,
    CombatPhase? phase,
    List<String>? clashLog,
    Map<String, CombatantState>? combatants,
    Object? resolutionSummary = _sentinel,
  }) {
    return CombatState(
      attackerId: attackerId ?? this.attackerId,
      defenderId: defenderId ?? this.defenderId,
      clashNumber: clashNumber ?? this.clashNumber,
      phase: phase ?? this.phase,
      clashLog: clashLog ?? this.clashLog,
      combatants: combatants ?? this.combatants,
      resolutionSummary: resolutionSummary == _sentinel
          ? this.resolutionSummary
          : resolutionSummary as CombatResolutionSummary?,
    );
  }
}
