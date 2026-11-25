import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:riverpod/riverpod.dart';

/// チュートリアル進捗をプロセス終了後も残す。
///
/// Example:
/// ```dart
/// repository.read();
/// ```
abstract interface class TutorialRepository {
  /// 保存が無ければ [TutorialProgress.initial]。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  Future<TutorialProgress> read();

  /// [progress] を保存する。
  ///
  /// Example:
  /// ```dart
  /// repository.write(TutorialProgress.initial.copyWith(mainCompleted: true));
  /// ```
  Future<void> write(TutorialProgress progress);
}

/// チュートリアル Repository の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// tutorialRepositoryProvider;
/// ```
final tutorialRepositoryProvider = Provider<TutorialRepository>(
  (ref) => throw UnimplementedError('tutorialRepositoryProvider'),
);
