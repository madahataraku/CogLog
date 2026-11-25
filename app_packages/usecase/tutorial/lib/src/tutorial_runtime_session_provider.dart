import 'package:riverpod/riverpod.dart';

import 'tutorial_runtime_session.dart';

/// プロセス内のチュートリアル実行状態。単一インスタンスを保つ。
///
/// Example:
/// ```dart
/// tutorialRuntimeSessionProvider;
/// ```
final tutorialRuntimeSessionProvider = Provider<TutorialRuntimeSession>((ref) {
  ref.keepAlive();
  return TutorialRuntimeSession();
});
