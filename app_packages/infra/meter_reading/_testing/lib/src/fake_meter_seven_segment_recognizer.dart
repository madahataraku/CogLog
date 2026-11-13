import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// 固定トークンまたは例外を返す七セグ認識器。
///
/// Example:
/// ```dart
/// FakeMeterSevenSegmentRecognizer(tokens: const []);
/// ```
final class FakeMeterSevenSegmentRecognizer
    implements MeterSevenSegmentRecognizer {
  /// [tokens] を返す認識器を作る。
  ///
  /// Example:
  /// ```dart
  /// FakeMeterSevenSegmentRecognizer();
  /// ```
  FakeMeterSevenSegmentRecognizer({
    this.tokens = const [],
    this.throwOnRecognize = false,
  });

  /// [recognize] が返す列。
  final List<MeterOcrToken> tokens;

  /// true のとき認識が失敗する。
  final bool throwOnRecognize;

  /// 呼出回数。
  int callCount = 0;

  /// [photoBytes] を無視して設定トークンを返すか失敗する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterSevenSegmentRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognize(Uint8List photoBytes) async {
    callCount += 1;
    if (throwOnRecognize) {
      throw StateError('FakeMeterSevenSegmentRecognizer failed');
    }
    return tokens;
  }

  /// 解放対象はない。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterSevenSegmentRecognizer().close();
  /// ```
  @override
  Future<void> close() async {}
}
