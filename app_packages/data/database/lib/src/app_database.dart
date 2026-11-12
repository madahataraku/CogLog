import 'package:drift/drift.dart';

import 'tables/exercise_histories.dart';

part 'app_database.g.dart';

/// CogLog のローカルデータベース。
///
/// Example:
/// ```dart
/// AppDatabase(NativeDatabase.memory());
/// ```
@DriftDatabase(tables: [ExerciseHistories])
class AppDatabase extends _$AppDatabase {
  /// [executor] で開く（ファイルまたはメモリ）。
  ///
  /// Example:
  /// ```dart
  /// AppDatabase(NativeDatabase.memory());
  /// ```
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  /// スキーマ更新。v1→v2 で [ExerciseHistories.healthWorkoutId] を追加する。
  ///
  /// Example:
  /// ```dart
  /// AppDatabase(NativeDatabase.memory()).migration;
  /// ```
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
          exerciseHistories,
          exerciseHistories.healthWorkoutId,
        );
      }
    },
  );
}
