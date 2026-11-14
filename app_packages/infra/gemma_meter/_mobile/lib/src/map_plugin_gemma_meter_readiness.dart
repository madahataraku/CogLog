import 'package:infra_gemma_meter/infra_gemma_meter.dart';

import 'gemma_meter_native_availability.dart';

/// ネイティブ [GemmaMeterNativeAvailability.status] を [GemmaMeterReadiness] へ写す。
///
/// 既知以外の status は [GemmaMeterReadiness.unavailable] とする。
///
/// Example:
/// ```dart
/// mapPluginGemmaMeterReadiness(
///   const GemmaMeterNativeAvailability(
///     status: 'ready',
///     reason: 'ready',
///     message: 'ok',
///   ),
/// );
/// ```
GemmaMeterReadiness mapPluginGemmaMeterReadiness(
  GemmaMeterNativeAvailability availability,
) {
  switch (availability.status) {
    case 'ready':
      return GemmaMeterReadiness.ready;
    case 'modelNotDownloaded':
      return GemmaMeterReadiness.modelNotDownloaded;
    default:
      return GemmaMeterReadiness.unavailable;
  }
}
