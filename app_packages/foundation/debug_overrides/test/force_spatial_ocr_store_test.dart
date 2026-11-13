import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:test/test.dart';

void main() {
  test('既定は enabled == false', () {
    final store = ForceSpatialOcrStore();
    expect(store.enabled, isFalse);
  });

  test('setEnabled で値が変わり listener が呼ばれる', () {
    final store = ForceSpatialOcrStore();
    var calls = 0;
    store.addListener(() => calls += 1);
    store.setEnabled(true);
    expect(store.enabled, isTrue);
    expect(calls, 1);
    store.setEnabled(true);
    expect(calls, 1);
    store.setEnabled(false);
    expect(store.enabled, isFalse);
    expect(calls, 2);
  });

  test('removeListener 後は通知されない', () {
    final store = ForceSpatialOcrStore();
    var calls = 0;
    void listener() => calls += 1;
    store.addListener(listener);
    store.removeListener(listener);
    store.setEnabled(true);
    expect(calls, 0);
  });

  test('新しいインスタンスは常に false', () {
    final a = ForceSpatialOcrStore()..setEnabled(true);
    final b = ForceSpatialOcrStore();
    expect(a.enabled, isTrue);
    expect(b.enabled, isFalse);
  });
}
