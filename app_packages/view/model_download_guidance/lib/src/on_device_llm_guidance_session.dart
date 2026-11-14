/// 同一プロセス内の OS LLM モデル誘導 (A) の再表示抑制。
///
/// NOTE.
/// Gemma メーター誘導 (B) のセッションとは独立する。
/// プロセス再起動で未提示に戻る。
///
/// Example:
/// ```dart
/// OnDeviceLlmGuidanceSession();
/// ```
final class OnDeviceLlmGuidanceSession {
  /// 未提示のセッションを作る。
  ///
  /// Example:
  /// ```dart
  /// OnDeviceLlmGuidanceSession();
  /// ```
  OnDeviceLlmGuidanceSession();

  /// このプロセスで誘導を出した／閉じたあとなら true。
  bool _presented = false;

  /// すでにこのプロセスで誘導を出した／閉じたあとなら true。
  ///
  /// Example:
  /// ```dart
  /// session.hasPresented;
  /// ```
  bool get hasPresented => _presented;

  /// まだ出していないとき true。
  ///
  /// Example:
  /// ```dart
  /// session.shouldShow;
  /// ```
  bool get shouldShow => !_presented;

  /// 表示開始時に呼び、同一プロセスでの再表示を止める。
  ///
  /// Example:
  /// ```dart
  /// session.markPresented();
  /// ```
  void markPresented() => _presented = true;
}
