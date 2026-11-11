import 'dart:typed_data';

import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';

void main() {
  test('利用可のとき固定文を返す', () async {
    final llm = FakeOnDeviceLlm(response: '今日はよく動けた');
    expect(await llm.readiness, OnDeviceLlmReadiness.ready);
    expect(await llm.isAvailable, isTrue);
    expect(await llm.generate('prompt'), '今日はよく動けた');
    expect(llm.generateCallCount, 1);
    expect(llm.lastPrompt, 'prompt');
  });

  test('supportsVision 既定は false', () async {
    expect(await FakeOnDeviceLlm().supportsVision, isFalse);
    expect(
      await FakeOnDeviceLlm(supportsVisionValue: true).supportsVision,
      isTrue,
    );
  });

  test('generateWithImage は固定文と画像を記録する', () async {
    final llm = FakeOnDeviceLlm(response: 'DISTANCE_KM=1');
    final bytes = Uint8List.fromList([1, 2]);
    expect(
      await llm.generateWithImage(prompt: 'panel', imageBytes: bytes),
      'DISTANCE_KM=1',
    );
    expect(llm.generateWithImageCallCount, 1);
    expect(llm.lastPrompt, 'panel');
    expect(llm.lastImageBytes, bytes);
  });

  test('throwOnGenerate で失敗する', () async {
    final llm = FakeOnDeviceLlm(throwOnGenerate: true);
    expect(await llm.isAvailable, isTrue);
    await expectLater(llm.generate('x'), throwsStateError);
    expect(llm.generateCallCount, 1);
  });

  test('throwOnGenerate は generateWithImage にも効く', () async {
    final llm = FakeOnDeviceLlm(throwOnGenerate: true);
    await expectLater(
      llm.generateWithImage(prompt: 'x', imageBytes: Uint8List(0)),
      throwsStateError,
    );
  });

  test('available false を返す', () async {
    final llm = FakeOnDeviceLlm(available: false);
    expect(await llm.readiness, OnDeviceLlmReadiness.unavailable);
    expect(await llm.isAvailable, isFalse);
  });

  test('modelNotDownloaded を返す', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.modelNotDownloaded,
    );
    expect(await llm.readiness, OnDeviceLlmReadiness.modelNotDownloaded);
    expect(await llm.isAvailable, isFalse);
  });

  test('throwOnIsAvailable で失敗する', () async {
    final llm = FakeOnDeviceLlm(throwOnIsAvailable: true);
    await expectLater(llm.isAvailable, throwsStateError);
  });

  test('prepareModel の呼出を数える', () async {
    final llm = FakeOnDeviceLlm();
    await llm.prepareModel();
    expect(llm.prepareModelCallCount, 1);
  });
}
