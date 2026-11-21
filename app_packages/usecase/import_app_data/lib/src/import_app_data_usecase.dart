import 'dart:typed_data';

import 'package:riverpod/riverpod.dart';

import 'import_app_data_event.dart';
import 'import_pick_result.dart';

/// アプリデータを `.cogsav` から取り込む。
///
/// Example:
/// ```dart
/// usecase.pickForImport();
/// ```
abstract interface class ImportAppDataUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<ImportAppDataUsecase>(
    (ref) => throw UnimplementedError('ImportAppDataUsecase.provider'),
  );

  /// ファイル選択ダイアログを開く。キャンセルは [ImportPickCancelled]。
  ///
  /// Example:
  /// ```dart
  /// await usecase.pickForImport();
  /// ```
  Future<ImportPickResult> pickForImport();

  /// 確認済みの [bytes] を強い原子性で適用する。
  ///
  /// Example:
  /// ```dart
  /// await for (final event in usecase.applyImport(Uint8List(0))) {
  ///   event;
  /// }
  /// ```
  Stream<ImportAppDataEvent> applyImport(Uint8List bytes);
}
