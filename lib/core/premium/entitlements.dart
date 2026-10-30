/// Entitlements are local-only for now. A store kit / Play Billing
/// implementation can replace [LocalEntitlements] later.
abstract class Entitlements {
  bool get isPremium;
  bool canUseFont(String fontId, {required bool markedPremium});
  bool canUseTheme(bool markedPremium);
  bool get adsEnabled;
}

class LocalEntitlements implements Entitlements {
  LocalEntitlements({this.isPremium = false});

  @override
  final bool isPremium;

  @override
  bool get adsEnabled => !isPremium;

  @override
  bool canUseFont(String fontId, {required bool markedPremium}) {
    if (!markedPremium) return true;
    return isPremium;
  }

  @override
  bool canUseTheme(bool markedPremium) {
    if (!markedPremium) return true;
    return isPremium;
  }
}
