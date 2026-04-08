import 'package:silver_wolf_engine/src/enums/school_status.dart';

class School {
  const School({
    required this.id,
    required this.name,
    required this.status,
    required this.saveProgress,
    required this.isCompletingSave,
    required this.defenders,
  });

  final String id;
  final String name;
  final SchoolStatus status;
  final int saveProgress;
  final bool isCompletingSave;
  final List<String> defenders;

  School copyWith({
    String? id,
    String? name,
    SchoolStatus? status,
    int? saveProgress,
    bool? isCompletingSave,
    List<String>? defenders,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      saveProgress: saveProgress ?? this.saveProgress,
      isCompletingSave: isCompletingSave ?? this.isCompletingSave,
      defenders: defenders ?? this.defenders,
    );
  }
}
