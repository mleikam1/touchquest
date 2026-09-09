import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show TextPainter, TextSpan, TextStyle;
import '../services/save_service.dart';
import 'core/game_session.dart';
import 'systems/milestone_director.dart';

class Spark {
  Offset p=Offset.zero, v=Offset.zero;
  double life=0, total=1;
  Color color=const Color(0xff58f9ef);
  bool ring=false;
}
class TouchQuestGame extends FlameGame {
  TouchQuestGame(this.session,this.save,this.onFrame);
  final GameSession session;
  final SaveService save;
  final void Function() onFrame;
  final pool=List.generate(240,(_)=>Spark());
  final rng=Random();
  double clock=0, ghostClock=0, slowFrames=0;
  int cursor=0;
  late final director=MilestoneDirector(session);
  double celebrationClock=0;
  final Paint ink=Paint();
  bool get reduced => save.flag('reduceMotion',false);
  bool get smooth => save.flag('reduceFlashing',true);
  Color get accent => session.rawTaps>=5000 || save.choice('skin','cyan')=='gold' ? const Color(0xffffd96a) : session.rawTaps>=800 ? const Color(0xffff8054) : const Color(0xff58f9ef);
  @override Color backgroundColor()=>const Color(0xff08132b);
  @override void onGameResize(Vector2 size) {super.onGameResize(size); session.resize(size.x,size.y);}
  void burst(Offset at,{bool celebrate=false}) {
    final low=save.choice('quality','auto')=='low' || (save.choice('quality','auto')=='auto' && slowFrames>20);
    final count=reduced?3:low?7:celebrate?90:director.hyper?36:session.rawTaps>=200?22:10;
    for(var i=0;i<count;i++) {
      final s=pool[cursor++%pool.length]; final a=rng.nextDouble()*pi*2;
      s.p=at; s.v=Offset(cos(a),sin(a))*(30+rng.nextDouble()*(celebrate?260:140)); s.total=s.life=celebrate?1.8:.65; s.ring=i==0; s.color=i%3==0?const Color(0xffbb8cff):accent;
    }
  }
  @override void update(double dt) {
    super.update(dt);
    if(session.state!=RunState.playing) return;
    clock+=dt; slowFrames=(slowFrames+(dt>.025?1:-.1)).clamp(0,100); session.update(dt);
    for(final s in pool) {if(s.life<=0) continue; s.life-=dt;
      if(!reduced) {if(session.rawTaps>=600) {final center=Offset(size.x/2,size.y/2); final pull=center-s.p; s.v+=Offset(-pull.dy,pull.dx)*dt*.4;} s.p+=s.v*dt;}
    }
    if(session.rawTaps>=9000 || (session.mode==GameMode.chaos && session.rawTaps>70)) {ghostClock+=dt; if(ghostClock>1.4) {ghostClock=0; final s=pool[cursor++%pool.length]; s.p=Offset(rng.nextDouble()*size.x,rng.nextDouble()*size.y); s.life=s.total=.8; s.ring=true; s.color=const Color(0xff66718c); s.v=Offset.zero;}}
    if(director.tapGod || session.active(1000,3) || session.active(10000,4)) {
      celebrationClock+=dt;
      if(celebrationClock>.5 && !reduced) {celebrationClock=0; burst(Offset(rng.nextDouble()*size.x,rng.nextDouble()*size.y*.6),celebrate:true);}
    }
    onFrame();
  }
  void label(Canvas c,String text,Offset p,{double fontSize=12,Color color=const Color(0xff7791b9)}) {
    final t=TextPainter(text:TextSpan(text:text,style:TextStyle(color:color,fontSize:fontSize,fontFamily:'monospace',fontWeight:FontWeight.w700,letterSpacing:2)),textDirection:TextDirection.ltr)..layout(maxWidth:max(1,size.x-32));
    t.paint(c,p-Offset(t.width/2,t.height/2));
  }
  @override void render(Canvas canvas) {
    super.render(canvas);
    final c=canvas;
    final rect=Offset.zero & size.toSize();
    c.save(); c.clipRect(rect);
    final shift=session.rawTaps>=100 ? (session.rawTaps>=2000 ? 4 : 1) : 0;
    final palette=[const Color(0xff152452),const Color(0xff30205a),const Color(0xff063e50),const Color(0xff351c54),const Color(0xff442138)];
    final base=palette[(session.stage~/5+shift+(session.rawTaps>=40000?session.tapRate.floor():0))%palette.length];
    ink..style=PaintingStyle.fill..shader=Gradient.radial(Offset(size.x*.5,size.y*.35),size.y,[base,const Color(0xff080e21)]);
    c.drawRect(rect,ink); ink.shader=null;
    final t=reduced?0.0:clock;
    for(var i=0;i<35;i++) {final x=(i*97.0)%size.x; final y=(i*151.0+t*(4+i%5))%size.y; ink.color=accent.withValues(alpha:.12); c.drawCircle(Offset(x,y),i%4==0?1.8:.8,ink);}
    ink..color=accent.withValues(alpha:.05)..strokeWidth=1;
    for(double x=0;x<size.x;x+=40) {c.drawLine(Offset(x,0),Offset(x,size.y),ink);}
    for(double y=0;y<size.y;y+=40) {c.drawLine(Offset(0,y),Offset(size.x,y),ink);}
    if(session.active(400,5)) {ink.color=(smooth?const Color(0xffaf70ff):accent).withValues(alpha:.08+.04*sin(clock*pi*.6)); c.drawRect(rect,ink);}
    if(session.active(4000,10)) {ink.color=const Color(0xffc977ff).withValues(alpha:.13); c.drawRect(rect,ink);}
    if(session.active(60000,30) || session.rawTaps>=10000) {ink..style=PaintingStyle.stroke..strokeWidth=2..color=accent.withValues(alpha:.12); for(var i=0;i<12;i++) {c.drawOval(Rect.fromCenter(center:Offset(size.x/2,size.y/2),width:30+i*35+sin(t+i)*10,height:20+i*30),ink);} ink.style=PaintingStyle.fill;}
    if(session.precision) {
      drawTarget(c,session.target,t);
      if(session.stage%5==4) drawTarget(c,session.secondary,t);
      if(session.mode==GameMode.chaos && session.rawTaps>100) {ink..color=const Color(0xff637088).withValues(alpha:.35)..style=PaintingStyle.stroke..strokeWidth=2; c.drawCircle(Offset(size.x-session.target.dx,session.target.dy),30,ink); ink.style=PaintingStyle.fill; label(c,'DECOY',Offset(size.x-session.target.dx,session.target.dy),fontSize:9);}
    } else {
      final center=Offset(size.x/2,size.y/2);
      for(var i=0;i<3;i++) {ink..color=accent.withValues(alpha:.08-i*.015)..style=PaintingStyle.stroke..strokeWidth=1; c.drawCircle(center,64+i*20+sin(t*1.5)*3,ink);}
      ink.style=PaintingStyle.fill;
      label(c,session.rawTaps==0?'TAP ANYWHERE':'KEEP GOING',center,fontSize:18,color:accent.withValues(alpha:.7));
      label(c,'YOUR FINGER IS THE CONTROLLER',center+const Offset(0,32),fontSize:9);
    }
    for(final s in pool) {if(s.life<=0) continue; final progress=(s.life/s.total).clamp(0.0,1.0); ink..color=s.color.withValues(alpha:progress)..strokeWidth=2..style=s.ring?PaintingStyle.stroke:PaintingStyle.fill; if(s.ring) {c.drawCircle(s.p,8+(1-progress)*(session.rawTaps>=900?100:60),ink);} else {c.drawCircle(s.p,2+progress*2,ink);}
      if(session.rawTaps>=20000 && !s.ring) {c.drawLine(s.p,s.p+Offset(8*sin(s.p.dy),-10),ink);}
    }
    ink.style=PaintingStyle.fill;
    if(session.active(25000,20) || (session.mode==GameMode.chaos && session.rawTaps%200>=160)) {
      // The boss chases from outside the valid zone; never obscures required input.
      final p=Offset((session.target.dx+100).clamp(40,size.x-40),max(40,session.target.dy-110));
      ink.color=const Color(0xffbd8df9); c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:p,width:52,height:52),const Radius.circular(16)),ink);
      for(var i=0;i<4;i++) {c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx-25+i*14,p.dy-58,11,50),const Radius.circular(6)),ink);}
      label(c,'CATCH ME!',p+const Offset(0,48),fontSize:10,color:accent);
    }
    if(session.active(30000,5)) {ink.color=accent.withValues(alpha:.1); for(double y=0;y<size.y;y+=8) {c.drawRect(Rect.fromLTWH(0,y,size.x,1),ink);} label(c,'REALITY.EXE IS STILL RESPONDING',Offset(size.x/2,40),fontSize:10);}
    if(session.rawTaps>=7000 && !reduced) {
      ink..style=PaintingStyle.stroke..strokeWidth=1..color=accent.withValues(alpha:.1);
      for(final s in pool.where((s)=>s.life>0 && s.ring).take(10)) {c.drawOval(Rect.fromCenter(center:s.p,width:120*(1-s.life/s.total)+5,height:35*(1-s.life/s.total)+5),ink);}
      ink.style=PaintingStyle.fill;
    }
    if(director.message.isNotEmpty) label(c,director.message,Offset(size.x/2,70),fontSize:11,color:accent);
    if(session.rawTaps>=6000) {for(var i=0;i<12;i++) {ink.color=accent.withValues(alpha:.3); final h=4+(reduced?4:(sin(t*session.tapRate+i)+1)*12); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.x/2-48+i*8,size.y-60-h,4,h),const Radius.circular(2)),ink);}}
    if(director.hyper && !reduced) {ink..style=PaintingStyle.stroke..strokeWidth=3..color=accent.withValues(alpha:.15+.05*sin(t*4)); c.drawRect(rect.deflate(2),ink); ink.style=PaintingStyle.fill;}
    if(session.rawTaps>=3000) {label(c,session.remaining<.6?'THAT WAS WAY TOO CLOSE.':session.tapRate>6?'FINGER OVERTIME APPROVED.':'YOU CAN STOP. PROBABLY.',Offset(size.x/2,size.y-30),fontSize:9,color:accent);}
    c.restore();
  }
  void drawTarget(Canvas c,Offset p,double t) {
    final r=session.radius;
    ink..style=PaintingStyle.fill..color=accent.withValues(alpha:.08); c.drawCircle(p,r+10+sin(t*2)*3,ink);
    ink.color=accent.withValues(alpha:.16); c.drawCircle(p,r,ink);
    ink..style=PaintingStyle.stroke..strokeWidth=3..color=accent;
    if(session.stage%3==1) {c.drawRRect(RRect.fromRectAndRadius(Rect.fromCircle(center:p,radius:r*.707),const Radius.circular(12)),ink);} else if(session.stage%3==2) {final path=Path(); for(var i=0;i<=6;i++) {final a=i*pi/3; final q=p+Offset(cos(a),sin(a))*r; if(i==0) {path.moveTo(q.dx,q.dy);} else {path.lineTo(q.dx,q.dy);}} c.drawPath(path,ink);} else {c.drawCircle(p,r,ink);}
    ink..strokeWidth=5..color=const Color(0xffffd675); c.drawArc(Rect.fromCircle(center:p,radius:r+7),-pi/2,pi*2*session.remaining/1.5,false,ink);
    ink.style=PaintingStyle.fill; label(c,'TAP',p,fontSize:16,color:accent);
  }
}
