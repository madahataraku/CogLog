import 'package:riverpod/riverpod.dart';

import 'app_log_entry.dart';
import 'app_log_level.dart';

/// プロセス内のリングバッファログ。
///
/// 永続化もクラウド送信もしない。上限を超えた古い行は捨てる。
///
/// Example:
/// ```dart
/// AppLogStore();
/// ```
final class AppLogStore {
  /// [maxEntries] 件までのリングバッファを作る。
  ///
  /// Example:
  /// ```dart
  /// AppLogStore(maxEntries: 50);
  /// ```
  AppLogStore({this.maxEntries = 200, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// 保持する最大行数。
  final int maxEntries;

  /// 記録時刻の供給。テストで差し替える。
  final DateTime Function() _clock;

  final List<AppLogEntry> _entries = <AppLogEntry>[];
  final List<void Function()> _listeners = <void Function()>[];

  /// 新しい順ではない、古い→新しいの一覧。
  ///
  /// Example:
  /// ```dart
  /// store.entries;
  /// ```
  List<AppLogEntry> get entries => List<AppLogEntry>.unmodifiable(_entries);

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

  /// 1 行を末尾へ足す。上限超過時は先頭を捨てる。
  ///
  /// Example:
  /// ```dart
  /// store.append(tag: 'llm', message: 'ready');
  /// ```
  void append({
    required String tag,
    required String message,
    AppLogLevel level = AppLogLevel.info,
    DateTime? at,
  }) {
    _entries.add(
      AppLogEntry(at: at ?? _clock(), level: level, tag: tag, message: message),
    );
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    _notify();
  }

  /// 全行を消す。
  ///
  /// Example:
  /// ```dart
  /// store.clear();
  /// ```
  void clear() {
    if (_entries.isEmpty) {
      return;
    }
    _entries.clear();
    _notify();
  }

  void _notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}

/// アプリログの注入点。既定は共有の空ストア。
///
/// Example:
/// ```dart
/// appLogStoreProvider;
/// ```
final appLogStoreProvider = Provider<AppLogStore>((ref) => AppLogStore());
