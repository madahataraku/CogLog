import 'package:meta/meta.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// 撮影タブ離脱・読み取り開始でコーチマークを閉じてよいか。
///
/// 撮影／編集文脈だけ true。ホームのメイン連鎖など他画面の表示は触らない。
///
/// Example:
/// ```dart
/// shouldDismissCoachMarkForMeterTutorial(TutorialKind.camera);
/// ```
@internal
bool shouldDismissCoachMarkForMeterTutorial(TutorialKind? kind) {
  return kind == TutorialKind.camera || kind == TutorialKind.meterEdit;
}
