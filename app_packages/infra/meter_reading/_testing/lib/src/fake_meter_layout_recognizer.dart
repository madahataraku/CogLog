import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// 固定トークン列を返すレイアウト認識器。
///
/// Example:
/// ```dart
/// FakeMeterLayoutRecognizer(tokens: const []);
/// ```
final class FakeMeterLayoutRecognizer implements MeterLayoutRecognizer {
  /// [tokens] を返す認識器を作る。
  ///
  /// Example:
  /// ```dart
  /// FakeMeterLayoutRecognizer();
  /// ```
  FakeMeterLayoutRecognizer({
    this.tokens = const [],
    this.throwOnRecognize = false,
  });

  /// [recognizeLayout] が返す列。
  final List<MeterOcrToken> tokens;

  /// true のとき認識が失敗する。
  final bool throwOnRecognize;

  /// 呼出回数。
  int callCount = 0;

  /// [tokens] を返すか失敗する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterLayoutRecognizer().recognizeLayout(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognizeLayout(Uint8List photoBytes) async {
    callCount += 1;
    if (throwOnRecognize) {
      throw StateError('FakeMeterLayoutRecognizer failed');
    }
    return tokens;
  }

  /// 解放対象はない。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterLayoutRecognizer().close();
  /// ```
  @override
  Future<void> close() async {}
}
