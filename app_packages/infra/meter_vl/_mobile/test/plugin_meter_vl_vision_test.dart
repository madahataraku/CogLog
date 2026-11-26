import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_mobile/infra_meter_vl_mobile.dart';
import 'package:infra_meter_vl_mobile/src/meter_vl_native_availability.dart';
import 'package:infra_meter_vl_mobile/src/meter_vl_native_client.dart';

/// [PluginMeterVlVision] 向けの固定応答クライアント。
final class _FakeClient implements MeterVlNativeClient {
  /// [availability] と例外フラグで振る舞いを固定する。
  ///
  /// Example:
  /// ```dart
  /// _FakeClient(throwOnAvailability: true);
  /// ```
  _FakeClient({
    this.availability = const MeterVlNativeAvailability(
      status: 'ready',
      reason: 'ready',
      message: 'ok',
    ),
    this.throwOnAvailability = false,
    this.prepareProgress = const [0.5, 1.0],
  });

  /// 返す可用性。
  MeterVlNativeAvailability availability;

  /// true のとき [getAvailability] が失敗する。
  final bool throwOnAvailability;

  /// [prepareModel] が流す進捗。
  final List<double> prepareProgress;

  /// 最後に渡された画像。
  Uint8List? lastImageBytes;

  @override
  Future<MeterVlNativeAvailability> getAvailability() async {
    if (throwOnAvailability) {
      throw StateError('boom');
    }
    return availability;
  }

  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    lastImageBytes = imageBytes;
    return 'reply:$prompt';
  }

  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async => 'diag:$prompt';

  @override
  Stream<double> prepareModel() => Stream<double>.fromIterable(prepareProgress);
}

void main() {
  test('availabilitySnapshot は backend を写す', () async {
    final plugin = PluginMeterVlVision(
      client: _FakeClient(
        availability: const MeterVlNativeAvailability(
          status: 'ready',
          reason: 'ready',
          message: 'ok',
          backend: 'gpu',
          visionBackend: 'cpu',
        ),
      ),
    );
    final snapshot = await plugin.availabilitySnapshot;
    expect(snapshot.backend, 'gpu');
    expect(snapshot.visionBackend, 'cpu');
  });

  test('readiness は ready / modelNotDownloaded / unavailable を写す', () async {
    final ready = PluginMeterVlVision(client: _FakeClient());
    expect(await ready.readiness, MeterVlReadiness.ready);
    expect(await ready.isAvailable, isTrue);

    final missing = PluginMeterVlVision(
      client: _FakeClient(
        availability: const MeterVlNativeAvailability(
          status: 'modelNotDownloaded',
          reason: 'missing',
          message: 'need download',
        ),
      ),
    );
    expect(await missing.readiness, MeterVlReadiness.modelNotDownloaded);
    expect(await missing.isAvailable, isFalse);

    final bad = PluginMeterVlVision(
      client: _FakeClient(throwOnAvailability: true),
    );
    expect(await bad.readiness, MeterVlReadiness.unavailable);
  });

  test('generateWithImage は ready のときだけ client を呼ぶ', () async {
    final client = _FakeClient();
    final plugin = PluginMeterVlVision(client: client);
    expect(
      await plugin.generateWithImage(
        prompt: 'hi',
        imageBytes: Uint8List.fromList([9]),
      ),
      'reply:hi',
    );
    expect(client.lastImageBytes, Uint8List.fromList([9]));

    final notReady = PluginMeterVlVision(
      client: _FakeClient(
        availability: const MeterVlNativeAvailability(
          status: 'modelNotDownloaded',
          reason: 'missing',
          message: 'need download',
        ),
      ),
    );
    await expectLater(
      notReady.generateWithImage(prompt: 'x', imageBytes: Uint8List(0)),
      throwsStateError,
    );
  });

  test('prepareModel は client の進捗を流す', () async {
    final plugin = PluginMeterVlVision(
      client: _FakeClient(prepareProgress: const [0.1, 1.0]),
    );
    expect(await plugin.prepareModel().toList(), [0.1, 1.0]);
  });

  test('diagnoseGenerateWithImage は readiness を問わない', () async {
    final plugin = PluginMeterVlVision(
      client: _FakeClient(
        availability: const MeterVlNativeAvailability(
          status: 'unavailable',
          reason: 'broken',
          message: 'no',
        ),
      ),
    );
    expect(
      await plugin.diagnoseGenerateWithImage(
        prompt: 'ping',
        imageBytes: Uint8List(0),
      ),
      'diag:ping',
    );
  });
}
