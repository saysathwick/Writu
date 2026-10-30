import 'package:flutter/widgets.dart';

abstract final class Motion {
  static const fast = Duration(milliseconds: 180);
  static const med = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 480);
  static const entrance = Duration(milliseconds: 560);

  static const ease = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const spring = Curves.easeOutBack;

  static Duration of(BuildContext context, Duration duration) {
    final mq = MediaQuery.maybeOf(context);
    if (mq != null && mq.disableAnimations) {
      return Duration.zero;
    }
    return duration;
  }
}
