import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// 初回アプリ向けの未接続読み取りエンジン。
///
/// 常に利用不可。実接続は後続で差し替える。
///
/// Example:
/// ```dart
/// const UnavailableMeterReadingEngine(MeterReadingEngineKind.mlKit);
/// ```
final class UnavailableMeterReadingEngine implements MeterReadingEngine {
  /// [kind] を持つ利用不可エンジンを作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableMeterReadingEngine(MeterReadingEngineKind.visionOcr);
  /// ```
  const UnavailableMeterReadingEngine(this.kind);

  /// エンジン種別。
  @override
  final MeterReadingEngineKind kind;

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterReadingEngine(MeterReadingEngineKind.mlKit)
  ///     .isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => false;

  /// 利用不可のため呼ばない想定。呼ばれたら失敗する。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterReadingEngine(MeterReadingEngineKind.mlKit)
  ///     .read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    throw StateError('MeterReadingEngine($kind) is unavailable');
  }
}
