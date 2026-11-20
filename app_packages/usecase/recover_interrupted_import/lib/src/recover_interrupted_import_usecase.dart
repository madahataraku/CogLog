import 'package:riverpod/riverpod.dart';

import 'recover_interrupted_import_result.dart';

/// 起動時に中断インポートのバックアップを処理する。
///
/// Example:
/// ```dart
/// await usecase.execute();
/// ```
abstract interface class RecoverInterruptedImportUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<RecoverInterruptedImportUsecase>(
    (ref) =>
        throw UnimplementedError('RecoverInterruptedImportUsecase.provider'),
  );

  /// marker / snapshot を見て noop・復元・破棄のいずれかを行う。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<RecoverInterruptedImportResult> execute();
}
