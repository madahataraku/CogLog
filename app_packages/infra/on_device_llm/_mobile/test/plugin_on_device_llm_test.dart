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
    this.throwOnAvailability = false,
  });

  /// 返す可用性。
  OnDeviceLlmNativeAvailability availability;

  /// 生成本文の接頭辞。
  final String replyPrefix = 'reply:';

  /// true のとき [getAvailability] が失敗する。
  final bool throwOnAvailability;

  /// [prepare] が呼ばれたか。
  bool prepareCalled = false;

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

  /// Android 風の診断情報を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().getPlatformInfo();
  /// ```
  @override
  Future<OnDeviceLlmNativePlatformInfo> getPlatformInfo() async =>
      const OnDeviceLlmNativePlatformInfo(
        backend: 'androidMlKitGenAi',
        diagnosticNotes: 'modelReady=true',
      );

  /// [replyPrefix] 付きで [prompt] を返す。
  ///
  /// Example:
  /// ```dart
  /// await _FakeClient().generate(prompt: 'hi');
  /// ```
  @override
  Future<String> generate({required String prompt}) async =>
      '$replyPrefix$prompt';

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
