class ChallengeState {
  static const Object _sentinel = Object();

  const ChallengeState({
    required this.challengerId,
    required this.opponentIds,
    required this.targetId,
  });

  final String challengerId;
  final List<String> opponentIds;
  final String? targetId;

  ChallengeState copyWith({
    String? challengerId,
    List<String>? opponentIds,
    Object? targetId = _sentinel,
  }) {
    return ChallengeState(
      challengerId: challengerId ?? this.challengerId,
      opponentIds: opponentIds ?? this.opponentIds,
      targetId: targetId == _sentinel ? this.targetId : targetId as String?,
    );
  }
}
