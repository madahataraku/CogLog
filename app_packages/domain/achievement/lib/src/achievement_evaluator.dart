import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'achievement_catalog.dart';
import 'achievement_criterion.dart';
import 'achievement_definition.dart';
import 'achievement_local_date.dart';
import 'achievement_progress.dart';

/// 運動履歴からアチーブメント進捗を算出する純関数群。
///
/// 永続化やトーストは扱わない。獲得済みの取り消しもしない。
///
/// Example:
/// ```dart
/// final progress = AchievementEvaluator.evaluate(histories, DateTime.now());
/// ```
final class AchievementEvaluator {
  /// 評価用の名前空間。
  ///
  /// Example:
  /// ```dart
  /// AchievementEvaluator.evaluate(const [], DateTime(2026, 11, 10));
  /// ```
  const AchievementEvaluator._();

  /// [histories] からカタログ全件の進捗を返す。
  ///
  /// [now] は判定時点の基準日時。v1 の各条件は履歴の記録日時のみで決まり、
  /// 現在ストリーク起点には使わない。
  /// 戻り値の並びは [AchievementCatalog.all] と同じ。
  ///
  /// Example:
  /// ```dart
  /// AchievementEvaluator.evaluate(histories, DateTime(2026, 11, 10, 12));
  /// ```
  static List<AchievementProgress> evaluate(
    List<ExerciseHistory> histories,
    DateTime now,
  ) {
    // 呼び出し契約として判定時点を受け取る。v1 条件は履歴のみで足りる。
    final _ = now.toLocal();

    final metrics = _Metrics.from(histories);
    return [
      for (final definition in AchievementCatalog.all)
        _progressFor(definition, metrics),
    ];
  }

  /// 定義 1 件分の進捗を組み立てる。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static AchievementProgress _progressFor(
    AchievementDefinition definition,
    _Metrics metrics,
  ) {
    final current = _currentValue(definition, metrics);
    final achieved = _isAchieved(definition, current, metrics);
    final ratio = definition.binaryProgress
        ? (achieved ? 1.0 : 0.0)
        : (definition.target <= 0
              ? (achieved ? 1.0 : 0.0)
              : (current / definition.target).clamp(0.0, 1.0));
    return AchievementProgress(
      id: definition.id,
      current: current,
      target: definition.target,
      ratio: ratio,
      achieved: achieved,
      binaryProgress: definition.binaryProgress,
    );
  }

  /// 条件種別に応じた現在値を返す。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static double _currentValue(
    AchievementDefinition definition,
    _Metrics metrics,
  ) {
    return switch (definition.criterion) {
      AchievementCriterion.firstRecord => metrics.recordCount >= 1 ? 1.0 : 0.0,
      AchievementCriterion.maxStreakDays => metrics.maxStreakDays.toDouble(),
      AchievementCriterion.uniqueDays => metrics.uniqueDays.toDouble(),
      AchievementCriterion.totalDistanceKm => metrics.totalDistanceKm,
      AchievementCriterion.totalDuration =>
        metrics.totalDurationSeconds.toDouble(),
      AchievementCriterion.totalCaloriesKcal => metrics.totalCaloriesKcal,
      AchievementCriterion.singleDuration =>
        metrics.maxSingleDurationSeconds.toDouble(),
      AchievementCriterion.bestDistanceUpdate =>
        metrics.bestDistanceUpdated ? 1.0 : 0.0,
      AchievementCriterion.bestDurationUpdate =>
        metrics.bestDurationUpdated ? 1.0 : 0.0,
      AchievementCriterion.gapRestartDays => metrics.maxGapDays.toDouble(),
      AchievementCriterion.leapDay => metrics.hasLeapDay ? 1.0 : 0.0,
      AchievementCriterion.dayMonth1111 => metrics.hasDay1111 ? 1.0 : 0.0,
      AchievementCriterion.recordCount => metrics.recordCount.toDouble(),
      AchievementCriterion.maxSameDayCount =>
        metrics.maxSameDayCount.toDouble(),
      AchievementCriterion.yearEndNewYearSeason =>
        metrics.maxYearEndSeasonDays.toDouble(),
    };
  }

  /// 定義と現在値から達成可否を判定する。
  ///
  /// [AchievementCriterion.gapRestartDays] だけは目標値を超えたとき（`>`）に達成。
  /// ほかは目標値以上（`>=`）。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static bool _isAchieved(
    AchievementDefinition definition,
    double current,
    _Metrics metrics,
  ) {
    return switch (definition.criterion) {
      AchievementCriterion.gapRestartDays =>
        metrics.maxGapDays > definition.target,
      AchievementCriterion.firstRecord ||
      AchievementCriterion.maxStreakDays ||
      AchievementCriterion.uniqueDays ||
      AchievementCriterion.totalDistanceKm ||
      AchievementCriterion.totalDuration ||
      AchievementCriterion.totalCaloriesKcal ||
      AchievementCriterion.singleDuration ||
      AchievementCriterion.bestDistanceUpdate ||
      AchievementCriterion.bestDurationUpdate ||
      AchievementCriterion.leapDay ||
      AchievementCriterion.dayMonth1111 ||
      AchievementCriterion.recordCount ||
      AchievementCriterion.maxSameDayCount ||
      AchievementCriterion.yearEndNewYearSeason => current >= definition.target,
    };
  }
}

