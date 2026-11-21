import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_user_file_mobile/infra_user_file_mobile.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

base class _TestPlatformFile extends PlatformFile {
  _TestPlatformFile({
    required this.name,
    required String path,
    required this.bytes,
  }) : uri = Uri.file(path);

  @override
  final String name;

  @override
  final Uri uri;

  final Uint8List bytes;

  @override
  XFile get xFile => XFile.fromData(bytes, name: name);

  @override
  int? lengthSync() => bytes.length;

  @override
  Future<int?> length() async => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

final class _MockFilePickerPlatform extends FilePickerPlatform
    with MockPlatformInterfaceMixin {
  FileType? lastPickType;
  List<String>? lastAllowedExtensions;
  String? lastSaveFileName;
  String? lastSaveMimeType;
  Uint8List? lastSaveBytes;

  PlatformFile? pickResult;
  Uri? saveResult;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    lastPickType = type;
    lastAllowedExtensions = allowedExtensions;
    return pickResult;
  }

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    lastSaveFileName = fileName;
    lastSaveMimeType = mimeType;
    lastSaveBytes = bytes;
    return saveResult;
  }
}

void main() {
  late _MockFilePickerPlatform mock;
  late FilePickerPlatform previous;

  setUp(() {
    previous = FilePickerPlatform.instance;
    mock = _MockFilePickerPlatform();
    FilePickerPlatform.instance = mock;
  });

  tearDown(() {
    FilePickerPlatform.instance = previous;
  });

  test('saveBytes は file_picker に委譲する', () async {
    mock.saveResult = Uri.parse('file:///tmp/coglog-backup.cogsav');
    final bytes = Uint8List.fromList([1, 2, 3]);

    final uri = await const FilePickerUserFileGateway().saveBytes(
      bytes: bytes,
      fileName: 'coglog-backup.cogsav',
      mimeType: 'application/zip',
    );

    expect(uri, Uri.parse('file:///tmp/coglog-backup.cogsav'));
    expect(mock.lastSaveFileName, 'coglog-backup.cogsav');
    expect(mock.lastSaveMimeType, 'application/zip');
    expect(mock.lastSaveBytes, bytes);
  });

  test('saveBytes のキャンセルは null', () async {
    mock.saveResult = null;

    final uri = await const FilePickerUserFileGateway().saveBytes(
      bytes: Uint8List(0),
      fileName: 'coglog-backup.cogsav',
      mimeType: 'application/zip',
    );

    expect(uri, isNull);
  });

  test('pickBytes は FileType.any で開き拡張子を後で検証する', () async {
    final bytes = Uint8List.fromList([9, 8, 7]);
    mock.pickResult = _TestPlatformFile(
      name: 'backup.cogsav',
      path: '/tmp/backup.cogsav',
      bytes: bytes,
    );

    final picked = await const FilePickerUserFileGateway().pickBytes(
      extensions: ['cogsav', 'zip'],
    );

    expect(picked, bytes);
    expect(mock.lastPickType, FileType.any);
    expect(mock.lastAllowedExtensions, isNull);
  });

  test('pickBytes のキャンセルは null', () async {
    mock.pickResult = null;

    final picked = await const FilePickerUserFileGateway().pickBytes(
      extensions: ['cogsav'],
    );

    expect(picked, isNull);
  });

  test('許可外拡張子は null', () async {
    mock.pickResult = _TestPlatformFile(
      name: 'notes.txt',
      path: '/tmp/notes.txt',
      bytes: Uint8List.fromList([1]),
    );

    final picked = await const FilePickerUserFileGateway().pickBytes(
      extensions: ['cogsav'],
    );

    expect(picked, isNull);
  });
}
