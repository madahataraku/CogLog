import 'dart:async';

import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// デバッグ画面テスト用の再ダウンロード Usecase フェイク。
final class FakeRedownloadMeterVlModelUsecase
    implements RedownloadMeterVlModelUsecase {
  FakeRedownloadMeterVlModelUsecase({
    this.progressValues = const [1.0],
    this.throwOnExecute,
    this.gate,
  });

  final List<double> progressValues;
  final Exception? throwOnExecute;
  final Completer<void>? gate;

  int executeCallCount = 0;

  @override
  Stream<double> execute() async* {
    executeCallCount++;
    if (throwOnExecute != null) {
      throw throwOnExecute!;
    }
    if (gate != null) {
      await gate!.future;
    }
    for (final progress in progressValues) {
      yield progress;
    }
  }
}
