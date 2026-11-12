import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:test/test.dart';

ExerciseHistory _history({
  required String id,
  required DateTime creationStartedAt,
  required Duration duration,
}) {
  return ExerciseHistory(
    id: id,
    savedAt: creationStartedAt,
    creationStartedAt: creationStartedAt,
    capturedAt: creationStartedAt,
    recordedAt: creationStartedAt,
    recordedAtManuallySet: false,
    distanceKm: 1,
    duration: duration,
    caloriesKcal: 1,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
  );
}

void main() {
  test('履歴0件なら null', () {
    expect(
      ExerciseReminderSchedule.compute(
        histories: const [],
        now: DateTime(2026, 11, 10, 12),
      ),
      isNull,
    );
  });

  test('当日に作成開始の履歴があれば null', () {
    final now = DateTime(2026, 11, 10, 12);
    final result = ExerciseReminderSchedule.compute(
      histories: [
        _history(
          id: '1',
          creationStartedAt: DateTime(2026, 11, 10, 9),
          duration: const Duration(minutes: 30),
        ),
      ],
      now: now,
    );
    expect(result, isNull);
  });

  test('1日分の平均から差し引き、未来ならその時刻', () {
    final now = DateTime(2026, 11, 10, 8);
    final result = ExerciseReminderSchedule.compute(
      histories: [
        _history(
          id: '1',
          creationStartedAt: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
      ],
      now: now,
    );
    expect(result, DateTime(2026, 11, 10, 17));
  });

  test('過去時刻なら null', () {
    final now = DateTime(2026, 11, 10, 18);
    final result = ExerciseReminderSchedule.compute(
      histories: [
        _history(
          id: '1',
          creationStartedAt: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
      ],
      now: now,
    );
    expect(result, isNull);
  });

  test('同一日は最新の作成開始を代表にする', () {
    final now = DateTime(2026, 11, 10, 8);
    final result = ExerciseReminderSchedule.compute(
      histories: [
        _history(
          id: 'old',
          creationStartedAt: DateTime(2026, 11, 9, 10),
          duration: const Duration(hours: 2),
        ),
        _history(
          id: 'new',
          creationStartedAt: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
      ],
      now: now,
    );
    expect(result, DateTime(2026, 11, 10, 17));
  });

  test('2日分の秒平均を切り捨てて差し引く', () {
    final now = DateTime(2026, 11, 10, 8);
    // day1: 18:00 start, 60m ; day2: 19:00 start, 30m
    // avgStart = (18*3600 + 19*3600) / 2 = 66600
    // avgDuration = (3600 + 1800) / 2 = 2700
    // candidate = 0:00 + 63900s = 17:45
    final result = ExerciseReminderSchedule.compute(
      histories: [
        _history(
          id: '1',
          creationStartedAt: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
        _history(
          id: '2',
          creationStartedAt: DateTime(2026, 11, 8, 19),
          duration: const Duration(minutes: 30),
        ),
      ],
      now: now,
    );
    expect(result, DateTime(2026, 11, 10, 17, 45));
  });

  test('開始平均より運動時間が長いときは null', () {
    final now = DateTime(2026, 11, 10, 8);
    final result = ExerciseReminderSchedule.compute(
      histories: [
        _history(
          id: '1',
          creationStartedAt: DateTime(2026, 11, 9, 0, 30),
          duration: const Duration(hours: 1),
        ),
      ],
      now: now,
    );
    expect(result, isNull);
  });
}
