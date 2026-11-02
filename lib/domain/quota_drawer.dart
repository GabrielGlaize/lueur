import "dart:math";

import "enums.dart";
import "settings.dart";

/// Draws a daily quota. The generator is injected so tests are deterministic
/// while the app uses [Random.secure].
class QuotaDrawer {
  QuotaDrawer(this._random);

  final Random _random;

  int draw(Settings settings) {
    if (settings.quotaMode == QuotaMode.fullRandom) {
      return 1 + _random.nextInt(settings.maximum);
    }
    final low = (settings.maximum * settings.pace.minimumRatio).round();
    final high = max(
      low,
      (settings.maximum * settings.pace.maximumRatio).round(),
    );
    return low + _random.nextInt(high - low + 1);
  }
}
