import 'package:riverpod/riverpod.dart';

import 'on_device_llm_availability_snapshot.dart';
import 'on_device_llm_readiness.dart';

/// 端末上の LLM への窓口。
///
/// 利用不可や生成失敗の扱いは呼び出し側が決める。
///
/// Example:
/// ```dart
/// final available = await llm.isAvailable;
/// ```
abstract interface class OnDeviceLlm {
  /// モデルの準備状態。
  ///
  /// Example:
  /// ```dart
  /// await llm.readiness;
  /// ```
  Future<OnDeviceLlmReadiness> get readiness;

  /// [readiness] が [OnDeviceLlmReadiness.ready] のとき true。
  ///
  /// Example:
  /// ```dart
  /// await llm.isAvailable;
  /// ```
  Future<bool> get isAvailable;

  /// デバッグ用の詳細。業務経路では使わない。
  ///
  /// Example:
  /// ```dart
  /// await llm.availabilitySnapshot;
  /// ```
  Future<OnDeviceLlmAvailabilitySnapshot> get availabilitySnapshot;

  /// [prompt] から短文を生成する。
  ///
  /// Example:
  /// ```dart
  /// await llm.generate('今日の運動について短く助言して');
  /// ```
  Future<String> generate(String prompt);

  /// 未ダウンロード時に OS へモデル準備を依頼する。
  ///
  /// [OnDeviceLlmReadiness.ready] のときは何もしない。
  /// [OnDeviceLlmReadiness.unavailable] のときは失敗してよい。
  ///
  /// Example:
  /// ```dart
  /// await llm.prepareModel();
  /// ```
  Future<void> prepareModel();
}

/// 端末上 LLM の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// onDeviceLlmProvider;
/// ```
final onDeviceLlmProvider = Provider<OnDeviceLlm>(
  (ref) => throw UnimplementedError('onDeviceLlmProvider'),
);
