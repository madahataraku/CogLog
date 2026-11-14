import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_mobile/infra_gemma_meter_mobile.dart';
import 'package:infra_gemma_meter_mobile/src/gemma_meter_native_availability.dart';
import 'package:infra_gemma_meter_mobile/src/gemma_meter_native_client.dart';

/// [PluginGemmaMeterVision] 向けの固定応答クライアント。
final class _FakeClient implements GemmaMeterNativeClient {
  /// [availability] と例外フラグで振る舞いを固定する。
  ///
  /// Example:
  /// ```dart
  /// _FakeClient(throwOnAvailability: true);
  /// ```
  _FakeClient({
    this.availability = const GemmaMeterNativeAvailability(
      status: 'ready',
      reason: 'ready',
      message: 'ok',
    ),
    this.throwOnAvailability = false,
    this.prepareProgress = const [0.5, 1.0],
  });

  /// 返す可用性。
  GemmaMeterNativeAvailability availability;

  /// true のとき [getAvailability] が失敗する。
  final bool throwOnAvailability;

  /// [prepareModel] が流す進捗。
  final List<double> prepareProgress;

  /// 最後に渡された画像。
  Uint8List? lastImageBytes;

  @override
  Future<GemmaMeterNativeAvailability> getAvailability() async {
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
  test('readiness は ready / modelNotDownloaded / unavailable を写す', () async {
    final ready = PluginGemmaMeterVision(client: _FakeClient());
    expect(await ready.readiness, GemmaMeterReadiness.ready);
    expect(await ready.isAvailable, isTrue);

    final missing = PluginGemmaMeterVision(
      client: _FakeClient(
        availability: const GemmaMeterNativeAvailability(
          status: 'modelNotDownloaded',
          reason: 'missing',
          message: 'need download',
        ),
      ),
    );
    expect(await missing.readiness, GemmaMeterReadiness.modelNotDownloaded);
    expect(await missing.isAvailable, isFalse);

    final bad = PluginGemmaMeterVision(
      client: _FakeClient(throwOnAvailability: true),
    );
    expect(await bad.readiness, GemmaMeterReadiness.unavailable);
  });

  test('generateWithImage は ready のときだけ client を呼ぶ', () async {
    final client = _FakeClient();
    final plugin = PluginGemmaMeterVision(client: client);
    expect(
      await plugin.generateWithImage(
        prompt: 'hi',
        imageBytes: Uint8List.fromList([9]),
      ),
      'reply:hi',
    );
    expect(client.lastImageBytes, Uint8List.fromList([9]));

    final notReady = PluginGemmaMeterVision(
      client: _FakeClient(
        availability: const GemmaMeterNativeAvailability(
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
    final plugin = PluginGemmaMeterVision(
      client: _FakeClient(prepareProgress: const [0.1, 1.0]),
    );
    expect(await plugin.prepareModel().toList(), [0.1, 1.0]);
  });

  test('diagnoseGenerateWithImage は readiness を問わない', () async {
    final plugin = PluginGemmaMeterVision(
      client: _FakeClient(
        availability: const GemmaMeterNativeAvailability(
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
