import 'package:riverpod/riverpod.dart';

/// 空間 OCR 強制のプロセス内フラグ。
///
/// ディスクへは書かない。既定は OFF。
/// ON のとき読み取りは空間 OCR のみを試し、使えなければ手打ちへ進む（LLM には戻さない）。
///
/// Example:
/// ```dart
/// ForceSpatialOcrStore();
/// ```
final class ForceSpatialOcrStore {
  /// 既定 OFF のストアを作る。
  ///
  /// Example:
  /// ```dart
  /// ForceSpatialOcrStore();
  /// ```
  ForceSpatialOcrStore();

  bool _enabled = false;
  final List<void Function()> _listeners = <void Function()>[];

  /// 空間 OCR を強制するか。
  ///
  /// Example:
  /// ```dart
  /// store.enabled;
  /// ```
  bool get enabled => _enabled;

  /// [enabled] を更新する。値が変わったときだけ購読者へ通知する。
  ///
  /// Example:
  /// ```dart
  /// store.setEnabled(true);
  /// ```
  void setEnabled(bool value) {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    _notify();
  }

  /// 変更通知を購読する。
  ///
  /// Example:
  /// ```dart
  /// store.addListener(() {});
  /// ```
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// [addListener] で登録した購読を外す。
  ///
  /// Example:
  /// ```dart
  /// store.removeListener(listener);
  /// ```
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}

/// 空間 OCR 強制ストアの注入点。既定は共有の OFF ストア。
///
/// Example:
/// ```dart
/// forceSpatialOcrStoreProvider;
/// ```
final forceSpatialOcrStoreProvider = Provider<ForceSpatialOcrStore>(
  (ref) => ForceSpatialOcrStore(),
);
