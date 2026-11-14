import 'package:flutter/foundation.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:infra_app_runtime_info_mobile/infra_app_runtime_info_mobile.dart';
import 'package:infra_app_settings/infra_app_settings.dart';
import 'package:infra_app_settings_mobile/infra_app_settings_mobile.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_mobile/infra_gemma_meter_mobile.dart';
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
import 'package:infra_network_connectivity/infra_network_connectivity.dart';
import 'package:infra_network_connectivity_mobile/infra_network_connectivity_mobile.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';
import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:infra_oss_license_catalog_impl/infra_oss_license_catalog_impl.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

/// 端末上 LLM など infra の本番実装を上書きする。
///
/// [onDeviceLlm] / [gemmaMeterVision] / [meterPhotoSource] /
/// [healthBodyMetricsSource] / [networkConnectivity] を渡すと、
/// その実装を使う（Widget テスト用）。
///
/// Example:
/// ```dart
/// infraOverrides();
/// ```
List<Override> infraOverrides({
  OnDeviceLlm? onDeviceLlm,
  GemmaMeterVision? gemmaMeterVision,
  MeterPhotoSource? meterPhotoSource,
  HealthBodyMetricsSource? healthBodyMetricsSource,
  NetworkConnectivity? networkConnectivity,
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
  gemmaMeterVisionProvider.overrideWith(
    (ref) => gemmaMeterVision ?? const UnavailableGemmaMeterVision(),
  ),
  networkConnectivityProvider.overrideWith(
    (ref) => networkConnectivity ?? ConnectivityPlusNetworkConnectivity(),
  ),
  meterPhotoSourceProvider.overrideWith(
    (ref) => meterPhotoSource ?? MobileMeterPhotoSource(),
  ),
  meterReadingEnginesProvider.overrideWith((ref) => _meterReadingEngines(ref)),
  meterReadingLlmEngineProvider.overrideWith(
    (ref) => _meterReadingLlmEngine(ref),
  ),
  meterReadingGemmaEngineProvider.overrideWith(
    (ref) => GemmaMeterReadingEngine(
      gemma: ref.watch(gemmaMeterVisionProvider),
      log: ref.watch(appLogStoreProvider),
    ),
  ),
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

/// LLM メーター読み取りエンジン。
///
/// Example:
/// ```dart
/// _meterReadingLlmEngine(ref);
/// ```
MeterReadingEngine _meterReadingLlmEngine(Ref ref) {
  final llm = ref.watch(onDeviceLlmProvider);
  final log = ref.watch(appLogStoreProvider);
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return LlmMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
        llm: llm,
        log: log,
      );
    case TargetPlatform.android:
      return LlmMeterReadingEngine(
        kind: MeterReadingEngineKind.geminiNano,
        llm: llm,
        log: log,
      );
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return const UnavailableMeterReadingEngine(
        MeterReadingEngineKind.geminiNano,
      );
  }
}

/// デバッグ／一覧用の LLM + Gemma エンジン。
///
/// Example:
/// ```dart
/// _meterReadingEngines(ref);
/// ```
List<MeterReadingEngine> _meterReadingEngines(Ref ref) => [
  _meterReadingLlmEngine(ref),
  ref.watch(meterReadingGemmaEngineProvider),
];
