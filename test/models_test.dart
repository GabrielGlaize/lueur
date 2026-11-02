import "package:flutter_test/flutter_test.dart";
import "package:lueur/domain/day_record.dart";
import "package:lueur/domain/settings.dart";

void main() {
  test("settings survive a JSON round trip", () {
    final settings = Settings.initial.copyWith(
      maximum: 17,
      notificationsEnabled: true,
    );
    expect(Settings.fromJson(settings.toJson()), settings);
  });

  test("settings reject missing, mistyped and out-of-range fields", () {
    final good = Settings.initial.toJson();
    expect(
      () => Settings.fromJson({...good}..remove("pace")),
      throwsFormatException,
    );
    expect(
      () => Settings.fromJson({...good, "maximum": "10"}),
      throwsFormatException,
    );
    expect(
      () => Settings.fromJson({...good, "maximum": 0}),
      throwsFormatException,
    );
    expect(
      () => Settings.fromJson({...good, "notificationHour": 24}),
      throwsFormatException,
    );
    expect(
      () => Settings.fromJson({...good, "quotaMode": "nope"}),
      throwsArgumentError,
    );
  });

  test("day records round trip and reject impossible counts", () {
    const record = DayRecord(
      dateKey: "2026-07-28",
      quota: 5,
      smoked: 3,
      seen: true,
    );
    expect(DayRecord.fromJson(record.toJson()), record);
    expect(
      () => DayRecord.fromJson({...record.toJson(), "smoked": -1}),
      throwsFormatException,
    );
    expect(
      () => DayRecord.fromJson({...record.toJson(), "smoked": 100}),
      throwsFormatException,
    );
  });

  test("only the maximum, mode and pace change what is drawn", () {
    final base = Settings.initial;
    expect(
      base.drawsDifferentlyFrom(base.copyWith(notificationHour: 9)),
      isFalse,
    );
    expect(base.drawsDifferentlyFrom(base.copyWith(maximum: 11)), isTrue);
  });
}
