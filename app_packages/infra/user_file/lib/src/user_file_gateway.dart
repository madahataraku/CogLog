import 'dart:typed_data';

import 'package:riverpod/riverpod.dart';

/// OS の保存ダイアログとファイル選択を扱う。
///
/// Usecase が端末のファイル UI に触れる入口。キャンセルは null。
///
/// Example:
/// ```dart
/// await gateway.saveBytes(
///   bytes: Uint8List(0),
///   fileName: 'coglog-backup.cogsav',
///   mimeType: 'application/zip',
/// );
/// ```
abstract interface class UserFileGateway {
  /// 保存ダイアログを開き、[bytes] を書き込む。キャンセルは null。
  ///
  /// Example:
  /// ```dart
  /// await gateway.saveBytes(
  ///   bytes: Uint8List.fromList([1, 2]),
  ///   fileName: 'coglog-backup.cogsav',
  ///   mimeType: 'application/zip',
  /// );
  /// ```
  Future<Uri?> saveBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });

  /// ファイル選択ダイアログを開き、内容を返す。キャンセルは null。
  ///
  /// Example:
  /// ```dart
  /// await gateway.pickBytes(extensions: ['cogsav', 'zip']);
  /// ```
  Future<Uint8List?> pickBytes({required List<String> extensions});
}

/// 利用者ファイルの注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// userFileGatewayProvider;
/// ```
final userFileGatewayProvider = Provider<UserFileGateway>(
  (ref) => throw UnimplementedError('userFileGatewayProvider'),
);
