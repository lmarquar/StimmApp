import 'package:flutter/material.dart';
import 'package:stimmapp/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  final AdService _adService = AdService();
  BannerAdWrapper? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoadFailed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = _adService.createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) {
          setState(() {
            _isAdLoadFailed = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: _bannerAd!.build(),
      );
    }
    // Return a placeholder while the ad loads or if it failed.
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      color: Colors.grey[200],
      child: Text(
        _isAdLoadFailed ? 'Ad Failed' : 'Loading Ad...',
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
