import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:test/test.dart';

void main() {
  test('append は古い順に保持し上限で先頭を捨てる', () {
    var tick = 0;
    final store = AppLogStore(
      maxEntries: 2,
      clock: () => DateTime.utc(2026, 1, 1).add(Duration(seconds: tick++)),
    );
    store.append(tag: 'a', message: '1');
    store.append(tag: 'a', message: '2');
    store.append(tag: 'a', message: '3');
    expect(store.entries.map((e) => e.message), ['2', '3']);
  });

  test('clear で空になり listener が呼ばれる', () {
    final store = AppLogStore();
    var calls = 0;
    store.addListener(() => calls += 1);
    store.append(tag: 't', message: 'x', level: AppLogLevel.warn);
    store.clear();
    expect(store.entries, isEmpty);
    expect(calls, 2);
  });
}
