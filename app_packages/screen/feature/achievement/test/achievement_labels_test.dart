import 'package:domain_achievement/domain_achievement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_achievement/src/achievement_labels.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  test('カタログ全 ID の名前と条件が ID そのものに落ちない', () {
    for (final definition in AchievementCatalog.all) {
      final name = resolveAchievementName(definition.id);
      final condition = resolveAchievementCondition(definition.id);
      expect(
        name,
        isNot(definition.id),
        reason: 'name fallback for ${definition.id}',
      );
      expect(
        condition,
        isNot(definition.id),
        reason: 'condition fallback for ${definition.id}',
      );
    }
  });
}
