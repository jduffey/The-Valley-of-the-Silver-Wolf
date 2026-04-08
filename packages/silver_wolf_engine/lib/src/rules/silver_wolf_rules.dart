import 'package:collection/collection.dart';
import 'package:silver_wolf_engine/src/constants/game_constants.dart';
import 'package:silver_wolf_engine/src/enums/school_status.dart';
import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/models/school.dart';
import 'package:silver_wolf_engine/src/random/randomizer.dart';
import 'package:silver_wolf_engine/src/rules/player_rules.dart';
import 'package:silver_wolf_engine/src/rules/school_rules.dart';

class SilverWolfAdvanceResult {
  const SilverWolfAdvanceResult({
    required this.schools,
    required this.logEntries,
    required this.schoolsStillStanding,
  });

  final List<School> schools;
  final List<GameLogEntry> logEntries;
  final bool schoolsStillStanding;
}

int rollDie(Randomizer randomizer, [int sides = 6]) {
  return randomizer.nextInt(sides) + 1;
}

int rollWhiteDie(Randomizer randomizer) {
  return rollDie(randomizer);
}

int getSilverWolfStrength(List<School> schools) {
  final int destroyedSchools = schools
      .where((School school) => school.status == SchoolStatus.destroyed)
      .length;
  return silverWolfBaseStrength + (destroyedSchools * 2);
}

bool canChallengeSilverWolf(Player player) {
  return player.alive && getTotalStats(player) >= totalToChallenge;
}

int buildCombatScore(Player player, Randomizer randomizer) {
  return getTotalStats(player) + rollDie(randomizer);
}

SilverWolfAdvanceResult advanceSilverWolf(
  List<School> schools,
  Randomizer randomizer,
) {
  final List<School> updatedSchools = cloneSchools(schools);
  final List<School> standingSchools = updatedSchools
      .where((School school) => school.status != SchoolStatus.destroyed)
      .toList(growable: false);

  if (standingSchools.isEmpty) {
    return const SilverWolfAdvanceResult(
      schools: <School>[],
      logEntries: <GameLogEntry>[],
      schoolsStillStanding: false,
    );
  }

  final List<GameLogEntry> logEntries = <GameLogEntry>[];
  final School? siegedSchool = standingSchools.firstWhereOrNull(
    (School school) =>
        school.status == SchoolStatus.sieged && !school.isCompletingSave,
  );
  final List<School> wholeSchools = standingSchools
      .where(
        (School school) =>
            school.status == SchoolStatus.whole && !school.isCompletingSave,
      )
      .toList(growable: false);
  final int whiteDieResult = rollWhiteDie(randomizer);

  if (siegedSchool != null) {
    final School selectedSchool =
        standingSchools[randomizer.nextInt(standingSchools.length)];

    if (selectedSchool.id != siegedSchool.id) {
      return SilverWolfAdvanceResult(
        schools: updatedSchools,
        logEntries: logEntries,
        schoolsStillStanding: updatedSchools.any(
          (School school) => school.status != SchoolStatus.destroyed,
        ),
      );
    }

    if (whiteDieResult == whiteDieWolfFace) {
      final int index = updatedSchools.indexWhere(
        (School school) => school.id == siegedSchool.id,
      );
      updatedSchools[index] = siegedSchool.copyWith(
        status: SchoolStatus.destroyed,
        saveProgress: 0,
        isCompletingSave: false,
        defenders: const <String>[],
      );
      logEntries.add(
        GameLogEntry(
          type: 'silver_wolf_school_destroyed',
          message:
              'The Silver Wolf has destroyed ${getSchoolEventLabel(updatedSchools[index])}.',
          metadata: <String, Object?>{
            'schoolId': updatedSchools[index].id,
            'whiteDieResult': whiteDieResult,
          },
        ),
      );
    }

    return SilverWolfAdvanceResult(
      schools: updatedSchools,
      logEntries: logEntries,
      schoolsStillStanding: updatedSchools.any(
        (School school) => school.status != SchoolStatus.destroyed,
      ),
    );
  }

  if (wholeSchools.isEmpty) {
    return const SilverWolfAdvanceResult(
      schools: <School>[],
      logEntries: <GameLogEntry>[],
      schoolsStillStanding: false,
    );
  }

  final School target = wholeSchools[randomizer.nextInt(wholeSchools.length)];

  if (whiteDieResult == whiteDieWolfFace) {
    final int index = updatedSchools.indexWhere(
      (School school) => school.id == target.id,
    );
    updatedSchools[index] = target.copyWith(
      status: SchoolStatus.sieged,
      saveProgress: 0,
      isCompletingSave: false,
      defenders: const <String>[],
    );
    logEntries.add(
      GameLogEntry(
        type: 'silver_wolf_school_sieged',
        message:
            'The Silver Wolf has laid siege to ${getSchoolEventLabel(updatedSchools[index])}.',
        metadata: <String, Object?>{
          'schoolId': updatedSchools[index].id,
          'whiteDieResult': whiteDieResult,
        },
      ),
    );
  }

  return SilverWolfAdvanceResult(
    schools: updatedSchools,
    logEntries: logEntries,
    schoolsStillStanding: updatedSchools.any(
      (School school) => school.status != SchoolStatus.destroyed,
    ),
  );
}
