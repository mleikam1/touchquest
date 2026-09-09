import '../core/game_session.dart';

/// All milestone durations are measured in active game time, never wall time.
class MilestoneDirector {
  const MilestoneDirector(this.session);
  final GameSession session;
  bool get funnySounds => session.active(300,12);
  bool get colorPulse => session.active(400,5);
  bool get hyper => session.active(900,8);
  bool get inverted => session.active(4000,10);
  bool get meltdown => session.active(30000,5);
  bool get wormhole => session.active(60000,30);
  bool get golden => session.fired.contains(5000);
  bool get electric => session.fired.contains(20000);
  bool get god => session.fired.contains(10000);
  bool get tapGod => session.fired.contains(100000);
  String get message {
    if(session.active(700,7)) return 'GAME COMEDY · SPONSORED BY ABSOLUTELY NOBODY';
    if(session.active(8000,8)) return 'ABSOLUTE TAP UNIT';
    if(session.active(50000,10)) return 'We did not expect you to get here. Thank you!';
    if(session.active(75000,10)) return 'YOUR FINGER BELONGS IN A MUSEUM';
    if(session.active(100000,15)) return 'TAP GOD · THE UNIVERSE APPLAUDS';
    return '';
  }
}
