import 'package:flutter_device_ai/flutter_device_ai.dart';
import 'package:flutter_device_ai/flutter_device_ai_method_channel.dart';
import 'package:flutter_device_ai/flutter_device_ai_platform_interface.dart';
import 'package:flutter_device_ai/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';

void main() {
  tearDown(() {
    FlutterDeviceAiPlatform.instance = MethodChannelFlutterDeviceAi();
  });

  test('availability available → ready', () async {
    FlutterDeviceAiPlatform.instance = FakeOnDeviceAiPlatform(
      availability: const OnDeviceAiAvailability(
        status: ModelFeatureStatus.available,
        reason: AvailabilityReason.ready,
        message: 'ok',
      ),
    );
    final llm = FlutterDeviceAiOnDeviceLlm();
    expect(await llm.readiness, OnDeviceLlmReadiness.ready);
    expect(await llm.isAvailable, isTrue);
  });

  test('downloadable → modelNotDownloaded', () async {
    FlutterDeviceAiPlatform.instance = FakeOnDeviceAiPlatform(
      availability: const OnDeviceAiAvailability(
        status: ModelFeatureStatus.downloadable,
        reason: AvailabilityReason.modelNotReady,
        message: 'need download',
      ),
    );
    final llm = FlutterDeviceAiOnDeviceLlm();
    expect(await llm.readiness, OnDeviceLlmReadiness.modelNotDownloaded);
    expect(await llm.isAvailable, isFalse);
  });

  test('非 ready で generate は StateError', () async {
    FlutterDeviceAiPlatform.instance = FakeOnDeviceAiPlatform(
      availability: const OnDeviceAiAvailability(
        status: ModelFeatureStatus.unavailable,
        reason: AvailabilityReason.deviceNotEligible,
        message: 'no',
      ),
    );
    await expectLater(
      FlutterDeviceAiOnDeviceLlm().generate('hello'),
      throwsStateError,
    );
  });

  test('ready で generate は本文を返す', () async {
    FlutterDeviceAiPlatform.instance = FakeOnDeviceAiPlatform(
      responder: (prompt, _) => 'reply:$prompt',
    );
    final text = await FlutterDeviceAiOnDeviceLlm().generate('hi');
    expect(text, 'reply:hi');
  });

  test('prepareModel は download を開始する', () async {
    final fake = FakeOnDeviceAiPlatform(
      availability: const OnDeviceAiAvailability(
        status: ModelFeatureStatus.downloadable,
        reason: AvailabilityReason.modelNotReady,
        message: 'need',
      ),
    )..downloadEvents = const [
      ModelDownloadStatus(status: ModelFeatureStatus.available, progress: 1),
    ];
    FlutterDeviceAiPlatform.instance = fake;
    await FlutterDeviceAiOnDeviceLlm().prepareModel();
  });
}
