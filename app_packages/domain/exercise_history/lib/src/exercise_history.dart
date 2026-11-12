/// 保存済みの 1 回の乗車。
///
/// 期間集計が足すのは走行距離、消費カロリー、運動時間である。
/// 平均速度は保持するが、合計には入れない。
///
/// Example:
/// ```dart
/// ExerciseHistory(
///   id: '11111111-1111-4111-8111-111111111111',
///   savedAt: DateTime.utc(2026, 11, 5),
///   creationStartedAt: DateTime.utc(2026, 11, 5),
///   capturedAt: DateTime.utc(2026, 11, 5),
///   recordedAt: DateTime.utc(2026, 11, 5, 12),
///   recordedAtManuallySet: false,
///   distanceKm: 1.25,
///   duration: Duration(minutes: 30),
///   caloriesKcal: 1.25,
///   averageSpeedKmh: 2.5,
///   photoRelativePath:
///       'exercise_histories/11111111-1111-4111-8111-111111111111/meter.jpg',
///   healthWorkoutId: null,
/// );
/// ```
final class ExerciseHistory {
  /// 永続項目すべてを持つ乗車を作る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistory(
  ///   id: '11111111-1111-4111-8111-111111111111',
  ///   savedAt: DateTime.utc(2026, 11, 5),
  ///   creationStartedAt: DateTime.utc(2026, 11, 5),
  ///   capturedAt: DateTime.utc(2026, 11, 5),
  ///   recordedAt: DateTime.utc(2026, 11, 5),
  ///   recordedAtManuallySet: false,
  ///   distanceKm: 1,
  ///   duration: Duration(minutes: 1),
  ///   caloriesKcal: 1,
  ///   averageSpeedKmh: 1,
  ///   photoRelativePath:
  ///       'exercise_histories/11111111-1111-4111-8111-111111111111/meter.jpg',
  ///   healthWorkoutId: null,
  /// );
  /// ```
  const ExerciseHistory({
    required this.id,
    required this.savedAt,
    required this.creationStartedAt,
    required this.capturedAt,
    required this.recordedAt,
    required this.recordedAtManuallySet,
    required this.distanceKm,
    required this.duration,
    required this.caloriesKcal,
    required this.averageSpeedKmh,
    required this.photoRelativePath,
    required this.healthWorkoutId,
  });

  /// 運動履歴 ID。
  final String id;

  /// 保存日時。初回書き込みのみ。編集では変えない。
  final DateTime savedAt;

  /// 作成開始日時。
  final DateTime creationStartedAt;

  /// 撮影日時。永続化では必須。
  final DateTime capturedAt;

  /// 期間へ振り分ける日時。
  final DateTime recordedAt;

  /// 記録日時を利用者が手で変えたか。
  final bool recordedAtManuallySet;

  /// 走行距離。単位は km。
  final double distanceKm;

  /// 運動時間。
  final Duration duration;

  /// 消費カロリー。単位は kcal。
  final double caloriesKcal;

  /// 平均速度。単位は km/h。期間の合計には使わない。
  final double averageSpeedKmh;

  /// Documents からの写真相対パス。
  final String photoRelativePath;

  /// ヘルスサービス上のサイクリング外部 ID。未対応・失敗時は null。
  final String? healthWorkoutId;
}
