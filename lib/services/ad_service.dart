import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdService {
  bool get rewardedReady;
  Widget banner();
  Future<void> initialize();
  Future<bool> reward();
  Future<void> stageBreak();
  void dispose();
  static AdService create()=>kIsWeb?WebAdService():MobileAdService();
}
class WebAdService implements AdService {
  @override bool get rewardedReady=>false;
  @override Widget banner()=>const AdPlaceholder();
  @override Future<void> initialize() async {}
  @override Future<bool> reward() async=>false;
  @override Future<void> stageBreak() async {}
  @override void dispose() {}
}
class AdPlaceholder extends StatelessWidget {
  const AdPlaceholder({super.key});
  @override Widget build(BuildContext context)=>const SizedBox(height:50,width:320,child:Center(child:Text('AD SPACE  ·  TAKE A FINGER BREATHER',style:TextStyle(color:Color(0xff62708d),fontSize:9,letterSpacing:1.3))));
}
class MobileAdService implements AdService {
  BannerAd? _banner;
  RewardedAd? _reward;
  InterstitialAd? _interstitial;
  final loaded=ValueNotifier(false);
  int breaks=0;
  bool get android=>defaultTargetPlatform==TargetPlatform.android;
  String unit(String type) {
    if(kReleaseMode) {return switch(type) {'banner'=>const String.fromEnvironment('ADMOB_BANNER_ID'),'reward'=>const String.fromEnvironment('ADMOB_REWARDED_ID'),_=>const String.fromEnvironment('ADMOB_INTERSTITIAL_ID')};}
    final suffix=android? switch(type){'banner'=>'6300978111','reward'=>'5224354917',_=>'1033173712'}:switch(type){'banner'=>'2934735716','reward'=>'1712485313',_=>'4411468910'};
    return 'ca-app-pub-3940256099942544/$suffix';
  }
  @override bool get rewardedReady=>_reward!=null;
  @override Future<void> initialize() async {
    if(unit('banner').isEmpty) return;
    final consent=Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(ConsentRequestParameters(),() {ConsentForm.loadAndShowConsentFormIfRequired((error) {if(!consent.isCompleted) consent.complete();});},(error) {if(!consent.isCompleted) consent.complete();});
    await consent.future;
    if(!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    _banner=BannerAd(size:AdSize.banner,adUnitId:unit('banner'),request:const AdRequest(),listener:BannerAdListener(onAdLoaded:(_)=>loaded.value=true,onAdFailedToLoad:(ad,error){ad.dispose(); debugPrint('Banner: $error');}));
    await _banner!.load(); loadReward(); loadInterstitial();
  }
  void loadReward() {if(unit('reward').isEmpty) return; RewardedAd.load(adUnitId:unit('reward'),request:const AdRequest(),rewardedAdLoadCallback:RewardedAdLoadCallback(onAdLoaded:(ad)=>_reward=ad,onAdFailedToLoad:(error)=>debugPrint('Reward ad: $error')));}
  void loadInterstitial() {if(unit('interstitial').isEmpty) return; InterstitialAd.load(adUnitId:unit('interstitial'),request:const AdRequest(),adLoadCallback:InterstitialAdLoadCallback(onAdLoaded:(ad)=>_interstitial=ad,onAdFailedToLoad:(error)=>debugPrint('Interstitial: $error')));}
  @override Widget banner()=>ValueListenableBuilder<bool>(valueListenable:loaded,builder:(context,ready,child)=>ready && _banner!=null?SizedBox(width:320,height:50,child:AdWidget(ad:_banner!)):const AdPlaceholder());
  @override Future<bool> reward() async {
    final ad=_reward; if(ad==null) return false; _reward=null;
    final result=Completer<bool>(); bool earned=false;
    ad.fullScreenContentCallback=FullScreenContentCallback(onAdDismissedFullScreenContent:(ad){ad.dispose(); result.complete(earned); loadReward();},onAdFailedToShowFullScreenContent:(ad,error){ad.dispose(); result.complete(false); loadReward();});
    ad.show(onUserEarnedReward:(ad,reward){earned=true;}); return result.future;
  }
  @override Future<void> stageBreak() async {breaks++; if(breaks%3!=0 || _interstitial==null) return; final ad=_interstitial!; _interstitial=null; final done=Completer<void>(); ad.fullScreenContentCallback=FullScreenContentCallback(onAdDismissedFullScreenContent:(ad){ad.dispose(); loadInterstitial(); done.complete();},onAdFailedToShowFullScreenContent:(ad,error){ad.dispose(); done.complete();}); ad.show(); await done.future;}
  @override void dispose() {_banner?.dispose(); _reward?.dispose(); _interstitial?.dispose(); loaded.dispose();}
}
