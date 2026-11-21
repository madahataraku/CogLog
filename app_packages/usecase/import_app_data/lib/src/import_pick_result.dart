import 'dart:typed_data';

import 'import_app_data_error.dart';

part 'import_pick_cancelled.dart';
part 'import_pick_failed.dart';
part 'import_pick_succeeded.dart';

/// インポート用ファイル選択の結果。
///
/// Example:
/// ```dart
/// const ImportPickCancelled();
/// ```
sealed class ImportPickResult {
  /// 結果の基底。
  ///
  /// Example:
  /// ```dart
  /// const ImportPickCancelled();
  /// ```
  const ImportPickResult();
}
