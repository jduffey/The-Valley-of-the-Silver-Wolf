String formatNameList(List<String> names) {
  if (names.isEmpty) {
    return '';
  }
  if (names.length == 1) {
    return names.first;
  }
  if (names.length == 2) {
    return '${names.first} and ${names.last}';
  }
  return '${names.take(names.length - 1).join(', ')}, and ${names.last}';
}

bool isTownId(String locationId) {
  return locationId.startsWith('#') && !locationId.startsWith('#road');
}

int normalizeIndex(int index, int length) {
  return ((index % length) + length) % length;
}
