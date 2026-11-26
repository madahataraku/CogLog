import 'dart:typed_data';

import 'package:infra_meter_vl/infra_meter_vl.dart';

import 'meter_vl_native_client.dart';
import 'map_plugin_meter_vl_readiness.dart';
import 'method_channel_meter_vl_native_client.dart';

/// LiteRT-LM を使う [MeterVlVision]（自前 Flutter plugin）。
///
/// Example:
/// ```dart
/// PluginMeterVlVision();
/// ```
final class PluginMeterVlVision implements MeterVlVision {
  /// [client] を省略すると MethodChannel 実装を使う。
  ///
  /// Example:
  /// ```dart
  /// PluginMeterVlVision();
  /// ```
  PluginMeterVlVision({MeterVlNativeClient? client})
    : _client = client ?? MethodChannelMeterVlNativeClient();

  /// ネイティブ問い合わせ先。
  final MeterVlNativeClient _client;

  /// ネイティブ可用性を [mapPluginMeterVlReadiness] で写す。
  ///
  /// 問い合わせ失敗時は [MeterVlReadiness.unavailable] とする。
  ///
  /// Example:
  /// ```dart
  /// await PluginMeterVlVision().readiness;
  /// ```
  @override
  Future<MeterVlReadiness> get readiness async {
    try {
      return mapPluginMeterVlReadiness(await _client.getAvailability());
    } on Object {
      // ネイティブ availability 例外は利用不可として扱う。
      return MeterVlReadiness.unavailable;
    }
  }

  /// [readiness] が ready のとき true。
  ///
  /// Example:
  /// ```dart
  /// await PluginMeterVlVision().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async =>
      (await readiness) == MeterVlReadiness.ready;

  /// ネイティブ可用性を診断スナップショットへ写す。
  ///
  /// 問い合わせ例外時は status `error` / reason `exception` の unavailable とする。
  ///
  /// Example:
  /// ```dart
  /// await PluginMeterVlVision().availabilitySnapshot;
  /// ```
  @override
  Future<MeterVlAvailabilitySnapshot> get availabilitySnapshot async {
    try {
      final availability = await _client.getAvailability();
      return MeterVlAvailabilitySnapshot(
        readiness: mapPluginMeterVlReadiness(availability),
        status: availability.status,
        reason: availability.reason,
        message: availability.message,
        backend: availability.backend,
        visionBackend: availability.visionBackend,
      );
    } on Object catch (error) {
      return MeterVlAvailabilitySnapshot(
        readiness: MeterVlReadiness.unavailable,
        status: 'error',
        reason: 'exception',
        message: error.toString(),
      );
    }
  }

  /// ネイティブ生成の本文を返す。
  ///
  /// [isAvailable] が false のときは [StateError] を投げる。
  ///
  /// Example:
  /// ```dart
  /// await PluginMeterVlVision().generateWithImage(
  ///   prompt: 'hello',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    if (!await isAvailable) {
      throw StateError('MeterVlVision is not ready');
    }
    return _client.generateWithImage(prompt: prompt, imageBytes: imageBytes);
  }

  /// 準備状態を問わずネイティブ生成を試す。
  ///
  /// Example:
  /// ```dart
  /// await PluginMeterVlVision().diagnoseGenerateWithImage(
  ///   prompt: 'ping',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) =>
      _client.diagnoseGenerateWithImage(prompt: prompt, imageBytes: imageBytes);

  /// ネイティブの準備進捗を [MeterVlNativeClient.prepareModel] へ委譲する。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in PluginMeterVlVision().prepareModel()) {
  ///   progress;
  /// }
  /// ```
  @override
  Stream<double> prepareModel() => _client.prepareModel();

  /// ネイティブ client へ削除を委譲する。
  ///
  /// Example:
  /// ```dart
  /// await plugin.deleteDownloadedModels();
  /// ```
  @override
  Future<void> deleteDownloadedModels() => _client.deleteDownloadedModels();

  /// ネイティブ client の busy 判定を委譲する。
  ///
  /// Example:
  /// ```dart
  /// await plugin.isOperationBusy;
  /// ```
  @override
  Future<bool> get isOperationBusy => _client.isOperationBusy;
}
