import "dart:math";

import "package:flutter_test/flutter_test.dart";
import "package:lueur/domain/enums.dart";
import "package:lueur/domain/quota_drawer.dart";
import "package:lueur/domain/settings.dart";

void main() {
  Settings with_({
    int maximum = 12,
    QuotaMode mode = QuotaMode.guided,
    ReductionPace pace = ReductionPace.balanced,
  }) =>
      Settings.initial.copyWith(maximum: maximum, quotaMode: mode, pace: pace);

  test("guided balanced stays inside its range", () {
    final drawer = QuotaDrawer(Random(1));
    for (var i = 0; i < 500; i++) {
      expect(drawer.draw(with_()), inInclusiveRange(5, 9));
    }
  });

  test("full random covers 1 up to the maximum and nothing else", () {
    final drawer = QuotaDrawer(Random(2));
    final seen = {
      for (var i = 0; i < 2000; i++)
        drawer.draw(with_(maximum: 5, mode: QuotaMode.fullRandom)),
    };
    expect(seen, {1, 2, 3, 4, 5});
  });

  test("bold pace never exceeds gentle pace", () {
    final drawer = QuotaDrawer(Random(3));
    for (var i = 0; i < 300; i++) {
      expect(
        drawer.draw(with_(maximum: 20, pace: ReductionPace.bold)),
        lessThanOrEqualTo(10),
      );
    }
  });

  test("extreme maximums never produce an invalid range", () {
    final drawer = QuotaDrawer(Random(4));
    for (final pace in ReductionPace.values) {
      for (final maximum in [Settings.minMaximum, 2, Settings.maxMaximum]) {
        for (var i = 0; i < 100; i++) {
          final quota = drawer.draw(with_(maximum: maximum, pace: pace));
          expect(quota, inInclusiveRange(0, maximum));
        }
      }
    }
  });
}
