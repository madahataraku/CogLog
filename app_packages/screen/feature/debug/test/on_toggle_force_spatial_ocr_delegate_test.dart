import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_toggle_force_spatial_ocr_delegate.dart';
import 'package:test/test.dart';

void main() {
  test('execute はストアへ反映する', () {
    final store = ForceSpatialOcrStore();
    OnToggleForceSpatialOcrDelegate(forceSpatialOcr: store).execute(true);
    expect(store.enabled, isTrue);
    OnToggleForceSpatialOcrDelegate(forceSpatialOcr: store).execute(false);
    expect(store.enabled, isFalse);
  });
}
