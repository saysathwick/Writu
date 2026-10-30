import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_banner.dart';
import 'ad_ids.dart';
import 'sponsored_card.dart';

/// Mapped to Google AdMob formats.
enum AdPlacement {
  /// Native / banner in the notes gallery.
  homeFeed,

  /// Adaptive anchored banner above the home thumb dock.
  homeBanner,

  /// Never an interstitial. Save must finish unblocked.
  whileSaving,

  /// Interstitial after the editor closes following a save.
  afterSave,

  /// Same natural break as [afterSave] for a newly created note.
  afterCreate,

  /// Interstitial after a share sheet dismisses.
  afterShare,

  /// App open ad on cold start / long resume.
  appOpen,
}

bool get adsSdkSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Dedicated ad surface. Screens talk to [AdService], not AdMob directly.
abstract class AdService {
  bool get adsEnabled;

  Widget placementCard({bool compact = false});

  /// Insert a labeled native card after the first note, then every four notes.
  bool shouldInsertAfterNote(int noteIndex, int noteCount) {
    if (!adsEnabled || noteCount == 0) return false;
    if (noteIndex == 0) return true;
    return (noteIndex + 1) % 4 == 0;
  }

  Future<void> maybeShowInterstitial(
    AdPlacement placement, {
    BuildContext? context,
  });
}

class MockAdService implements AdService {
  MockAdService({required this.adsEnabled});

  @override
  final bool adsEnabled;

  int _breaksSinceInterstitial = 0;

  @override
  Widget placementCard({bool compact = false}) {
    if (!adsEnabled) return const SizedBox.shrink();
    return SponsoredCard(compact: compact);
  }

  @override
  bool shouldInsertAfterNote(int noteIndex, int noteCount) {
    if (!adsEnabled || noteCount == 0) return false;
    if (noteIndex == 0) return true;
    return (noteIndex + 1) % 4 == 0;
  }

  @override
  Future<void> maybeShowInterstitial(
    AdPlacement placement, {
    BuildContext? context,
  }) async {
    if (!adsEnabled) return;
    switch (placement) {
      case AdPlacement.whileSaving:
      case AdPlacement.homeFeed:
      case AdPlacement.homeBanner:
      case AdPlacement.appOpen:
        return;
      case AdPlacement.afterSave:
      case AdPlacement.afterCreate:
      case AdPlacement.afterShare:
        _breaksSinceInterstitial += 1;
        if (_breaksSinceInterstitial % 2 != 0) return;
        if (context == null || !context.mounted) return;
        await showMockInterstitial(context);
    }
  }
}

class GoogleMobileAdsService implements AdService {
  GoogleMobileAdsService({required this.adsEnabled}) {
    if (adsEnabled) _loadInterstitial();
  }

  @override
  final bool adsEnabled;

  @override
  bool shouldInsertAfterNote(int noteIndex, int noteCount) {
    if (!adsEnabled || noteCount == 0) return false;
    if (noteIndex == 0) return true;
    return (noteIndex + 1) % 4 == 0;
  }

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _breaksSinceInterstitial = 0;

  String get _interstitialId => defaultTargetPlatform == TargetPlatform.iOS
      ? AdIds.iosInterstitial
      : AdIds.androidInterstitial;

  @override
  Widget placementCard({bool compact = false}) {
    if (!adsEnabled) return const SizedBox.shrink();
    return AdBanner(compact: compact);
  }

  void _loadInterstitial() {
    if (!adsEnabled || _loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
          _loadingInterstitial = false;
          debugPrint('AdMob interstitial failed: $error');
        },
      ),
    );
  }

  @override
  Future<void> maybeShowInterstitial(
    AdPlacement placement, {
    BuildContext? context,
  }) async {
    if (!adsEnabled) return;
    switch (placement) {
      case AdPlacement.whileSaving:
      case AdPlacement.homeFeed:
      case AdPlacement.homeBanner:
      case AdPlacement.appOpen:
        return;
      case AdPlacement.afterSave:
      case AdPlacement.afterCreate:
      case AdPlacement.afterShare:
        _breaksSinceInterstitial += 1;
        if (_breaksSinceInterstitial % 2 != 0) {
          _loadInterstitial();
          return;
        }
        final ad = _interstitial;
        if (ad == null) {
          _loadInterstitial();
          return;
        }
        _interstitial = null;
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (shown) {
            shown.dispose();
            _loadInterstitial();
          },
          onAdFailedToShowFullScreenContent: (shown, error) {
            shown.dispose();
            _loadInterstitial();
          },
        );
        await ad.show();
    }
  }
}

Future<void> initializeAds() async {
  if (!adsSdkSupported) return;
  await MobileAds.instance.initialize();
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: const ['EMULATOR']),
  );
}

Future<void> showMockInterstitial(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Advertisement',
    barrierColor: const Color(0xCC1E2430),
    pageBuilder: (context, _, _) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: const Color(0xFF1E2430),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ADVERTISEMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: const Color(0xFF7CFFCB),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Interstitial after save',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is the AdMob interstitial slot that appears after a note is saved and the editor closes, never while saving.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
