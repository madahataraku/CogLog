/// 撮影日時として採用してよい最早（端末ローカル壁時計）。これより前は極端な過去。
final earliestAcceptableMeterPhotoCapturedAt = DateTime(2000, 1, 1);

/// [now] より先に許すクロックスキュー余裕。これを超える未来は異常。
const meterPhotoCapturedAtFutureSkew = Duration(days: 1);

/// [candidate] が撮影日時として採用可能なら true。
///
/// Example:
/// ```dart
/// isAcceptableMeterPhotoCapturedAt(
///   DateTime(2024, 5, 18),
///   now: DateTime.timestamp(),
/// );
/// ```
bool isAcceptableMeterPhotoCapturedAt(
  DateTime candidate, {
  required DateTime now,
}) {
  if (candidate.isBefore(earliestAcceptableMeterPhotoCapturedAt)) {
    return false;
  }
  if (candidate.isAfter(now.add(meterPhotoCapturedAtFutureSkew))) {
    return false;
  }
  return true;
}
