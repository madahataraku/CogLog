import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';

/// 登録可能条件を満たすときだけ永続化し、ヘルス失敗でも成功とする。
///
/// Example:
/// ```dart
/// SaveMeterCaptureUsecaseImpl(histories: histories, health: health).execute(
///   SaveMeterCaptureRequest(
///     creationStartedAt: DateTime.timestamp(),
///     capturedAt: DateTime.timestamp(),
///     recordedAt: DateTime.timestamp(),
///     recordedAtManuallySet: false,
///     distanceKm: 1,
///     duration: const Duration(minutes: 1),
///     caloriesKcal: 1,
///     averageSpeedKmh: 1,
///     photoBytes: Uint8List(0),
///   ),
/// );
/// ```
final class SaveMeterCaptureUsecaseImpl implements SaveMeterCaptureUsecase {
  /// [histories] と [health] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// SaveMeterCaptureUsecaseImpl(histories: histories, health: health);
  /// ```
  const SaveMeterCaptureUsecaseImpl({
    required this.histories,
    required this.health,
  });

  /// 運動履歴の保存先。
  final ExerciseHistoryRepository histories;

  /// ヘルスへのサイクリング書き込み。
  final HealthWorkoutWriter health;

  /// [request] を検証し、作成後にヘルスへ書く。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   SaveMeterCaptureRequest(
  ///     creationStartedAt: DateTime.timestamp(),
  ///     capturedAt: DateTime.timestamp(),
  ///     recordedAt: DateTime.timestamp(),
  ///     recordedAtManuallySet: false,
  ///     distanceKm: 1,
  ///     duration: const Duration(minutes: 1),
  ///     caloriesKcal: 1,
  ///     averageSpeedKmh: 1,
  ///     photoBytes: Uint8List(0),
  ///   ),
  /// );
  /// ```
  @override
  Future<SaveMeterCaptureResult> execute(
    SaveMeterCaptureRequest request,
  ) async {
    if (!_isValid(request)) {
      return const SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.invalidInput,
      );
    }

    try {
      final history = await histories.create(
        creationStartedAt: request.creationStartedAt,
        capturedAt: request.capturedAt,
        recordedAt: request.recordedAt,
        recordedAtManuallySet: request.recordedAtManuallySet,
        distanceKm: request.distanceKm,
        duration: request.duration,
        caloriesKcal: request.caloriesKcal,
        averageSpeedKmh: request.averageSpeedKmh,
        photoBytes: request.photoBytes,
      );

      final healthWriteSucceeded = await _writeHealth(request);

      return SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.success,
        history: history,
        healthWriteSucceeded: healthWriteSucceeded,
      );
    } on Object {
      return const SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.saveFailed,
      );
    }
  }

  /// 登録可能条件を満たすか。
  ///
  /// Example:
  /// ```dart
  /// _isValid(request);
  /// ```
  static bool _isValid(SaveMeterCaptureRequest request) {
    if (request.duration <= Duration.zero) {
      return false;
    }
    if (request.distanceKm < 0 ||
        request.averageSpeedKmh < 0 ||
        request.caloriesKcal < 0) {
      return false;
    }
    return true;
  }

  /// ヘルスへ書き、失敗や例外は false にする。
  ///
  /// Example:
  /// ```dart
  /// await _writeHealth(request);
  /// ```
  Future<bool> _writeHealth(SaveMeterCaptureRequest request) async {
    try {
      final start = request.recordedAt;
      final end = request.recordedAt.add(request.duration);
      return await health.writeCycling(
        start: start,
        end: end,
        distanceKm: request.distanceKm,
        duration: request.duration,
        caloriesKcal: request.caloriesKcal,
      );
    } on Object {
      return false;
    }
  }
}
