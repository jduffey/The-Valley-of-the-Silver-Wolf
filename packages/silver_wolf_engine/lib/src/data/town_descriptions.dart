typedef TownDescriptionCopy = ({String description, String school});

const Map<String, TownDescriptionCopy>
townDescriptions = <String, TownDescriptionCopy>{
  '#Leap-Creek': (
    description: 'The Water Temple',
    school: "Temple of T'ai Chi Chuan",
  ),
  '#Blackstone': (
    description: 'The Iron Fortress',
    school: 'School of Hong Quan',
  ),
  '#Fangmarsh': (
    description: 'The Bog That Burns',
    school: 'Kwoon of Pai Tong Long',
  ),
  '#Underclaw': (description: 'The Buried City', school: 'Kwoon of Changquan'),
  '#Pouch': (description: 'The Wooded Winery', school: 'School of Zui Quan'),
};
