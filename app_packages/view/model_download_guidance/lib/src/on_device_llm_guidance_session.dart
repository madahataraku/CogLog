/// 同一プロセス内のモデル誘導の再表示抑制。
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
