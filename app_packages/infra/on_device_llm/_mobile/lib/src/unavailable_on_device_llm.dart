import 'package:infra_on_device_llm/infra_on_device_llm.dart';

/// 利用不可の端末上 LLM。
///
/// 非モバイルや未対応経路向け。常に [OnDeviceLlmReadiness.unavailable]。
///
/// Example:
/// ```dart
/// const UnavailableOnDeviceLlm();
/// ```
final class UnavailableOnDeviceLlm implements OnDeviceLlm {
  /// 利用不可の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableOnDeviceLlm();
  /// ```
  const UnavailableOnDeviceLlm();

  /// 常に [OnDeviceLlmReadiness.unavailable]。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableOnDeviceLlm().readiness;
  /// ```
  @override
  Future<OnDeviceLlmReadiness> get readiness async =>
      OnDeviceLlmReadiness.unavailable;

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableOnDeviceLlm().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => false;

  /// 利用不可のため呼ばない想定。呼ばれたら失敗する。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableOnDeviceLlm().generate('prompt');
  /// ```
  @override
  Future<String> generate(String prompt) async {
    throw StateError('OnDeviceLlm is unavailable');
  }

  /// 利用不可のため何もしない。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableOnDeviceLlm().prepareModel();
  /// ```
  @override
  Future<void> prepareModel() async {}
}
