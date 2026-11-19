/// 走行距離 km をヘルス書き込み用のメートル整数へ写す。
///
/// Example:
/// ```dart
/// distanceKmToMeters(12.3);
/// ```
int distanceKmToMeters(double distanceKm) => (distanceKm * 1000).round();

/// 消費カロリー kcal をヘルス書き込み用の整数へ写す。
///
/// Example:
/// ```dart
/// caloriesKcalToInt(300.4);
/// ```
int caloriesKcalToInt(double caloriesKcal) => caloriesKcal.round();

/// [writeWorkoutDataUUID] が返し得る不正 UUID を弾く。
///
/// Example:
/// ```dart
/// isValidWorkoutUuid('abc');
/// ```
bool isValidWorkoutUuid(String? uuid) =>
    uuid != null && uuid.isNotEmpty && uuid != 'null';

/// Android の WRITE 許可マップがすべて true か。
///
/// Example:
/// ```dart
/// allWritePermissionsGranted({'WORKOUT': true});
/// ```
bool allWritePermissionsGranted(Map<Object, bool?> grantedByType) {
  if (grantedByType.isEmpty) {
    return false;
  }
  for (final value in grantedByType.values) {
    if (value != true) {
      return false;
    }
  }
  return true;
}
