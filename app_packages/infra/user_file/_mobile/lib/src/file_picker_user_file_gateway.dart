import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:infra_user_file/infra_user_file.dart';

/// `file_picker` による保存ダイアログとファイル選択。
///
/// 選択は [FileType.any] で開き、戻り後に拡張子を検証する。
/// Android が `.cogsav` を `application/octet-stream` と報告しても、
/// カスタム MIME／拡張子フィルタで弾かれないようにする。
///
/// Example:
/// ```dart
/// const FilePickerUserFileGateway();
/// ```
final class FilePickerUserFileGateway implements UserFileGateway {
  /// 既定の [FilePicker] で作る。
  ///
  /// Example:
  /// ```dart
  /// const FilePickerUserFileGateway();
  /// ```
  const FilePickerUserFileGateway();

  /// 保存ダイアログで [bytes] を書き、選ばれた場所の [Uri] を返す。
  ///
  /// Example:
  /// ```dart
  /// await const FilePickerUserFileGateway().saveBytes(
  ///   bytes: Uint8List(0),
  ///   fileName: 'coglog-backup.cogsav',
  ///   mimeType: 'application/zip',
  /// );
  /// ```
  @override
  Future<Uri?> saveBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) =>
      FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType);

  /// 拡張子フィルタ付きで 1 ファイルを選び、バイト列を返す。
  ///
  /// ダイアログは拡張子を OS 側で絞らず、選択後に [extensions] と照合する。
  /// 不一致はキャンセルと同様に null を返す。
  ///
  /// Example:
  /// ```dart
  /// await const FilePickerUserFileGateway().pickBytes(
  ///   extensions: ['cogsav', 'zip'],
  /// );
  /// ```
  @override
  Future<Uint8List?> pickBytes({required List<String> extensions}) async {
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) {
      return null;
    }
    final allowed = {
      for (final extension in extensions) extension.toLowerCase(),
    };
    final selected = file.extension?.toLowerCase();
    if (selected == null || !allowed.contains(selected)) {
      return null;
    }
    return file.readAsBytes();
  }
}
