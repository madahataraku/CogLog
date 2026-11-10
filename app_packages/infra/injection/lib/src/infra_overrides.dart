import 'package:flutter/foundation.dart';
import 'package:infra_app_settings/infra_app_settings.dart';
import 'package:infra_app_settings_mobile/infra_app_settings_mobile.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_mobile/infra_health_body_metrics_mobile.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:infra_health_workout_mobile/infra_health_workout_mobile.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:infra_meter_photo_mobile/infra_meter_photo_mobile.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';
import 'package:riverpod/misc.dart';

/// 端末上 LLM など infra の本番実装を上書きする。
///
/// [onDeviceLlm] / [meterPhotoSource] を渡すと、その実装を使う（Widget テスト用）。
///
/// Example:
/// ```dart
/// infraOverrides();
/// ```
List<Override> infraOverrides({
  OnDeviceLlm? onDeviceLlm,
  MeterPhotoSource? meterPhotoSource,
}) => [
  onDeviceLlmProvider.overrideWith((ref) {
    final injected = onDeviceLlm;
    if (injected != null) {
      return injected;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return FlutterDeviceAiOnDeviceLlm();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const UnavailableOnDeviceLlm();
    }
  }),
  meterPhotoSourceProvider.overrideWith(
    (ref) => meterPhotoSource ?? MobileMeterPhotoSource(),
  ),
  meterReadingEnginesProvider.overrideWith(
    (ref) => _unavailableMeterReadingEngines(),
  ),
  healthWorkoutWriterProvider.overrideWith(
    (ref) => const UnavailableHealthWorkoutWriter(),
  ),
  healthBodyMetricsSourceProvider.overrideWith((ref) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return HealthPackageBodyMetricsSource();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const UnavailableHealthBodyMetricsSource();
    }
  }),
  appSettingsOpenerProvider.overrideWith(
    (ref) => const AppSettingsPackageOpener(),
  ),
];

/// OS ごとの未接続エンジン列。iOS は Vision→Foundation、Android は ML Kit→Gemini Nano。
///
/// Example:
/// ```dart
/// _unavailableMeterReadingEngines();
/// ```
List<MeterReadingEngine> _unavailableMeterReadingEngines() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return const [
        UnavailableMeterReadingEngine(MeterReadingEngineKind.visionOcr),
        UnavailableMeterReadingEngine(MeterReadingEngineKind.foundationModel),
      ];
    case TargetPlatform.android:
      return const [
        UnavailableMeterReadingEngine(MeterReadingEngineKind.mlKit),
        UnavailableMeterReadingEngine(MeterReadingEngineKind.geminiNano),
      ];
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return const [
        UnavailableMeterReadingEngine(MeterReadingEngineKind.mlKit),
        UnavailableMeterReadingEngine(MeterReadingEngineKind.geminiNano),
      ];
  }
}
