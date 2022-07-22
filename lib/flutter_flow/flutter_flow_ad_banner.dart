import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FlutterFlowAdBanner extends StatefulWidget {
  const FlutterFlowAdBanner({
    Key key,
    this.width,
    this.height,
    @required this.showsTestAd,
    this.iOSAdUnitID,
    this.androidAdUnitID,
  }) : super(key: key);

  final double width;
  final double height;
  final bool showsTestAd;
  final String iOSAdUnitID;
  final String androidAdUnitID;

  @override
  _FlutterFlowAdBannerState createState() => _FlutterFlowAdBannerState();
}

class _FlutterFlowAdBannerState extends State<FlutterFlowAdBanner> {
  static const AdRequest request = AdRequest();

  BannerAd _anchoredBanner;
  AdWidget adWidget;

  @override
  void initState() {
    super.initState();

    _createAnchoredBanner(context);
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loadingText = 'Ad Loading... \n\n';
    if (widget.showsTestAd) {
      loadingText +=
          'If this takes a long time, you may have to check whether the ad is '
          'being covered from a parent widget. For example, a larger width than '
          'the device screen size or a large border radius encompassing the ad banner '
          'may stop ads from loading.\n\n'
          'If a full-width banner is desired for your app, leave the width and '
          'height of the AdBanner widget empty. AdBanner will automatically'
          'match the size of the banner to the device screen.';
    }

    return _anchoredBanner != null && adWidget != null
        ? Container(
            alignment: Alignment.center,
            color: Colors.red,
            width: _anchoredBanner.size.width.toDouble(),
            height: _anchoredBanner.size.height.toDouble(),
            child: adWidget,
          )
        : Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                loadingText,
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }

  Future _createAnchoredBanner(BuildContext context) async {
    final AdSize size = widget.width != null && widget.height != null
        ? AdSize(
            height: widget.height.toInt(),
            width: widget.width.toInt(),
          )
        : await AdSize.getAnchoredAdaptiveBannerAdSize(
            widget.width == null ? Orientation.portrait : Orientation.landscape,
            widget.width == null
                ? MediaQuery.of(context).size.width.truncate()
                : MediaQuery.of(context).size.height.truncate(),
          );

    if (size == null) {
      print('Unable to get size of anchored banner.');
      return;
    }

    final isAndroid = !kIsWeb && Platform.isAndroid;
    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: widget.showsTestAd
          ? isAndroid
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-3940256099942544/2934735716'
          : isAndroid
              ? widget.androidAdUnitID
              : widget.iOSAdUnitID,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('$BannerAd loaded.');
          if (mounted) {
            setState(() => _anchoredBanner = ad as BannerAd);
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    await banner.load();

    adWidget = AdWidget(ad: banner);
    setState(() {});
    return;
  }
}
