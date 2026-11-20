import 'package:riverpod/riverpod.dart';

import 'export_app_data_event.dart';

/// アプリデータを `.cogsav` として書き出す。
///
/// Example:
/// ```dart
/// usecase.execute();
/// ```
abstract interface class ExportAppDataUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<ExportAppDataUsecase>(
    (ref) => throw UnimplementedError('ExportAppDataUsecase.provider'),
  );

  /// 読込・符号化・保存ダイアログまで進める。進捗と結果を流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final event in usecase.execute()) {
  ///   event;
  /// }
  /// ```
  Stream<ExportAppDataEvent> execute();
}
