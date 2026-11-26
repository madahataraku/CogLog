import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_meter_capture/src/view/meter_tutorial_dismiss_policy.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

void main() {
  // テスト対象:
  // shouldDismissCoachMarkForMeterTutorial
  //
  // テスト内容:
  // 撮影／編集だけ閉じ、メイン表示中の離脱では閉じない。
  test('撮影・編集文脈だけ dismiss 対象', () {
    expect(shouldDismissCoachMarkForMeterTutorial(TutorialKind.camera), isTrue);
    expect(
      shouldDismissCoachMarkForMeterTutorial(TutorialKind.meterEdit),
      isTrue,
    );
    expect(shouldDismissCoachMarkForMeterTutorial(TutorialKind.main), isFalse);
    expect(
      shouldDismissCoachMarkForMeterTutorial(TutorialKind.goalSettings),
      isFalse,
    );
    expect(shouldDismissCoachMarkForMeterTutorial(null), isFalse);
  });
}
