class AssetCatalog {
  const AssetCatalog._();

  static const String boardMap = 'assets/board/map.png';
  static const String modalBackground = 'assets/images/modal-background.jpeg';

  static const Map<String, String> _sigilsByTownName = <String, String>{
    'Leap-Creek': 'assets/sigils/leapcreek.svg',
    'Blackstone': 'assets/sigils/blackstone.svg',
    'Fangmarsh': 'assets/sigils/fangmarsh.svg',
    'Underclaw': 'assets/sigils/underclaw.svg',
    'Pouch': 'assets/sigils/pouch.svg',
  };

  static const Map<String, String> _sigilsByLocationId = <String, String>{
    '#Leap-Creek': 'assets/sigils/leapcreek.svg',
    '#Blackstone': 'assets/sigils/blackstone.svg',
    '#Fangmarsh': 'assets/sigils/fangmarsh.svg',
    '#Underclaw': 'assets/sigils/underclaw.svg',
    '#Pouch': 'assets/sigils/pouch.svg',
  };

  static String? sigilForTownName(String townName) =>
      _sigilsByTownName[townName];

  static String? sigilForLocationId(String locationId) =>
      _sigilsByLocationId[locationId];
}
