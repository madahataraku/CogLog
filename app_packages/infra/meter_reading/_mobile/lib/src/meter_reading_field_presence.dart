import 'package:domain_exercise_history/domain_exercise_history.dart';

/// [values] の各フィールド有無だけをログ向けにする（数値は出さない）。
///
/// Example:
/// ```dart
/// formatMeterReadingFieldPresence(
///   const MeterReadingValues(distanceKm: 1),
/// );
/// ```
String formatMeterReadingFieldPresence(MeterReadingValues values) {
  final present = <String>[];
  final missing = <String>[];
  void classify(String name, Object? value) {
    if (value == null) {
      missing.add(name);
    } else {
      present.add(name);
    }
  }

  classify('distanceKm', values.distanceKm);
  classify('duration', values.duration);
  classify('caloriesKcal', values.caloriesKcal);
  classify('averageSpeedKmh', values.averageSpeedKmh);
  return 'present=[${present.join(',')}]; missing=[${missing.join(',')}]';
}
