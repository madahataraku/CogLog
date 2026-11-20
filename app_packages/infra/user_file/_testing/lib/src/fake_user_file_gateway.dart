import 'dart:async';
import 'dart:typed_data';

import 'package:infra_user_file/infra_user_file.dart';

/// 呼び出しを記録し、戻り値やコールバックで差し替える Fake。
///
/// Example:
/// ```dart
/// FakeUserFileGateway(pickBytesResult: Uint8List.fromList([1]));
/// ```
final class FakeUserFileGateway implements UserFileGateway {
  /// 固定戻り値またはコールバックで作る。
  ///
  /// [onSaveBytes] / [onPickBytes] があればそちらを優先する。
  ///
  /// Example:
  /// ```dart
  /// FakeUserFileGateway(saveBytesResult: Uri.parse('file:///tmp/a.cogsav'));
  /// ```
  FakeUserFileGateway({
    this.saveBytesResult,
    this.pickBytesResult,
    this.onSaveBytes,
    this.onPickBytes,
  });

  /// [onSaveBytes] が無いときの [saveBytes] 戻り値。null はキャンセル。
  Uri? saveBytesResult;

  /// [onPickBytes] が無いときの [pickBytes] 戻り値。null はキャンセル。
  Uint8List? pickBytesResult;

  /// 指定時は [saveBytes] の本体になる。
  FutureOr<Uri?> Function({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  })?
  onSaveBytes;

  /// 指定時は [pickBytes] の本体になる。
  FutureOr<Uint8List?> Function({required List<String> extensions})?
  onPickBytes;

  /// 最後の [saveBytes] 引数。
  ({Uint8List bytes, String fileName, String mimeType})? lastSave;

  /// 最後の [pickBytes] の拡張子一覧。
  List<String>? lastPickExtensions;

  /// [saveBytes] が呼ばれた回数。
  int saveCallCount = 0;

  /// [pickBytes] が呼ばれた回数。
  int pickCallCount = 0;

  /// 保存を記録し、コールバックまたは [saveBytesResult] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeUserFileGateway().saveBytes(
  ///   bytes: Uint8List(0),
  ///   fileName: 'a.cogsav',
  ///   mimeType: 'application/zip',
  /// );
  /// ```
  @override
  Future<Uri?> saveBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    saveCallCount += 1;
    lastSave = (bytes: bytes, fileName: fileName, mimeType: mimeType);
    final custom = onSaveBytes;
    if (custom != null) {
      return custom(bytes: bytes, fileName: fileName, mimeType: mimeType);
    }
    return saveBytesResult;
  }

  /// 選択を記録し、コールバックまたは [pickBytesResult] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeUserFileGateway().pickBytes(extensions: ['cogsav']);
  /// ```
  @override
  Future<Uint8List?> pickBytes({required List<String> extensions}) async {
    pickCallCount += 1;
    lastPickExtensions = List<String>.unmodifiable(extensions);
    final custom = onPickBytes;
    if (custom != null) {
      return custom(extensions: extensions);
    }
    return pickBytesResult;
  }
}
