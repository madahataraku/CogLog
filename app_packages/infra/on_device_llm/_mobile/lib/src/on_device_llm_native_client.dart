import 'dart:typed_data';

import 'on_device_llm_native_availability.dart';
import 'on_device_llm_native_platform_info.dart';

/// OS オンデバイス LLM への MethodChannel 窓口。
///
/// Example:
/// ```dart
/// final OnDeviceLlmNativeClient client =
///     MethodChannelOnDeviceLlmNativeClient();
/// ```
abstract interface class OnDeviceLlmNativeClient {
  /// 可用性を問い合わせる。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelOnDeviceLlmNativeClient();
  /// await client.getAvailability();
  /// ```
  Future<OnDeviceLlmNativeAvailability> getAvailability();

  /// プラットフォーム診断を問い合わせる。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelOnDeviceLlmNativeClient();
  /// await client.getPlatformInfo();
  /// ```
  Future<OnDeviceLlmNativePlatformInfo> getPlatformInfo();

  /// 短文を生成する。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelOnDeviceLlmNativeClient();
  /// await client.generate(prompt: 'hi');
  /// ```
  Future<String> generate({required String prompt});

  /// [imageBytes] 付きで短文を生成する。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelOnDeviceLlmNativeClient();
  /// await client.generateWithImage(
  ///   prompt: 'hi',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  });

  /// readiness を見ずに生成を試す。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelOnDeviceLlmNativeClient();
  /// await client.diagnoseGenerate(prompt: 'ping');
  /// ```
  Future<String> diagnoseGenerate({required String prompt});

  /// モデル準備（ダウンロード）を依頼する。
  ///
  /// Example:
  /// ```dart
  /// final client = MethodChannelOnDeviceLlmNativeClient();
  /// await client.prepare();
  /// ```
  Future<void> prepare();
}
