import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';

void main() {
  test('新規 trophy semantics キーが ja/en にある', () {
    expect(
      StringsTestHelper.ja.contains(
        'screen_feature_top_achievements_new_semantics',
      ),
      isTrue,
    );
    expect(
      StringsTestHelper.en.contains(
        'screen_feature_top_achievements_new_semantics',
      ),
      isTrue,
    );
  });
}
