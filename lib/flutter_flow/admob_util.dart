import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Learn more about displaying interstitial ads:
// https://developers.google.com/admob/flutter/interstitial

InterstitialAd _interstitialAd;
String _loadingInterstitialAdUnitId;

void loadInterstitialAd(
  String iosAdUnitId,
  String androidAdUnitId,
  bool showTestAds,
) {
  if (kIsWeb) {
    print('AdMob is not supported on web.');
    return;
  }
  String adUnitId;
  if (Platform.isIOS) {
    adUnitId = showTestAds ? InterstitialAd.testAdUnitId : iosAdUnitId;
  } else if (Platform.isAndroid) {
    adUnitId = showTestAds ? InterstitialAd.testAdUnitId : androidAdUnitId;
  } else {
    print("AdMob is not supported on this platform.");
    return;
  }

  if (adUnitId == _loadingInterstitialAdUnitId) {
    // Already loading the same ad.
    return;
  }
  if (adUnitId == _interstitialAd?.adUnitId) {
    // The ad is already loaded.
    return;
  }
  _loadingInterstitialAdUnitId = adUnitId;

  InterstitialAd.load(
    adUnitId: adUnitId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        if (adUnitId == _loadingInterstitialAdUnitId) {
          _interstitialAd = ad;
          _loadingInterstitialAdUnitId = null;
        }
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('Interstitial ad failed to load: $error');
        _loadingInterstitialAdUnitId = null;
      },
    ),
  );
}

Future<bool> showInterstitialAd() async {
  if (_interstitialAd == null) {
    print('Interstitial ad is not loaded.');
    // Return success even if the ad is not yet loaded.
    // The ad waits for the user, so the user never waits for the ad!
    // https://youtu.be/r2RgFD3Apyo?t=188
    return true;
  }
  final completer = Completer<bool>();
  _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      ad.dispose();
      _interstitialAd = null;
      completer.complete(true);
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('$ad onAdFailedToShowFullScreenContent: $error');
      ad.dispose();
      _interstitialAd = null;
      completer.complete(false);
    },
  );
  _interstitialAd.show();
  return completer.future;
}
