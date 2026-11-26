import 'package:infra_meter_vl/infra_meter_vl.dart';

import 'meter_vl_native_availability.dart';

/// ネイティブ [MeterVlNativeAvailability.status] を [MeterVlReadiness] へ写す。
///
/// 既知以外の status は [MeterVlReadiness.unavailable] とする。
///
/// Example:
/// ```dart
/// mapPluginMeterVlReadiness(
///   const MeterVlNativeAvailability(
///     status: 'ready',
///     reason: 'ready',
///     message: 'ok',
///   ),
/// );
/// ```
MeterVlReadiness mapPluginMeterVlReadiness(
  MeterVlNativeAvailability availability,
) {
  switch (availability.status) {
    case 'ready':
      return MeterVlReadiness.ready;
    case 'modelNotDownloaded':
      return MeterVlReadiness.modelNotDownloaded;
    default:
      return MeterVlReadiness.unavailable;
  }
}
