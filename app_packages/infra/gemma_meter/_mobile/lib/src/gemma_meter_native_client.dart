import 'dart:typed_data';

import 'gemma_meter_native_availability.dart';

/// Gemma メーター経路への MethodChannel / EventChannel 窓口。
///
/// Example:
/// ```dart
/// final GemmaMeterNativeClient client =
///     MethodChannelGemmaMeterNativeClient();
/// ```
abstract interface class GemmaMeterNativeClient {
  /// ネイティブの可用性スナップショットを返す。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelGemmaMeterNativeClient();
  /// await client.getAvailability();
  /// ```
  Future<GemmaMeterNativeAvailability> getAvailability();

  /// [prompt] と [imageBytes] で短文を生成する。
  ///
  /// 呼び出し側で ready を確認してから使う想定。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelGemmaMeterNativeClient();
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
  /// final client = MethodChannelGemmaMeterNativeClient();
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
  /// final client = MethodChannelGemmaMeterNativeClient();
  /// await for (final progress in client.prepareModel()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> prepareModel();
}
