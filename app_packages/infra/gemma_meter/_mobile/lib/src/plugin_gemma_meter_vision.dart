import 'dart:typed_data';

import 'package:infra_gemma_meter/infra_gemma_meter.dart';

import 'gemma_meter_native_client.dart';
import 'map_plugin_gemma_meter_readiness.dart';
import 'method_channel_gemma_meter_native_client.dart';

/// LiteRT-LM を使う [GemmaMeterVision]（自前 Flutter plugin）。
///
/// Example:
/// ```dart
/// PluginGemmaMeterVision();
/// ```
final class PluginGemmaMeterVision implements GemmaMeterVision {
  /// [client] を省略すると MethodChannel 実装を使う。
  ///
  /// Example:
  /// ```dart
  /// PluginGemmaMeterVision();
  /// ```
  PluginGemmaMeterVision({GemmaMeterNativeClient? client})
    : _client = client ?? MethodChannelGemmaMeterNativeClient();

  /// ネイティブ問い合わせ先。
  final GemmaMeterNativeClient _client;

  /// ネイティブ可用性を [mapPluginGemmaMeterReadiness] で写す。
  ///
  /// 問い合わせ失敗時は [GemmaMeterReadiness.unavailable] とする。
  ///
  /// Example:
  /// ```dart
  /// await PluginGemmaMeterVision().readiness;
  /// ```
  @override
  Future<GemmaMeterReadiness> get readiness async {
    try {
      return mapPluginGemmaMeterReadiness(await _client.getAvailability());
    } on Object {
      // ネイティブ availability 例外は利用不可として扱う。
      return GemmaMeterReadiness.unavailable;
    }
  }

  /// [readiness] が ready のとき true。
  ///
  /// Example:
  /// ```dart
  /// await PluginGemmaMeterVision().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async =>
      (await readiness) == GemmaMeterReadiness.ready;

  /// ネイティブ可用性を診断スナップショットへ写す。
  ///
  /// 問い合わせ例外時は status `error` / reason `exception` の unavailable とする。
  ///
  /// Example:
  /// ```dart
  /// await PluginGemmaMeterVision().availabilitySnapshot;
  /// ```
  @override
  Future<GemmaMeterAvailabilitySnapshot> get availabilitySnapshot async {
    try {
      final availability = await _client.getAvailability();
      return GemmaMeterAvailabilitySnapshot(
        readiness: mapPluginGemmaMeterReadiness(availability),
        status: availability.status,
        reason: availability.reason,
        message: availability.message,
      );
    } on Object catch (error) {
      return GemmaMeterAvailabilitySnapshot(
        readiness: GemmaMeterReadiness.unavailable,
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
  /// await PluginGemmaMeterVision().generateWithImage(
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
      throw StateError('GemmaMeterVision is not ready');
    }
    return _client.generateWithImage(prompt: prompt, imageBytes: imageBytes);
  }

  /// 準備状態を問わずネイティブ生成を試す。
  ///
  /// Example:
  /// ```dart
  /// await PluginGemmaMeterVision().diagnoseGenerateWithImage(
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

  /// ネイティブの準備進捗を [GemmaMeterNativeClient.prepareModel] へ委譲する。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in PluginGemmaMeterVision().prepareModel()) {
  ///   progress;
  /// }
  /// ```
  @override
  Stream<double> prepareModel() => _client.prepareModel();
}
