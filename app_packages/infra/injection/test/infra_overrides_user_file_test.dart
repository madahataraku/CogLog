import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:infra_user_file/infra_user_file.dart';
import 'package:infra_user_file_mobile/infra_user_file_mobile.dart';
import 'package:infra_user_file_testing/infra_user_file_testing.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test('既定は FilePickerUserFileGateway', () {
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);

    expect(
      container.read(userFileGatewayProvider),
      isA<FilePickerUserFileGateway>(),
    );
  });

  test('userFileGateway 引数で差し替えられる', () async {
    final fake = FakeUserFileGateway(
      pickBytesResult: Uint8List.fromList([4, 5]),
    );
    final container = ProviderContainer(
      overrides: infraOverrides(userFileGateway: fake),
    );
    addTearDown(container.dispose);

    final gateway = container.read(userFileGatewayProvider);
    expect(gateway, same(fake));
    expect(
      await gateway.pickBytes(extensions: ['cogsav']),
      Uint8List.fromList([4, 5]),
    );
  });
}
