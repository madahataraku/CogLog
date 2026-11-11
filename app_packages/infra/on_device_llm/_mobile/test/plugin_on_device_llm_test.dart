import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';
import 'package:infra_on_device_llm_mobile/src/on_device_llm_native_availability.dart';
import 'package:infra_on_device_llm_mobile/src/on_device_llm_native_client.dart';
import 'package:infra_on_device_llm_mobile/src/on_device_llm_native_platform_info.dart';

/// [PluginOnDeviceLlm] 向けの固定応答クライアント。
final class _FakeClient implements OnDeviceLlmNativeClient {
  /// [availability] と例外フラグで振る舞いを固定する。
  ///
  /// Example:
  /// ```dart
  /// _FakeClient(throwOnAvailability: true);
  /// ```
  _FakeClient({
    this.availability = const OnDeviceLlmNativeAvailability(
      status: 'available',
      reason: 'ready',
      message: 'ok',
    ),
    this.platformInfo = const OnDeviceLlmNativePlatformInfo(
      backend: 'androidMlKitGenAi',
      diagnosticNotes: 'modelReady=true',
      supportsVision: true,
    ),
    this.throwOnAvailability = false,
  });

  /// 返す可用性。
  OnDeviceLlmNativeAvailability availability;

  /// 返すプラットフォーム診断。
  OnDeviceLlmNativePlatformInfo platformInfo;

  /// 生成本文の接頭辞。
  final String replyPrefix = 'reply:';

  /// true のとき [getAvailability] が失敗する。
  final bool throwOnAvailability;

  /// [prepare] が呼ばれたか。
  bool prepareCalled = false;

  /// 最後に [generateWithImage] へ渡された画像。
  Uint8List? lastImageBytes;

  /// 固定した [availability] を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().getAvailability();
  /// ```
  @override
  Future<OnDeviceLlmNativeAvailability> getAvailability() async {
    if (throwOnAvailability) {
      throw StateError('boom');
    }
    return availability;
  }

  /// [platformInfo] を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().getPlatformInfo();
  /// ```
  @override
  Future<OnDeviceLlmNativePlatformInfo> getPlatformInfo() async => platformInfo;

  /// [replyPrefix] 付きで [prompt] を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().generate(prompt: 'hi');
  /// ```
  @override
  Future<String> generate({required String prompt}) async =>
      '$replyPrefix$prompt';

  /// 画像付きで [replyPrefix] 付き本文を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().generateWithImage(
  ///   prompt: 'hi',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    lastImageBytes = imageBytes;
    return '$replyPrefix$prompt';
  }

  /// 診断用に `diag:` 接頭辞で [prompt] を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().diagnoseGenerate(prompt: 'ping');
  /// ```
  @override
  Future<String> diagnoseGenerate({required String prompt}) async =>
      'diag:$prompt';

  /// 呼び出しを記録し、可用性を ready にする。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().prepare();
  /// ```
  @override
  Future<void> prepare() async {
    prepareCalled = true;
    availability = const OnDeviceLlmNativeAvailability(
      status: 'available',
      reason: 'ready',
      message: 'ok',
    );
  }
}

void main() {
  test('availability available → ready', () async {
    final llm = PluginOnDeviceLlm(client: _FakeClient());
    expect(await llm.readiness, OnDeviceLlmReadiness.ready);
    expect(await llm.isAvailable, isTrue);
  });

  test('downloadable → modelNotDownloaded', () async {
    final llm = PluginOnDeviceLlm(
      client: _FakeClient(
        availability: const OnDeviceLlmNativeAvailability(
          status: 'downloadable',
          reason: 'modelNotReady',
          message: 'need download',
        ),
      ),
    );
    expect(await llm.readiness, OnDeviceLlmReadiness.modelNotDownloaded);
    expect(await llm.isAvailable, isFalse);
  });

  test('非 ready で generate は StateError', () async {
    final llm = PluginOnDeviceLlm(
      client: _FakeClient(
        availability: const OnDeviceLlmNativeAvailability(
          status: 'unavailable',
          reason: 'deviceNotEligible',
          message: 'no',
        ),
      ),
    );
    await expectLater(llm.generate('hello'), throwsStateError);
  });

  test('ready で generate は本文を返す', () async {
    final text = await PluginOnDeviceLlm(client: _FakeClient()).generate('hi');
    expect(text, 'reply:hi');
  });

  test('supportsVision は platformInfo を写す', () async {
    final llm = PluginOnDeviceLlm(
      client: _FakeClient(
        platformInfo: const OnDeviceLlmNativePlatformInfo(
          backend: 'iosFoundationModels',
          supportsVision: false,
        ),
      ),
    );
    expect(await llm.supportsVision, isFalse);
  });

  test('ready で generateWithImage は本文を返す', () async {
    final client = _FakeClient();
    final bytes = Uint8List.fromList([1, 2, 3]);
    final text = await PluginOnDeviceLlm(client: client)
        .generateWithImage(prompt: 'panel', imageBytes: bytes);
    expect(text, 'reply:panel');
    expect(client.lastImageBytes, bytes);
  });

  test('非 ready で generateWithImage は StateError', () async {
    final llm = PluginOnDeviceLlm(
      client: _FakeClient(
        availability: const OnDeviceLlmNativeAvailability(
          status: 'unavailable',
          reason: 'deviceNotEligible',
          message: 'no',
        ),
      ),
    );
    await expectLater(
      llm.generateWithImage(prompt: 'x', imageBytes: Uint8List(0)),
      throwsStateError,
    );
  });

  test('prepareModel は client.prepare を呼ぶ', () async {
    final fake = _FakeClient(
      availability: const OnDeviceLlmNativeAvailability(
        status: 'downloadable',
        reason: 'modelNotReady',
        message: 'need',
      ),
    );
    await PluginOnDeviceLlm(client: fake).prepareModel();
    expect(fake.prepareCalled, isTrue);
  });

  test('availability 例外時 snapshot は unavailable', () async {
    final snapshot = await PluginOnDeviceLlm(
      client: _FakeClient(throwOnAvailability: true),
    ).availabilitySnapshot;
    expect(snapshot.readiness, OnDeviceLlmReadiness.unavailable);
    expect(snapshot.status, 'error');
    expect(snapshot.error, isNotNull);
  });

  test('diagnoseGenerate は readiness を問わない', () async {
    final text = await PluginOnDeviceLlm(
      client: _FakeClient(
        availability: const OnDeviceLlmNativeAvailability(
          status: 'unavailable',
          reason: 'deviceNotEligible',
          message: 'no',
        ),
      ),
    ).diagnoseGenerate('ping');
    expect(text, 'diag:ping');
  });
}
