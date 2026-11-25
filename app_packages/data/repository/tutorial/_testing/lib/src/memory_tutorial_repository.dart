import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:domain_tutorial/domain_tutorial.dart';

/// メモリ上のチュートリアル進捗。初期は [TutorialProgress.initial]。
///
/// Example:
/// ```dart
/// MemoryTutorialRepository();
/// ```
final class MemoryTutorialRepository implements TutorialRepository {
  /// 未完了の状態で作る。
  ///
  /// Example:
  /// ```dart
  /// MemoryTutorialRepository();
  /// ```
  MemoryTutorialRepository();

  /// 直近の [write] 内容。未書き込みは [TutorialProgress.initial]。
  TutorialProgress _progress = TutorialProgress.initial;

  /// まだ書いていなければ [TutorialProgress.initial]。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  @override
  Future<TutorialProgress> read() async => _progress;

  /// [progress] を次の [read] で返す。
  ///
  /// Example:
  /// ```dart
  /// repository.write(TutorialProgress.initial.copyWith(mainCompleted: true));
  /// ```
  @override
  Future<void> write(TutorialProgress progress) async {
    _progress = progress;
  }
}
