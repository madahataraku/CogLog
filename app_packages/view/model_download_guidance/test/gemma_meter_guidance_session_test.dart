import 'package:flutter_test/flutter_test.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

void main() {
  test('初期は shouldShow true、markPresented 後は false', () {
    final session = GemmaMeterGuidanceSession();
    expect(session.shouldShow, isTrue);
    expect(session.hasPresented, isFalse);
    session.markPresented();
    expect(session.shouldShow, isFalse);
    expect(session.hasPresented, isTrue);
  });

  test('新しいインスタンスは再び shouldShow true', () {
    final first = GemmaMeterGuidanceSession()..markPresented();
    expect(first.shouldShow, isFalse);
    expect(GemmaMeterGuidanceSession().shouldShow, isTrue);
  });

  test('(A) セッションとは独立', () {
    final onDevice = OnDeviceLlmGuidanceSession()..markPresented();
    final gemma = GemmaMeterGuidanceSession();
    expect(onDevice.shouldShow, isFalse);
    expect(gemma.shouldShow, isTrue);
  });
}
