/// Local calendar-day helpers. Days are keyed as `yyyy-MM-dd` in local time.
String dateKeyOf(DateTime date) =>
    "${date.year.toString().padLeft(4, "0")}-"
    "${date.month.toString().padLeft(2, "0")}-"
    "${date.day.toString().padLeft(2, "0")}";

DateTime dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

/// Calendar arithmetic, safe across daylight-saving changes.
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

typedef Clock = DateTime Function();
