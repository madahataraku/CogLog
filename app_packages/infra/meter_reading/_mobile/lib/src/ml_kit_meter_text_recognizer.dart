import 'dart:typed_data';

import 'package:infra_meter_reading/infra_meter_reading.dart';

import 'ml_kit_recognized_text_loader.dart';

/// ML Kit Text Recognition でメーター画像を文字列化する。
///
/// 日本語スクリプトが失敗したときはラテンへ落とす。
/// 圧縮画像はデコードして bitmap 入力を優先し、失敗時だけ一時ファイルへ書く。
///
/// Example:
/// ```dart
/// MlKitMeterTextRecognizer();
/// ```
final class MlKitMeterTextRecognizer implements MeterTextRecognizer {
  /// [loader] を省略すると日本語→ラテンの既定ローダーを使う。
  ///
  /// Example:
  /// ```dart
  /// MlKitMeterTextRecognizer();
  /// ```
  MlKitMeterTextRecognizer({MlKitRecognizedTextLoader? loader})
    : _loader = loader ?? MlKitRecognizedTextLoader(),
      _ownsLoader = loader == null;

  final MlKitRecognizedTextLoader _loader;
  final bool _ownsLoader;

  /// [photoBytes] を認識し、失敗時は例外を投げて一時ファイルを残さない。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterTextRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<String> recognize(Uint8List photoBytes) async {
    final loaded = await _loader.load(photoBytes);
    return loaded.recognized.text;
  }

  /// 保持する認識資源を閉じる。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterTextRecognizer().close();
  /// ```
  @override
  Future<void> close() async {
    if (_ownsLoader) {
      await _loader.close();
    }
  }
}
