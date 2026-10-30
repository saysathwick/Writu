import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'sponsored_card.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key, this.compact = false});

  final bool compact;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final size = widget.compact ? AdSize.banner : AdSize.largeBanner;
    final ad = BannerAd(
      size: size,
      adUnitId: defaultTargetPlatform == TargetPlatform.iOS
          ? AdIds.iosBanner
          : AdIds.androidBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _ad = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _failed = true);
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (_failed || ad == null) {
      return SponsoredCard(compact: widget.compact);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.compact ? 22 : 26),
      child: ColoredBox(
        color: const Color(0xFF1E2430),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
            const Positioned(
              left: 8,
              top: 6,
              child: Text(
                'TEST AD',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Color(0xFF7CFFCB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
