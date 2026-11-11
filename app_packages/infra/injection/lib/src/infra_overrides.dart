import 'package:flutter/foundation.dart';
import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:infra_app_runtime_info_mobile/infra_app_runtime_info_mobile.dart';
import 'package:infra_app_settings/infra_app_settings.dart';
import 'package:infra_app_settings_mobile/infra_app_settings_mobile.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_mobile/infra_health_body_metrics_mobile.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:infra_health_workout_mobile/infra_health_workout_mobile.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:infra_local_notification_mobile/infra_local_notification_mobile.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:infra_meter_photo_mobile/infra_meter_photo_mobile.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';
import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:infra_oss_license_catalog_impl/infra_oss_license_catalog_impl.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

/// 端末上 LLM など infra の本番実装を上書きする。
///
/// [onDeviceLlm] / [meterPhotoSource] / [healthBodyMetricsSource] を渡すと、
/// その実装を使う（Widget テスト用）。
///
/// Example:
/// ```dart
/// infraOverrides();
/// ```
List<Override> infraOverrides({
  OnDeviceLlm? onDeviceLlm,
  MeterPhotoSource? meterPhotoSource,
  HealthBodyMetricsSource? healthBodyMetricsSource,
}) => [
  onDeviceLlmProvider.overrideWith((ref) {
    final injected = onDeviceLlm;
    if (injected != null) {
      return injected;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return PluginOnDeviceLlm();
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
  meterReadingEnginesProvider.overrideWith((ref) => _meterReadingEngines(ref)),
  healthWorkoutWriterProvider.overrideWith(
    (ref) => const UnavailableHealthWorkoutWriter(),
  ),
  healthBodyMetricsSourceProvider.overrideWith((ref) {
    final injected = healthBodyMetricsSource;
    if (injected != null) {
      return injected;
    }
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
  localNotificationGatewayProvider.overrideWith((ref) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return FlutterLocalNotificationsGateway();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const UnavailableLocalNotificationGateway();
    }
  }),
  AppRuntimeInfoReader.provider.overrideWith(
    (ref) => const PackageDeviceAppRuntimeInfoReader(),
  ),
  OssLicenseCatalog.provider.overrideWith(
    (ref) => const GeneratedOssLicenseCatalog(),
  ),
];

/// OS ごとの読み取りエンジン列。iOS は Vision→Foundation、Android は ML Kit→Gemini Nano。
///
/// Example:
/// ```dart
/// _meterReadingEngines(ref);
/// ```
List<MeterReadingEngine> _meterReadingEngines(Ref ref) {
  final llm = ref.watch(onDeviceLlmProvider);
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return [
        OcrMeterReadingEngine(
          kind: MeterReadingEngineKind.visionOcr,
          recognizer: VisionMeterTextRecognizer(),
        ),
        LlmMeterReadingEngine(
          kind: MeterReadingEngineKind.foundationModel,
          llm: llm,
        ),
      ];
    case TargetPlatform.android:
      return [
        OcrMeterReadingEngine(
          kind: MeterReadingEngineKind.mlKit,
          recognizer: MlKitMeterTextRecognizer(),
        ),
        LlmMeterReadingEngine(
          kind: MeterReadingEngineKind.geminiNano,
          llm: llm,
        ),
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
