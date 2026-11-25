import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';

void main() {
  group('TutorialProgress', () {
    test('initial はすべて false', () {
      expect(TutorialProgress.initial.mainCompleted, isFalse);
      expect(TutorialProgress.initial.cameraContextSeen, isFalse);
      expect(TutorialProgress.initial.meterEditContextSeen, isFalse);
      expect(TutorialProgress.initial.trendsContextSeen, isFalse);
      expect(TutorialProgress.initial.historyContextSeen, isFalse);
      expect(TutorialProgress.initial.achievementContextSeen, isFalse);
    });

    test('reset は initial を返す', () {
      final progressed = TutorialProgress.initial.copyWith(
        mainCompleted: true,
        cameraContextSeen: true,
      );
      expect(progressed.reset(), TutorialProgress.initial);
    });

    test('copyWith は指定フィールドだけ差し替える', () {
      final updated = TutorialProgress.initial.copyWith(
        mainCompleted: true,
        trendsContextSeen: true,
      );
      expect(updated.mainCompleted, isTrue);
      expect(updated.trendsContextSeen, isTrue);
      expect(updated.cameraContextSeen, isFalse);
      expect(updated.meterEditContextSeen, isFalse);
      expect(updated.historyContextSeen, isFalse);
      expect(updated.achievementContextSeen, isFalse);
    });

    test('== と hashCode は 6 フラグで決まる', () {
      const a = TutorialProgress(
        mainCompleted: true,
        cameraContextSeen: false,
        meterEditContextSeen: true,
        trendsContextSeen: false,
        historyContextSeen: true,
        achievementContextSeen: false,
      );
      const b = TutorialProgress(
        mainCompleted: true,
        cameraContextSeen: false,
        meterEditContextSeen: true,
        trendsContextSeen: false,
        historyContextSeen: true,
        achievementContextSeen: false,
      );
      const c = TutorialProgress(
        mainCompleted: true,
        cameraContextSeen: false,
        meterEditContextSeen: true,
        trendsContextSeen: false,
        historyContextSeen: true,
        achievementContextSeen: true,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
