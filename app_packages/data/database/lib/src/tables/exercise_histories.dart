import 'package:drift/drift.dart';

/// 運動履歴テーブル。
@DataClassName('ExerciseHistoryRow')
class ExerciseHistories extends Table {
  /// 運動履歴 ID（UUID）。
  TextColumn get id => text()();

  /// 保存日時（UTC ISO-8601）。
  TextColumn get savedAt => text()();

  /// 作成開始日時（UTC ISO-8601）。
  TextColumn get creationStartedAt => text()();

  /// 撮影日時（UTC ISO-8601）。
  TextColumn get capturedAt => text()();

  /// 記録日時（UTC ISO-8601）。
  TextColumn get recordedAt => text()();

  /// 記録日時の手変更。
  BoolColumn get recordedAtManuallySet => boolean()();

  /// 走行距離（km）。
  RealColumn get distanceKm => real()();

  /// 運動時間（ミリ秒）。
  IntColumn get durationMs => integer()();

  /// 消費カロリー（kcal）。
  RealColumn get caloriesKcal => real()();

  /// 平均速度（km/h）。
  RealColumn get averageSpeedKmh => real()();

  /// Documents からの写真相対パス。
  TextColumn get photoRelativePath => text()();

  /// ヘルスサービス上のサイクリング外部 ID。未対応・失敗時は null。
  TextColumn get healthWorkoutId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
