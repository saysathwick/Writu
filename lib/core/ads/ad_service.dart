import 'package:flutter/material.dart';

/// Mapped to Google AdMob formats. See the U-write AdMob plan canvas.
enum AdPlacement {
  /// Native Advanced in the notes gallery.
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

  /// App open ad on cold start / long resume. Wired at the app root later.
  appOpen,
}

/// Dedicated ad surface. Swap [MockAdService] for Google Mobile Ads
/// without rewriting screens.
abstract class AdService {
  bool get adsEnabled;

  Widget? feedCard({required int index});

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
  Widget? feedCard({required int index}) {
    if (!adsEnabled) return null;
    return null;
  }

  /// Insert a labeled native card after the first note, then every four notes.
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
  GoogleMobileAdsService({required this.adsEnabled});

  @override
  final bool adsEnabled;

  @override
  Widget? feedCard({required int index}) => null;

  @override
  Future<void> maybeShowInterstitial(
    AdPlacement placement, {
    BuildContext? context,
  }) async {}
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
                        'This is the AdMob interstitial slot that appears after a note is saved and the editor closes — never while saving.',
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
