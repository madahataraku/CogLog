import 'package:flutter_device_ai/flutter_device_ai.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';

import 'map_flutter_device_ai_readiness.dart';

/// `flutter_device_ai` のネイティブモデルだけを使う [OnDeviceLlm]。
///
/// GGUF ローカルフォールバックは付けない。
///
/// Example:
/// ```dart
/// FlutterDeviceAiOnDeviceLlm();
/// ```
final class FlutterDeviceAiOnDeviceLlm implements OnDeviceLlm {
  /// [ai] を省略するとフォールバック無しの共有インスタンスを使う。
  ///
  /// Example:
  /// ```dart
  /// FlutterDeviceAiOnDeviceLlm();
  /// ```
  FlutterDeviceAiOnDeviceLlm({FlutterDeviceAi? ai})
    : _ai = ai ?? FlutterDeviceAi();

  /// ネイティブ推論に使うクライアント（フォールバック無し）。
  final FlutterDeviceAi _ai;

  /// ネイティブ可否を [mapFlutterDeviceAiReadiness] で写す。失敗時は unavailable。
  ///
  /// Example:
  /// ```dart
  /// await FlutterDeviceAiOnDeviceLlm().readiness;
  /// ```
  @override
  Future<OnDeviceLlmReadiness> get readiness async {
    try {
      return mapFlutterDeviceAiReadiness(await _ai.availability());
    } on Object {
      // ネイティブ availability 例外は利用不可として扱う。
      return OnDeviceLlmReadiness.unavailable;
    }
  }

  /// [readiness] が ready のとき true。
  ///
  /// Example:
  /// ```dart
  /// await FlutterDeviceAiOnDeviceLlm().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async =>
      (await readiness) == OnDeviceLlmReadiness.ready;

  /// ネイティブ availability と platformInfo を診断スナップショットへ写す。
  ///
  /// Example:
  /// ```dart
  /// await FlutterDeviceAiOnDeviceLlm().availabilitySnapshot;
  /// ```
  @override
  Future<OnDeviceLlmAvailabilitySnapshot> get availabilitySnapshot async {
    try {
      final availability = await _ai.availability();
      String? backend;
      String? platformNotes;
      try {
        final info = await _ai.getPlatformInfo();
        backend = info.backend.name;
        platformNotes = info.diagnosticNotes;
      } on Object {
        // platformInfo 失敗は availability 本体の診断を優先する。
      }
      return OnDeviceLlmAvailabilitySnapshot(
        readiness: mapFlutterDeviceAiReadiness(availability),
        status: availability.status.name,
        reason: availability.reason.name,
        message: availability.message,
        backend: backend,
        platformNotes: platformNotes,
      );
    } on Object catch (error) {
      return OnDeviceLlmAvailabilitySnapshot(
        readiness: OnDeviceLlmReadiness.unavailable,
        status: 'error',
        reason: 'exception',
        message: 'availability failed',
        error: error.toString(),
      );
    }
  }

  /// ネイティブ生成の本文を返す。ready でなければ失敗する。
  ///
  /// Example:
  /// ```dart
  /// await FlutterDeviceAiOnDeviceLlm().generate('hello');
  /// ```
  @override
  Future<String> generate(String prompt) async {
    if (!await isAvailable) {
      throw StateError('OnDeviceLlm is not ready');
    }
    final response = await _ai.generateText(prompt: prompt);
    return response.text;
  }

  /// OS にモデル準備を依頼する。
  ///
  /// Example:
  /// ```dart
  /// await FlutterDeviceAiOnDeviceLlm().prepareModel();
  /// ```
  @override
  Future<void> prepareModel() async {
    await _ai.prepare();
  }
}
