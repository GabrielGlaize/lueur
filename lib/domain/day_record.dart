import "package:equatable/equatable.dart";

import "../core/json_read.dart";

class DayRecord extends Equatable {
  const DayRecord({
    required this.dateKey,
    required this.quota,
    required this.smoked,
    required this.seen,
  });

  static const int maxSmoked = 99;

  final String dateKey;
  final int quota;
  final int smoked;

  /// True once the user opened the app that day. Days drawn ahead for the
  /// notifications stay unseen, so they never count as "respected".
  final bool seen;

  bool get respected => smoked <= quota;
  int get remaining => quota - smoked;

  DayRecord copyWith({int? quota, int? smoked, bool? seen}) => DayRecord(
    dateKey: dateKey,
    quota: quota ?? this.quota,
    smoked: smoked ?? this.smoked,
    seen: seen ?? this.seen,
  );

  Map<String, Object?> toJson() => {
    "date": dateKey,
    "quota": quota,
    "smoked": smoked,
    "seen": seen,
  };

  factory DayRecord.fromJson(Map<String, Object?> json) {
    final record = DayRecord(
      dateKey: readField<String>(json, "date"),
      quota: readField<int>(json, "quota"),
      smoked: readField<int>(json, "smoked"),
      seen: readField<bool>(json, "seen"),
    );
    if (record.quota < 0 || record.smoked < 0 || record.smoked > maxSmoked) {
      throw FormatException("Day counts out of range", json);
    }
    return record;
  }

  @override
  List<Object?> get props => [dateKey, quota, smoked, seen];
}
