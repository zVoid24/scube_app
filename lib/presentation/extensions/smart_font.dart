import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension AdaptiveFont on num {
  double get adaptiveSp {
    final base = toDouble();
    final safeBase = base <= 0 ? 1.0 : base;
    final w = ScreenUtil().screenWidth;
    final h = ScreenUtil().screenHeight;
    final isLandscape = ScreenUtil().orientation == Orientation.landscape;

    final shortestSide = w < h ? w : h;
    final isTablet = shortestSide >= 600 && shortestSide < 1024;
    final isDesktop = shortestSide >= 1024;

    double multiplier = 1.0;
    if (isDesktop) {
      multiplier *= 0.90;
    } else if (isTablet) {
      multiplier *= 1.00;
    }

    if (isLandscape) {
      multiplier *= isDesktop ? 0.92 : (isTablet ? 0.97 : 0.94);
    }

    final scaled = safeBase.sp * multiplier;
    final tabletExtra = isTablet ? 2.0 : (isDesktop ? 1.0 : 0.0);

    double minLimit, maxLimit;
    if (safeBase < 8) {
      minLimit = (safeBase - 1).clamp(1.0, double.infinity);
      maxLimit = (safeBase + 2 + tabletExtra).clamp(minLimit, double.infinity);
    } else if (safeBase <= 12) {
      minLimit = (safeBase - 1).clamp(8.0, double.infinity);
      maxLimit = safeBase + 2 + tabletExtra;
    } else if (safeBase <= 20) {
      minLimit = (safeBase - 2).clamp(10.0, double.infinity);
      maxLimit = safeBase + 5 + tabletExtra;
    } else {
      minLimit = (safeBase - 3).clamp(12.0, double.infinity);
      maxLimit = safeBase + 7 + tabletExtra;
    }
    if (maxLimit < minLimit) maxLimit = minLimit;

    return scaled.clamp(minLimit, maxLimit);
  }

  double adaptiveSpInBox({required double boxH}) {
    double scaled = adaptiveSp;

    if (boxH < 150) scaled *= 0.95;
    if (boxH < 135) scaled *= 0.92;
    if (boxH < 125) scaled *= 0.88;
    if (boxH < 110) scaled *= 0.85;

    return scaled;
  }
}
