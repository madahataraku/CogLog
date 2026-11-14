import 'dart:async';
import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// テスト用の固定読み取りエンジン。
///
/// Example:
/// ```dart
/// FakeMeterReadingEngine(
///   kind: MeterReadingEngineKind.foundationModel,
///   values: MeterReadingValues(distanceKm: 1),
/// );
/// ```
final class FakeMeterReadingEngine implements MeterReadingEngine {
  /// [kind]・利用可否・返却値を指定する。
  ///
  /// Example:
  /// ```dart
  /// FakeMeterReadingEngine(
  ///   kind: MeterReadingEngineKind.geminiNano,
  ///   available: false,
  /// );
  /// ```
  FakeMeterReadingEngine({
    required this.kind,
    this.available = true,
    this.values = const MeterReadingValues(),
    this.throwOnRead = false,
    this.hangOnRead = false,
  });

  /// エンジン種別。
  @override
  final MeterReadingEngineKind kind;

  /// [isAvailable] が返す値。
  final bool available;

  /// [read] が返す計測値。
  final MeterReadingValues values;

  /// true のとき [read] が失敗する。
  final bool throwOnRead;

  /// true のとき [read] が完了しない。
  final bool hangOnRead;

  /// [read] が呼ばれた回数。
  int readCallCount = 0;

  /// 最後に渡された写真バイト。
  Uint8List? lastPhotoBytes;

  /// [available] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterReadingEngine(kind: MeterReadingEngineKind.geminiNano)
  ///     .isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => available;

  /// [values] を返すか失敗する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterReadingEngine(kind: MeterReadingEngineKind.geminiNano)
  ///     .read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    readCallCount += 1;
    lastPhotoBytes = photoBytes;
    if (throwOnRead) {
      throw StateError('FakeMeterReadingEngine($kind) read failed');
    }
    if (hangOnRead) {
      return Completer<MeterReadingValues>().future;
    }
    return values;
  }
}
