import 'dart:typed_data';

import 'package:infra_user_file_testing/infra_user_file_testing.dart';
import 'package:test/test.dart';

void main() {
  test('saveBytes と pickBytes の引数を記録する', () async {
    final bytes = Uint8List.fromList([9, 8]);
    final gateway = FakeUserFileGateway(
      saveBytesResult: Uri.parse('file:///tmp/out.cogsav'),
      pickBytesResult: Uint8List.fromList([1, 2, 3]),
    );

    final saved = await gateway.saveBytes(
      bytes: bytes,
      fileName: 'out.cogsav',
      mimeType: 'application/zip',
    );
    expect(saved, Uri.parse('file:///tmp/out.cogsav'));
    expect(gateway.saveCallCount, 1);
    expect(gateway.lastSave?.fileName, 'out.cogsav');
    expect(gateway.lastSave?.mimeType, 'application/zip');
    expect(gateway.lastSave?.bytes, bytes);

    final picked = await gateway.pickBytes(extensions: ['cogsav', 'zip']);
    expect(picked, Uint8List.fromList([1, 2, 3]));
    expect(gateway.pickCallCount, 1);
    expect(gateway.lastPickExtensions, ['cogsav', 'zip']);
  });

  test('コールバックがあれば固定値より優先する', () async {
    final gateway = FakeUserFileGateway(
      saveBytesResult: Uri.parse('file:///ignored'),
      pickBytesResult: Uint8List.fromList([0]),
      onSaveBytes: ({required bytes, required fileName, required mimeType}) =>
          null,
      onPickBytes: ({required extensions}) => Uint8List.fromList([7]),
    );

    expect(
      await gateway.saveBytes(
        bytes: Uint8List(0),
        fileName: 'a.cogsav',
        mimeType: 'application/zip',
      ),
      isNull,
    );
    expect(
      await gateway.pickBytes(extensions: ['cogsav']),
      Uint8List.fromList([7]),
    );
  });
}
