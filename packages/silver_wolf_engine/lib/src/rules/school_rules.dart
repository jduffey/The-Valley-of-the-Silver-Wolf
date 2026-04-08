import 'package:silver_wolf_engine/src/data/town_descriptions.dart';
import 'package:silver_wolf_engine/src/models/school.dart';

List<School> cloneSchools(List<School> schools) {
  return schools
      .map(
        (School school) =>
            school.copyWith(defenders: List<String>.from(school.defenders)),
      )
      .toList(growable: false);
}

School? getSchoolById(List<School> schools, String schoolId) {
  for (final School school in schools) {
    if (school.id == schoolId) {
      return school;
    }
  }
  return null;
}

School? getSchoolByName(List<School> schools, String schoolName) {
  for (final School school in schools) {
    if (school.name == schoolName) {
      return school;
    }
  }
  return null;
}

TownDescriptionCopy getTownCopy(String locationId) {
  return townDescriptions[locationId] ??
      (description: 'The Valley of the Star', school: 'Wilderness');
}

String getSchoolEventLabel(School school) {
  final TownDescriptionCopy townCopy = getTownCopy(school.id);
  return 'the ${townCopy.school} in ${school.name}';
}
