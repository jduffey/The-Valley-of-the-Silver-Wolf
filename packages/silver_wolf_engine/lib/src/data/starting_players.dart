typedef StartingPlayerSeed = ({
  String id,
  String name,
  String color,
  int locationIndex,
});

const List<StartingPlayerSeed> startingPlayers = <StartingPlayerSeed>[
  (id: 'p1', name: 'Leap-Creek', color: '#47c3ed', locationIndex: 0),
  (id: 'p2', name: 'Blackstone', color: '#7d7f84', locationIndex: 2),
  (id: 'p3', name: 'Fangmarsh', color: '#cf4254', locationIndex: 4),
  (id: 'p4', name: 'Underclaw', color: '#2f9e61', locationIndex: 6),
  (id: 'p5', name: 'Pouch', color: '#8d59df', locationIndex: 8),
];
