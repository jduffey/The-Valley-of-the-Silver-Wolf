class GameLogEntry {
  const GameLogEntry({
    required this.message,
    this.type = 'info',
    this.metadata = const <String, Object?>{},
  });

  final String message;
  final String type;
  final Map<String, Object?> metadata;

  GameLogEntry copyWith({
    String? message,
    String? type,
    Map<String, Object?>? metadata,
  }) {
    return GameLogEntry(
      message: message ?? this.message,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}