/// 評価に使う集計値。
///
/// 履歴を 1 回走査して条件ごとの現在値の素を揃える。
final class _Metrics {
  /// 集計済みの素を保持する。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  const _Metrics({
    required this.recordCount,
    required this.uniqueDays,
    required this.maxStreakDays,
    required this.totalDistanceKm,
    required this.totalDurationSeconds,
    required this.totalCaloriesKcal,
    required this.maxSingleDurationSeconds,
    required this.bestDistanceUpdated,
    required this.bestDurationUpdated,
    required this.maxGapDays,
    required this.hasLeapDay,
    required this.hasDay1111,
    required this.maxSameDayCount,
    required this.maxYearEndSeasonDays,
  });

  /// 空履歴向けのゼロ集計。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static const empty = _Metrics(
    recordCount: 0,
    uniqueDays: 0,
    maxStreakDays: 0,
    totalDistanceKm: 0,
    totalDurationSeconds: 0,
    totalCaloriesKcal: 0,
    maxSingleDurationSeconds: 0,
    bestDistanceUpdated: false,
    bestDurationUpdated: false,
    maxGapDays: 0,
    hasLeapDay: false,
    hasDay1111: false,
    maxSameDayCount: 0,
    maxYearEndSeasonDays: 0,
  );

  /// [histories] から集計する。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static _Metrics from(List<ExerciseHistory> histories) {
    if (histories.isEmpty) {
      return empty;
    }

    final sortedByRecorded = [...histories]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final localDays = AchievementLocalDate.uniqueSortedDays(histories);
    final sameDayCounts = <DateTime, int>{};
    var totalDistanceKm = 0.0;
    var totalDurationSeconds = 0;
    var totalCaloriesKcal = 0.0;
    var maxSingleDurationSeconds = 0;
    var hasLeapDay = false;
    var hasDay1111 = false;

    for (final history in histories) {
      final day = AchievementLocalDate.fromHistory(history);
      sameDayCounts[day] = (sameDayCounts[day] ?? 0) + 1;
      totalDistanceKm += history.distanceKm;
      totalDurationSeconds += history.duration.inSeconds;
      totalCaloriesKcal += history.caloriesKcal;
      if (history.duration.inSeconds > maxSingleDurationSeconds) {
        maxSingleDurationSeconds = history.duration.inSeconds;
      }
      if (day.month == 2 && day.day == 29) {
        hasLeapDay = true;
      }
      if (day.month == 11 && day.day == 11) {
        hasDay1111 = true;
      }
    }

    var maxSameDayCount = 0;
    for (final count in sameDayCounts.values) {
      if (count > maxSameDayCount) {
        maxSameDayCount = count;
      }
    }

    return _Metrics(
      recordCount: histories.length,
      uniqueDays: localDays.length,
      maxStreakDays: _maxStreak(localDays),
      totalDistanceKm: totalDistanceKm,
      totalDurationSeconds: totalDurationSeconds,
      totalCaloriesKcal: totalCaloriesKcal,
      maxSingleDurationSeconds: maxSingleDurationSeconds,
      bestDistanceUpdated: _bestDistanceUpdated(sortedByRecorded),
      bestDurationUpdated: _bestDurationUpdated(sortedByRecorded),
      maxGapDays: _maxGapDays(localDays),
      hasLeapDay: hasLeapDay,
      hasDay1111: hasDay1111,
      maxSameDayCount: maxSameDayCount,
      maxYearEndSeasonDays: _maxYearEndSeasonDays(localDays.toSet()),
    );
  }

  /// 運動記録の件数。
  final int recordCount;

  /// ユニークな現地運動日数。
  final int uniqueDays;

  /// 史上最長の連続運動日数。
  final int maxStreakDays;

  /// 累計走行距離（km）。
  final double totalDistanceKm;

  /// 累計運動時間（秒）。
  final int totalDurationSeconds;

  /// 累計消費カロリー（kcal）。
  final double totalCaloriesKcal;

  /// 1 回あたりの最長運動時間（秒）。
  final int maxSingleDurationSeconds;

  /// 初回以外で過去最高距離を更新したか。
  final bool bestDistanceUpdated;

  /// 初回以外で過去最高時間を更新したか。
  final bool bestDurationUpdated;

  /// 隣接する運動日間隔の最大（日）。
  final int maxGapDays;

  /// 2 月 29 日の運動があるか。
  final bool hasLeapDay;

  /// 11 月 11 日の運動があるか。
  final bool hasDay1111;

  /// 同一日の最大運動回数。
  final int maxSameDayCount;

  /// 年末年始シーズンで最も多く揃った日数（最大 6）。
  final int maxYearEndSeasonDays;

  /// 昇順のユニーク日付から史上最長連続日数を求める。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static int _maxStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) {
      return 0;
    }
    var best = 1;
    var run = 1;
    for (var i = 1; i < sortedDays.length; i++) {
      final gap = AchievementLocalDate.calendarDaysBetween(
        sortedDays[i - 1],
        sortedDays[i],
      );
      if (gap == 1) {
        run += 1;
        if (run > best) {
          best = run;
        }
      } else {
        run = 1;
      }
    }
    return best;
  }

  /// 記録日時昇順で、2 件目以降に距離の厳密な自己ベスト更新があるか。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static bool _bestDistanceUpdated(List<ExerciseHistory> sortedByRecorded) {
    if (sortedByRecorded.length < 2) {
      return false;
    }
    var best = sortedByRecorded.first.distanceKm;
    for (var i = 1; i < sortedByRecorded.length; i++) {
      final distance = sortedByRecorded[i].distanceKm;
      if (distance > best) {
        return true;
      }
    }
    return false;
  }

  /// 記録日時昇順で、2 件目以降に時間の厳密な自己ベスト更新があるか。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static bool _bestDurationUpdated(List<ExerciseHistory> sortedByRecorded) {
    if (sortedByRecorded.length < 2) {
      return false;
    }
    var best = sortedByRecorded.first.duration;
    for (var i = 1; i < sortedByRecorded.length; i++) {
      final duration = sortedByRecorded[i].duration;
      if (duration > best) {
        return true;
      }
    }
    return false;
  }

  /// 隣接するユニーク運動日の差（日）の最大を返す。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static int _maxGapDays(List<DateTime> sortedDays) {
    if (sortedDays.length < 2) {
      return 0;
    }
    var maxGap = 0;
    for (var i = 1; i < sortedDays.length; i++) {
      final gap = AchievementLocalDate.calendarDaysBetween(
        sortedDays[i - 1],
        sortedDays[i],
      );
      if (gap > maxGap) {
        maxGap = gap;
      }
    }
    return maxGap;
  }

  /// 各年末年始シーズン（12/29–1/3）で揃った日数の最大を返す。
  ///
  /// Example:
  /// ```dart
  /// // パッケージ内からのみ利用する。
  /// ```
  static int _maxYearEndSeasonDays(Set<DateTime> days) {
    if (days.isEmpty) {
      return 0;
    }
    final years = <int>{};
    for (final day in days) {
      years.add(day.year);
      if (day.month == 1 && day.day <= 3) {
        years.add(day.year - 1);
      }
    }
    var best = 0;
    for (final year in years) {
      final seasonDays = [
        DateTime(year, 12, 29),
        DateTime(year, 12, 30),
        DateTime(year, 12, 31),
        DateTime(year + 1, 1, 1),
        DateTime(year + 1, 1, 2),
        DateTime(year + 1, 1, 3),
      ];
      var hit = 0;
      for (final seasonDay in seasonDays) {
        if (days.contains(seasonDay)) {
          hit += 1;
        }
      }
      if (hit > best) {
        best = hit;
      }
    }
    return best;
  }
}
