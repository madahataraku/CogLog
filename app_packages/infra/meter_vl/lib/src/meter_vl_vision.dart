import 'dart:typed_data';

import 'package:riverpod/riverpod.dart';

import 'meter_vl_availability_snapshot.dart';
import 'meter_vl_readiness.dart';

/// メーター読み取り専用の LFM VL（LiteRT-LM）窓口。
///
/// [isAvailable] は [readiness] が [MeterVlReadiness.ready] のときだけ true。
///
/// Example:
/// ```dart
/// final available = await meterVl.isAvailable;
/// ```
abstract interface class MeterVlVision {
  /// モデルの準備状態。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.readiness;
  /// ```
  Future<MeterVlReadiness> get readiness;

  /// [readiness] == [MeterVlReadiness.ready] のとき true。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.isAvailable;
  /// ```
  Future<bool> get isAvailable;

  /// デバッグ用の詳細。業務経路では使わない。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.availabilitySnapshot;
  /// ```
  Future<MeterVlAvailabilitySnapshot> get availabilitySnapshot;

  /// [prompt] と [imageBytes] から短文を生成する。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.generateWithImage(
  ///   prompt: 'panel',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  });

  /// 診断専用。準備状態を問わず生成を試し、失敗理由を例外で返す。
  ///
  /// 業務経路では [generateWithImage] を使う。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.diagnoseGenerateWithImage(
  ///   prompt: 'ping',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  });

  /// 未ダウンロード時にモデル準備を依頼する。
  ///
  /// 進捗は 0.0〜1.0。取得不能なら段階近似でよい（後続 N）。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in meterVl.prepareModel()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> prepareModel();

  /// 保持中の LFM VL 成果物と Gemma 時代の旧成果物を削除する。
  ///
  /// 未保持なら成功（no-op）。prepare / generate 実行中は失敗する。
  /// 誘導の提示済みフラグは変更しない。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.deleteDownloadedModels();
  /// ```
  Future<void> deleteDownloadedModels();

  /// prepare または generate がネイティブで実行中なら true。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.isOperationBusy;
  /// ```
  Future<bool> get isOperationBusy;
}

/// メーター VL 経路の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// meterVlVisionProvider;
/// ```
final meterVlVisionProvider = Provider<MeterVlVision>(
  (ref) => throw UnimplementedError('meterVlVisionProvider'),
);
