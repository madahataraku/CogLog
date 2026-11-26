import 'dart:typed_data';

import 'meter_vl_native_availability.dart';

/// メーター VL 経路への MethodChannel / EventChannel 窓口。
///
/// Example:
/// ```dart
/// final MeterVlNativeClient client =
///     MethodChannelMeterVlNativeClient();
/// ```
abstract interface class MeterVlNativeClient {
  /// ネイティブの可用性スナップショットを返す。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelMeterVlNativeClient();
  /// await client.getAvailability();
  /// ```
  Future<MeterVlNativeAvailability> getAvailability();

  /// [prompt] と [imageBytes] で短文を生成する。
  ///
  /// 呼び出し側で ready を確認してから使う想定。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelMeterVlNativeClient();
  /// await client.generateWithImage(
  ///   prompt: 'hi',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  });

  /// readiness を見ずに生成を試す診断用入口。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelMeterVlNativeClient();
  /// await client.diagnoseGenerateWithImage(
  ///   prompt: 'ping',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  });

  /// モデル準備（ダウンロード）の進捗（0.0〜1.0 想定）を流す。
  ///
  /// 失敗はストリームの error として届く。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelMeterVlNativeClient();
  /// await for (final progress in client.prepareModel()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> prepareModel();

  /// モデル成果物・stamp・engine・legacy Gemma を削除する。
  ///
  /// Example:
  /// ```dart
  /// await client.deleteDownloadedModels();
  /// ```
  Future<void> deleteDownloadedModels();

  /// prepare / generate 実行中なら true。
  ///
  /// Example:
  /// ```dart
  /// await client.isOperationBusy;
  /// ```
  Future<bool> get isOperationBusy;
}
