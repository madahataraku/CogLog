import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';

void main() {
  test('世代が進むと依存 Provider が再生成される', () {
    var builds = 0;
    final dependent = Provider.autoDispose<int>((ref) {
      ref.watch(appDataImportRefreshProvider);
      builds += 1;
      return builds;
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(dependent, (_, _) {});
    addTearDown(subscription.close);

    expect(container.read(dependent), 1);
    container.read(appDataImportRefreshProvider.notifier).state++;
    expect(container.read(dependent), 2);
    expect(builds, 2);
  });
}
