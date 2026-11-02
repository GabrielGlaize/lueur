import "package:equatable/equatable.dart";

import "../core/json_read.dart";
import "enums.dart";

class Settings extends Equatable {
  const Settings({
    required this.maximum,
    required this.quotaMode,
    required this.pace,
    required this.drawPolicy,
    required this.notificationHour,
    required this.notificationMinute,
    required this.notificationsEnabled,
  });

  static const int minMaximum = 1;
  static const int maxMaximum = 60;
  static const int defaultMaximum = 10;
  static const QuotaMode defaultQuotaMode = QuotaMode.guided;
  static const ReductionPace defaultPace = ReductionPace.balanced;
  static const DrawPolicy defaultDrawPolicy = DrawPolicy.frozen;
  static const int defaultNotificationHour = 8;
  static const int defaultNotificationMinute = 30;
  static const bool defaultNotificationsEnabled = false;

  /// Settings proposed at the start of onboarding.
  static const Settings initial = Settings(
    maximum: defaultMaximum,
    quotaMode: defaultQuotaMode,
    pace: defaultPace,
    drawPolicy: defaultDrawPolicy,
    notificationHour: defaultNotificationHour,
    notificationMinute: defaultNotificationMinute,
    notificationsEnabled: defaultNotificationsEnabled,
  );

  final int maximum;
  final QuotaMode quotaMode;
  final ReductionPace pace;
  final DrawPolicy drawPolicy;
  final int notificationHour;
  final int notificationMinute;
  final bool notificationsEnabled;

  /// Whether a quota drawn with [other] would differ from one drawn with this.
  bool drawsDifferentlyFrom(Settings other) =>
      maximum != other.maximum ||
      quotaMode != other.quotaMode ||
      pace != other.pace;

  Settings copyWith({
    int? maximum,
    QuotaMode? quotaMode,
    ReductionPace? pace,
    DrawPolicy? drawPolicy,
    int? notificationHour,
    int? notificationMinute,
    bool? notificationsEnabled,
  }) {
    return Settings(
      maximum: maximum ?? this.maximum,
      quotaMode: quotaMode ?? this.quotaMode,
      pace: pace ?? this.pace,
      drawPolicy: drawPolicy ?? this.drawPolicy,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, Object?> toJson() => {
    "maximum": maximum,
    "quotaMode": quotaMode.name,
    "pace": pace.name,
    "drawPolicy": drawPolicy.name,
    "notificationHour": notificationHour,
    "notificationMinute": notificationMinute,
    "notificationsEnabled": notificationsEnabled,
  };

  factory Settings.fromJson(Map<String, Object?> json) {
    final settings = Settings(
      maximum: readField<int>(json, "maximum"),
      quotaMode: QuotaMode.values.byName(readField<String>(json, "quotaMode")),
      pace: ReductionPace.values.byName(readField<String>(json, "pace")),
      drawPolicy: DrawPolicy.values.byName(
        readField<String>(json, "drawPolicy"),
      ),
      notificationHour: readField<int>(json, "notificationHour"),
      notificationMinute: readField<int>(json, "notificationMinute"),
      notificationsEnabled: readField<bool>(json, "notificationsEnabled"),
    );
    if (settings.maximum < minMaximum || settings.maximum > maxMaximum) {
      throw FormatException("Maximum out of range: ${settings.maximum}");
    }
    if (settings.notificationHour < 0 || settings.notificationHour > 23) {
      throw FormatException("Hour out of range: ${settings.notificationHour}");
    }
    if (settings.notificationMinute < 0 || settings.notificationMinute > 59) {
      throw FormatException(
        "Minute out of range: ${settings.notificationMinute}",
      );
    }
    return settings;
  }

  @override
  List<Object?> get props => [
    maximum,
    quotaMode,
    pace,
    drawPolicy,
    notificationHour,
    notificationMinute,
    notificationsEnabled,
  ];
}
