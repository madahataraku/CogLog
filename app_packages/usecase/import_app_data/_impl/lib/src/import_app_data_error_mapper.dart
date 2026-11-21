import 'dart:io';

import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:meta/meta.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';

/// Cogsav / IO 例外を [ImportAppDataError] へ落とす。
///
/// Example:
/// ```dart
/// mapImportAppDataError(const CogsavCorruptException('x'));
/// ```
@internal
ImportAppDataError mapImportAppDataError(Object error) {
  if (error is CogsavUnsupportedVersionException) {
    return ImportAppDataError.unsupportedVersion;
  }
  if (error is CogsavCorruptException) {
    final message = error.message;
    // アーカイブ構造の欠落（manifest / data.json 本体）は corrupt。
    // data.json 内の必須キー欠落・不明 level は missingRequired。
    final missingRequired =
        message.startsWith('data.json に') ||
        message.contains('必須キーが欠ける') ||
        message.contains('が不明') ||
        (message.endsWith('が無い') &&
            message != 'manifest.json が無い' &&
            message != 'data.json が無い');
    if (missingRequired) {
      return ImportAppDataError.missingRequired;
    }
    return ImportAppDataError.corrupt;
  }
  if (error is PathAccessException) {
    return ImportAppDataError.permissionDenied;
  }
  if (error is FileSystemException) {
    final code = error.osError?.errorCode;
    final message = '${error.message} ${error.osError?.message ?? ''}';
    if (code == 28 || message.toLowerCase().contains('no space')) {
      return ImportAppDataError.storageFull;
    }
    if (code == 13) {
      return ImportAppDataError.permissionDenied;
    }
  }
  return ImportAppDataError.unexpected;
}
