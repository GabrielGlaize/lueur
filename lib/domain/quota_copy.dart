import "enums.dart";
import "settings.dart";

/// User-facing wording tied to a quota. Kept free of judgement on purpose.
abstract final class QuotaCopy {
  static String cigarettes(int count) =>
      count > 1 ? "$count cigarettes" : "$count cigarette";

  static String dayMessage(int quota, int maximum) {
    if (quota == 0) {
      return "Aujourd’hui, on tente une journée sans. Une envie passe toujours.";
    }
    final ratio = quota / maximum;
    if (ratio <= .35) {
      return "Petit nombre, grande journée. Garde-les pour les moments qui comptent.";
    }
    if (ratio <= .6) {
      return "Le défi est là, mais il est à ta portée. Un moment après l’autre.";
    }
    if (ratio < .9) {
      return "Une marge douce pour avancer sans te brusquer.";
    }
    return "Journée tranquille. Observer ses habitudes, c’est déjà avancer.";
  }

  static String statusMessage(int smoked, int quota) {
    if (smoked > quota) {
      return "Quota dépassé aujourd’hui. Ce n’est pas grave : demain repart à zéro.";
    }
    if (smoked == quota) {
      return "Quota atteint. Le prochain choix t’appartient.";
    }
    final left = quota - smoked;
    return left > 1 ? "Il t’en reste $left." : "Il t’en reste une.";
  }

  static String notificationBody(int quota, Settings settings) {
    final lead = quota == 0
        ? "Aujourd’hui : une journée sans, si tu veux bien."
        : "Aujourd’hui : ${cigarettes(quota)} au maximum.";
    final tail = settings.quotaMode == QuotaMode.fullRandom
        ? "Le hasard a parlé, à toi de choisir tes moments."
        : switch (settings.pace) {
            ReductionPace.gentle => "Doucement, mais sûrement.",
            ReductionPace.balanced => "Tu peux le faire.",
            ReductionPace.bold => "Respire, puis choisis.",
          };
    return "$lead $tail";
  }
}
