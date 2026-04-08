import 'package:silver_wolf_engine/src/enums/combat_mode.dart';
import 'package:silver_wolf_engine/src/models/combat_card.dart';

class CombatantState {
  static const Object _sentinel = Object();

  const CombatantState({
    required this.id,
    required this.name,
    required this.displayName,
    required this.hometownName,
    required this.keyword,
    required this.maxHitPoints,
    required this.currentHitPoints,
    required this.maxFormPoints,
    required this.currentFormPoints,
    required this.drawPile,
    required this.hand,
    required this.discard,
    required this.selectedCardId,
    required this.selectedMode,
    required this.effectiveCardId,
    required this.stumbleTriggered,
    required this.reactionLocked,
  });

  final String id;
  final String name;
  final String displayName;
  final String hometownName;
  final String keyword;
  final int maxHitPoints;
  final int currentHitPoints;
  final int maxFormPoints;
  final int currentFormPoints;
  final List<CombatCard> drawPile;
  final List<CombatCard> hand;
  final List<CombatCard> discard;
  final String? selectedCardId;
  final CombatMode? selectedMode;
  final String? effectiveCardId;
  final bool stumbleTriggered;
  final bool reactionLocked;

  CombatantState copyWith({
    String? id,
    String? name,
    String? displayName,
    String? hometownName,
    String? keyword,
    int? maxHitPoints,
    int? currentHitPoints,
    int? maxFormPoints,
    int? currentFormPoints,
    List<CombatCard>? drawPile,
    List<CombatCard>? hand,
    List<CombatCard>? discard,
    Object? selectedCardId = _sentinel,
    Object? selectedMode = _sentinel,
    Object? effectiveCardId = _sentinel,
    bool? stumbleTriggered,
    bool? reactionLocked,
  }) {
    return CombatantState(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      hometownName: hometownName ?? this.hometownName,
      keyword: keyword ?? this.keyword,
      maxHitPoints: maxHitPoints ?? this.maxHitPoints,
      currentHitPoints: currentHitPoints ?? this.currentHitPoints,
      maxFormPoints: maxFormPoints ?? this.maxFormPoints,
      currentFormPoints: currentFormPoints ?? this.currentFormPoints,
      drawPile: drawPile ?? this.drawPile,
      hand: hand ?? this.hand,
      discard: discard ?? this.discard,
      selectedCardId: selectedCardId == _sentinel
          ? this.selectedCardId
          : selectedCardId as String?,
      selectedMode: selectedMode == _sentinel
          ? this.selectedMode
          : selectedMode as CombatMode?,
      effectiveCardId: effectiveCardId == _sentinel
          ? this.effectiveCardId
          : effectiveCardId as String?,
      stumbleTriggered: stumbleTriggered ?? this.stumbleTriggered,
      reactionLocked: reactionLocked ?? this.reactionLocked,
    );
  }
}
