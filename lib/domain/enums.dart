enum QuotaMode { guided, fullRandom }

enum ReductionPace { gentle, balanced, bold }

/// What happens to today's quota when settings change.
enum DrawPolicy { frozen, recalculating }

extension QuotaModeUi on QuotaMode {
  String get label => switch (this) {
    QuotaMode.guided => "Progressif",
    QuotaMode.fullRandom => "Hasard total",
  };

  String get description => switch (this) {
    QuotaMode.guided =>
      "L’allure définit une fourchette autour de ton maximum.",
    QuotaMode.fullRandom => "Chaque jour, un nombre de 1 jusqu’à ton maximum.",
  };
}

extension ReductionPaceUi on ReductionPace {
  String get label => switch (this) {
    ReductionPace.gentle => "Douce",
    ReductionPace.balanced => "Équilibre",
    ReductionPace.bold => "Intense",
  };

  String get description => switch (this) {
    ReductionPace.gentle => "Petits pas, sans pression",
    ReductionPace.balanced => "Un défi juste et tenable",
    ReductionPace.bold => "Une baisse plus franche",
  };

  double get minimumRatio => switch (this) {
    ReductionPace.gentle => .68,
    ReductionPace.balanced => .42,
    ReductionPace.bold => .18,
  };

  double get maximumRatio => switch (this) {
    ReductionPace.gentle => 1,
    ReductionPace.balanced => .78,
    ReductionPace.bold => .52,
  };
}

extension DrawPolicyUi on DrawPolicy {
  String get label => switch (this) {
    DrawPolicy.frozen => "Figé",
    DrawPolicy.recalculating => "Recalculé",
  };

  String get description => switch (this) {
    DrawPolicy.frozen =>
      "Le quota du jour ne bouge plus une fois tiré. Tes nouveaux réglages valent dès demain.",
    DrawPolicy.recalculating =>
      "Si tu changes ton maximum ou ton allure, le quota d’aujourd’hui est tiré à nouveau.",
  };
}
