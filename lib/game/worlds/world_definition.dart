import 'dart:ui';

class WorldDefinition {
  const WorldDefinition(this.color, this.accent, this.modifier);
  final Color color, accent;
  final String modifier;
}

const worldDefinitions = [
  WorldDefinition(Color(0xff152452), Color(0xff58f9ef), 'RELOCATE'),
  WorldDefinition(Color(0xff30205a), Color(0xffbfa0ff), 'PIXEL HOP'),
  WorldDefinition(Color(0xff063e50), Color(0xff65d9ff), 'CURRENT'),
  WorldDefinition(Color(0xff211e50), Color(0xffbeaaff), 'ORBIT'),
  WorldDefinition(Color(0xff442138), Color(0xffff9870), 'HEAT PULSE'),
  WorldDefinition(Color(0xff152f44), Color(0xff52ffd8), 'FAST LANE'),
  WorldDefinition(Color(0xff432447), Color(0xffffa9db), 'DOUBLE SWEET'),
  WorldDefinition(Color(0xff321c58), Color(0xffcc99ff), 'TELEPORT'),
  WorldDefinition(Color(0xff183b34), Color(0xffb4fc85), 'BOUNCE'),
  WorldDefinition(Color(0xff40311e), Color(0xffffd675), 'FINAL TRIAL'),
];
