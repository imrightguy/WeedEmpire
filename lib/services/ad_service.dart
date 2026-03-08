import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized Ad Service for WeedEmpire.
/// Manages rewarded ad loading and display.
/// Replace test ad unit IDs with your real AdMob IDs before release.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool get isAdLoaded => _isAdLoaded;

  // Test Ad Unit IDs (replace with real ones for production)
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          debugPrint('AdService: Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          debugPrint('AdService: Failed to load rewarded ad: ${error.message}');
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }

  /// Show a rewarded ad. [onReward] is called when the user earns the reward.
  void showRewardedAd({required VoidCallback onReward}) {
    if (_rewardedAd == null) {
      debugPrint('AdService: Ad not ready.');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdLoaded = false;
        loadRewardedAd(); // Preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAdLoaded = false;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onReward();
      },
    );
    _rewardedAd = null;
  }
}
