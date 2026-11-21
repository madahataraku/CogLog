import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_data_management/src/strings.dart';

const _prefix = 'screen_feature_data_management_';

List<String> _csvIds() {
  final lines = File('res/strings.csv').readAsLinesSync().skip(1);
  return [
    for (final line in lines)
      if (line.trim().isNotEmpty) line.split(',').first,
  ];
}

void main() {
  final csvIds = _csvIds();
  final keys = [for (final id in csvIds) '$_prefix$id'];

  test('CSV のキーが ARB / StringsTestHelper / gen と一致する', () {
    final jaArb = jsonDecode(
      File('../../../../app/runner/lib/l10n/intl_app_ja.arb')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final enArb = jsonDecode(
      File('../../../../app/runner/lib/l10n/intl_app_en.arb')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final helperJa = jsonDecode(StringsTestHelper.ja) as Map<String, dynamic>;
    final helperEn = jsonDecode(StringsTestHelper.en) as Map<String, dynamic>;

    for (final key in keys) {
      expect(jaArb.containsKey(key), isTrue, reason: 'ja arb missing $key');
      expect(enArb.containsKey(key), isTrue, reason: 'en arb missing $key');
      expect(
        helperJa.containsKey(key),
        isTrue,
        reason: 'helper ja missing $key',
      );
      expect(
        helperEn.containsKey(key),
        isTrue,
        reason: 'helper en missing $key',
      );
    }
  });

  test('各キーを LocalizeStringDelegate で解決できる', () async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    addTearDown(LocalizeStringDelegate.resetDelegateForTest);

    for (final key in keys) {
      final value = LocalizeStringDelegate.get(key);
      expect(value, isNotEmpty, reason: key);
      expect(value, isNot(key), reason: '$key unresolved');
    }

    // gen mixin 経由でも読めること
    expect(strings.screen_feature_data_management_title, 'データ管理');
    expect(strings.screen_feature_data_management_export_item, isNotEmpty);
    expect(strings.screen_feature_data_management_import_item, isNotEmpty);
  });
}
