part of 'import_pick_result.dart';

/// ファイル選択に成功した。
///
/// Example:
/// ```dart
/// ImportPickSucceeded(Uint8List(0));
/// ```
final class ImportPickSucceeded extends ImportPickResult {
  /// 選ばれた [bytes] を持つ。
  ///
  /// Example:
  /// ```dart
  /// ImportPickSucceeded(Uint8List.fromList([1]));
  /// ```
  const ImportPickSucceeded(this.bytes);

  /// `.cogsav` / ZIP の生バイト。
  final Uint8List bytes;
}
