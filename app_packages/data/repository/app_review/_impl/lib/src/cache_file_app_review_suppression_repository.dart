import 'dart:io';

import 'package:data_repository_app_review/data_repository_app_review.dart';

/// アプリキャッシュ上のフラグファイルで抑止を残す。
///
/// Example:
/// ```dart
/// CacheFileAppReviewSuppressionRepository(Directory.systemTemp);
/// ```
final class CacheFileAppReviewSuppressionRepository
    implements AppReviewSuppressionRepository {
  /// [cacheDirectory] 配下へフラグを書く。
  ///
  /// Example:
  /// ```dart
  /// CacheFileAppReviewSuppressionRepository(Directory.systemTemp);
  /// ```
  const CacheFileAppReviewSuppressionRepository(this._cacheDirectory);

  /// フラグファイル名。
  static const fileName = 'app_review_suppressed';

  /// 書き込み先のキャッシュディレクトリ。
  final Directory _cacheDirectory;

  /// フラグファイルのパス。
  ///
  /// Example:
  /// ```dart
  /// CacheFileAppReviewSuppressionRepository(dir)._flagFile;
  /// ```
  File get _flagFile => File('${_cacheDirectory.path}/$fileName');

  /// ファイルが存在すれば true。読取失敗は false。
  ///
  /// Example:
  /// ```dart
  /// await repository.isSuppressed();
  /// ```
  @override
  Future<bool> isSuppressed() async {
    try {
      return _flagFile.existsSync();
    } on Object {
      return false;
    }
  }

  /// フラグファイルを作成する。
  ///
  /// Example:
  /// ```dart
  /// await repository.markSuppressed();
  /// ```
  @override
  Future<void> markSuppressed() async {
    if (!_cacheDirectory.existsSync()) {
      await _cacheDirectory.create(recursive: true);
    }
    await _flagFile.writeAsString('1');
  }
}
