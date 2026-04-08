const int clockwiseDirection = 1;
const int counterClockwiseDirection = -1;
const int initialReputation = 3;
const int initialHitPoints = 3;
const int initialFormPoints = 2;
const int maxStat = 5;
const int silverWolfBaseStrength = 20;
const int totalToChallenge = 15;
const int whiteDieWolfFace = 1;

const Map<String, Map<String, int>> playerStartingStats =
    <String, Map<String, int>>{
      'Pouch': <String, int>{
        'power': 0,
        'stamina': 1,
        'agility': 0,
        'chi': 0,
        'wit': 2,
      },
      'Leap-Creek': <String, int>{
        'power': 0,
        'stamina': 0,
        'agility': 1,
        'chi': 2,
        'wit': 0,
      },
      'Fangmarsh': <String, int>{
        'power': 2,
        'stamina': 0,
        'agility': 0,
        'chi': 0,
        'wit': 1,
      },
      'Blackstone': <String, int>{
        'power': 1,
        'stamina': 2,
        'agility': 0,
        'chi': 0,
        'wit': 0,
      },
      'Underclaw': <String, int>{
        'power': 0,
        'stamina': 0,
        'agility': 2,
        'chi': 1,
        'wit': 0,
      },
    };
