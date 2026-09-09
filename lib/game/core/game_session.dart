import 'dart:math';
import 'dart:ui';

enum GameMode { casual, campaign, chaos }
enum RunState { playing, paused, over, won }
const worlds = ['Neon Beginnings','Pixel Panic','Underwater Tap','Cosmic Touch','Lava Fingers','Cyber City','Candy Chaos','Wizard Warp','Alien Arcade','Temple of the Tap God'];
const milestones = <int,String>{100:'BACKGROUND SHIFT',200:'TAP EXPLOSIONS',300:'FUNNY SOUND MODE',400:'COLOR PULSE',500:'OVERDRIVE',600:'GRAVITY WARP',700:'TROLLVERTISEMENT',800:'FIRE TOUCH',900:'HYPER TAP',1000:'THE FIRST ASCENSION',2000:'WORLD SHIFT',3000:'TAP ASSISTANT',4000:'INVERTED REALITY',5000:'GOLDEN TOUCH',6000:'BEAT TAP',7000:'REALITY DISTORTION',8000:'MEME MAYHEM',9000:'GHOST TAPS',10000:'GOD MODE',15000:'TAP VELOCITY UPGRADE',20000:'ELECTRIC TOUCH',25000:'BOSS HAND',30000:'SYSTEM MELTDOWN',40000:'TAP UNIVERSE',50000:'SECRET DEVELOPER MESSAGE',60000:'INFINITE WORMHOLE',75000:'HALL OF FAME',100000:'TAP GOD'};

class GameSession {
  GameSession({this.mode = GameMode.casual, this.stage = 0, this.velocityPerk = false, int seed = 42}) : random = Random(seed);
  final String id=DateTime.now().microsecondsSinceEpoch.toString();
  final GameMode mode;
  final int stage;
  final bool velocityPerk;
  final Random random;
  RunState state = RunState.playing;
  int rawTaps = 0, score = 0, reviveCount = 0;
  double remaining = 1.5, duration = 0, grace = 0, overdrive = 0;
  double width = 400, height = 500, radius = 62, phase = 0;
  Offset target = const Offset(200,250);
  final Set<int> fired = {};
  final Map<int,double> ages = {};
  String reason = 'Your finger took a vacation.';
  int get highest => fired.isEmpty ? 0 : fired.reduce(max);
  int get goal => 25 + stage * 5;
  double get tapRate => duration > 0 ? rawTaps / duration : 0;
  int get multiplier => overdrive > 0 ? 2 : 1;
  bool get precision => mode == GameMode.campaign || (mode == GameMode.chaos && rawTaps >= 15) || (mode == GameMode.casual && rawTaps >= 60 && rawTaps % 80 >= 60);
  bool active(int n, double seconds) => ages.containsKey(n) && ages[n]! < seconds;
  void resize(double w,double h) { width=w; height=h; radius=min(62,min(w,h)/4); clampTarget(); }
  void clampTarget() { target=Offset(target.dx.clamp(radius+8,max(radius+8,width-radius-8)),target.dy.clamp(radius+8,max(radius+8,height-radius-8))); }
  void moveTarget() {
    final r = max(30.0,62-stage*0.6-min(rawTaps/250,20));
    radius=min(r,min(width,height)/4);
    // Bounded travel: each relocation remains reachable and entirely in the field.
    target += Offset((random.nextDouble()-.5)*160,(random.nextDouble()-.5)*180);
    clampTarget();
  }
  bool insideShape(Offset p,Offset center) {
    final delta=p-center;
    if(stage%3==1) return delta.dx.abs()<=radius*.707 && delta.dy.abs()<=radius*.707;
    // Hex uses a generous inscribed circular hit zone plus its actual polygon.
    if(stage%3==2) {
      final angle=atan2(delta.dy,delta.dx)-pi/6;
      final local=(angle+pi/6)%(pi/3)-pi/6;
      return delta.distance<=radius*cos(pi/6)/cos(local);
    }
    return delta.distance<=radius;
  }
  bool hit(Offset p) => insideShape(p,target) || (stage%5==4 && insideShape(p,secondary));
  Offset get secondary => Offset(width-target.dx,height-target.dy);
  List<int> tap(Offset position) {
    if(state != RunState.playing) return [];
    if(precision && !hit(position)) { state=RunState.over; reason='The glowing zone missed you.'; return []; }
    rawTaps++; score += multiplier + (velocityPerk && rawTaps % 10 == 0 ? 1 : 0); remaining=1.5;
    final unlocked=<int>[];
    for(final n in milestones.keys) { if(rawTaps>=n && fired.add(n)) { ages[n]=0; unlocked.add(n); if(n==500) overdrive=10; } }
    if(precision && (stage % 3 == 0 || rawTaps % 3 == 0)) moveTarget();
    if(mode == GameMode.campaign && rawTaps >= goal) {state=RunState.won; reason='Stage cleared. Finger promoted.';}
    return unlocked;
  }
  void update(double dt) {
    if(state != RunState.playing) return;
    duration += dt; phase += dt;
    for(final n in ages.keys.toList()) { ages[n]=ages[n]!+dt; }
    overdrive=max(0,overdrive-dt);
    if(grace>0) {grace=max(0,grace-dt);} else {remaining=max(0,remaining-dt);}
    if(remaining <= 0) {state=RunState.over; return;}
    if(precision && (stage%3!=0 || mode!=GameMode.campaign)) {
      final speed=min(95.0,18+stage*2+rawTaps/80);
      target += Offset(cos(phase*.8)*speed*dt,sin(phase*1.1)*speed*dt); clampTarget();
    }
  }
  void pause() {if(state==RunState.playing) state=RunState.paused;}
  void resume() {if(state==RunState.paused) state=RunState.playing;}
  bool revive({required bool rewarded}) {if(!rewarded || state!=RunState.over || reviveCount>=1) return false; reviveCount++; remaining=1.5; grace=2; state=RunState.playing; return true;}
  Map<String,dynamic> toJson() => {'runId':id,'mode':mode.name,'rawTaps':rawTaps,'score':score,'durationMs':(duration*1000).round(),'averageTapsPerSecond':tapRate,'reviveCount':reviveCount,'highestMilestone':highest,'stage':stage,'completed':state==RunState.won};
}
