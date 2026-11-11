import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

/// 利用可能なエンジンを順に試し、後勝ちでマージする。
///
/// コアが揃った時点で打ち切る。全失敗でも空に近い値を返し例外にしない。
/// 全体の上限は [timeout]（既定 30 秒）。超過時はその時点のマージ結果を返す。
///
/// Example:
/// ```dart
/// ReadMeterPanelUsecaseImpl(engines: engines).execute(
///   ReadMeterPanelRequest(photoBytes: Uint8List(0)),
/// );
/// ```
final class ReadMeterPanelUsecaseImpl implements ReadMeterPanelUsecase {
  /// [engines] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// ReadMeterPanelUsecaseImpl(engines: engines);
  /// ```
  const ReadMeterPanelUsecaseImpl({
    required this.engines,
    this.timeout = const Duration(seconds: 30),
  });

  /// 試すエンジン列。先頭から順に使う。
  final List<MeterReadingEngine> engines;

  /// 読み取り全体の上限。超過時はそれまでのマージ結果で手打ちへ進む。
  final Duration timeout;

  /// [request] の写真を読み、初期平均速度を埋めて返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(ReadMeterPanelRequest(photoBytes: Uint8List(0)));
  /// ```
  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async {
    var merged = const MeterReadingValues();

    Future<MeterReadingValues> runEngines() async {
      for (final engine in engines) {
        try {
          if (!await engine.isAvailable) {
            continue;
          }
          final next = await engine.read(request.photoBytes);
          merged = MeterReadingMerger.merge(merged, next);
          if (isCompleteMeterReadingCore(merged)) {
            break;
          }
        } on Object {
          // 可否判定・読み取りの失敗は次エンジンへ。全失敗でも手打ちへ進む。
        }
      }
      return merged;
    }

    try {
      merged = await runEngines().timeout(timeout);
    } on TimeoutException {
      // その時点の merged を使う。
    }

    final resolved = resolveInitialAverageSpeed(merged: merged);
    return ReadMeterPanelResult(
      values: MeterReadingValues(
        distanceKm: merged.distanceKm,
        duration: merged.duration,
        caloriesKcal: merged.caloriesKcal,
        averageSpeedKmh: resolved.speed,
      ),
      averageSpeedFromPanel: resolved.fromPanel,
    );
  }
}
