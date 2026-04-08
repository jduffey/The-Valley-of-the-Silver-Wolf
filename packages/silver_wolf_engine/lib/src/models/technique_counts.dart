class TechniqueCounts {
  const TechniqueCounts({this.black = 0, this.brown = 0, this.gold = 0});

  final int black;
  final int brown;
  final int gold;

  TechniqueCounts copyWith({int? black, int? brown, int? gold}) {
    return TechniqueCounts(
      black: black ?? this.black,
      brown: brown ?? this.brown,
      gold: gold ?? this.gold,
    );
  }
}
