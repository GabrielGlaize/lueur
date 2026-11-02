/// Stored data exists but cannot be read. The user chooses to reset it.
class StorageCorruptedException implements Exception {
  const StorageCorruptedException(this.key, this.cause);

  final String key;
  final Object cause;

  @override
  String toString() => "StorageCorruptedException($key): $cause";
}
