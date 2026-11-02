/// Strict JSON field access. A missing or mistyped field means the stored data
/// is corrupted, so it raises instead of inventing a value.
T readField<T>(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! T) {
    throw FormatException("Field \"$key\" is missing or not a $T", json);
  }
  return value;
}
