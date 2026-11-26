import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';

void main() {
  // テスト対象:
  // TutorialProgress.initial
  //
  // テスト内容:
  // 初期値は未完了・到達0・全文脈未表示である。
  test('TutorialProgress initial はすべて未完了', () {
    const p = TutorialProgress.initial;
    expect(p.mainCompleted, isFalse);
    expect(p.mainReachedStep, 0);
    expect(p.goalSettingsContextSeen, isFalse);
    expect(p.cameraContextSeen, isFalse);
    expect(p.meterEditContextSeen, isFalse);
    expect(p.trendsContextSeen, isFalse);
    expect(p.historyContextSeen, isFalse);
    expect(p.achievementContextSeen, isFalse);
  });

  // テスト対象:
  // TutorialProgress.reset
  //
  // テスト内容:
  // reset は initial を返す。
  test('TutorialProgress reset は initial を返す', () {
    final p = TutorialProgress.initial.copyWith(
      mainCompleted: true,
      mainReachedStep: 7,
      goalSettingsContextSeen: true,
    );
    expect(p.reset(), TutorialProgress.initial);
  });

  // テスト対象:
  // TutorialProgress.copyWith
  //
  // テスト内容:
  // 指定フィールドだけ差し替える。
  test('TutorialProgress copyWith は指定フィールドだけ差し替える', () {
    final p = TutorialProgress.initial.copyWith(
      mainReachedStep: 3,
      goalSettingsContextSeen: true,
    );
    expect(p.mainReachedStep, 3);
    expect(p.goalSettingsContextSeen, isTrue);
    expect(p.mainCompleted, isFalse);
  });

  // テスト対象:
  // TutorialProgress == / hashCode
  //
  // テスト内容:
  // 全永続フィールドで等価が決まる。
  test('TutorialProgress == と hashCode は永続フィールドで決まる', () {
    const a = TutorialProgress(
      mainCompleted: true,
      mainReachedStep: 4,
      goalSettingsContextSeen: true,
      cameraContextSeen: true,
      meterEditContextSeen: false,
      trendsContextSeen: false,
      historyContextSeen: false,
      achievementContextSeen: false,
    );
    const b = TutorialProgress(
      mainCompleted: true,
      mainReachedStep: 4,
      goalSettingsContextSeen: true,
      cameraContextSeen: true,
      meterEditContextSeen: false,
      trendsContextSeen: false,
      historyContextSeen: false,
      achievementContextSeen: false,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
