import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/exercise_history_edit_screen_state.dart';

/// 運動時間の時の上限。
@visibleForTesting
const maxExerciseHistoryEditHours = 99;

/// 運動時間の分・秒の上限。
@visibleForTesting
const maxExerciseHistoryEditMinutesOrSeconds = 59;

/// 空は未入力 null。非空は非負 finite。負・非数はパース失敗。
///
/// Example:
/// ```dart
/// parseNonNegativeDoubleOrNull('1.5');
/// ```
@visibleForTesting
double? parseNonNegativeDoubleOrNull(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final value = double.tryParse(trimmed);
  if (value == null || !value.isFinite || value < 0) {
    throw const FormatException('non-negative double expected');
  }
  return value;
}

/// 時分秒テキストから Duration。すべて空なら null。不正は失敗。
///
/// Example:
/// ```dart
/// parseDurationOrNull(hours: '0', minutes: '30', seconds: '0');
/// ```
@visibleForTesting
Duration? parseDurationOrNull({
  required String hours,
  required String minutes,
  required String seconds,
}) {
  final h = hours.trim();
  final m = minutes.trim();
  final s = seconds.trim();
  if (h.isEmpty && m.isEmpty && s.isEmpty) {
    return null;
  }
  final hoursValue = _parseNonNegativeIntOrZeroWhenEmpty(
    h,
    max: maxExerciseHistoryEditHours,
  );
  final minutesValue = _parseNonNegativeIntOrZeroWhenEmpty(
    m,
    max: maxExerciseHistoryEditMinutesOrSeconds,
  );
  final secondsValue = _parseNonNegativeIntOrZeroWhenEmpty(
    s,
    max: maxExerciseHistoryEditMinutesOrSeconds,
  );
  if (hoursValue == null || minutesValue == null || secondsValue == null) {
    throw const FormatException('duration fields invalid');
  }
  return Duration(
    hours: hoursValue,
    minutes: minutesValue,
    seconds: secondsValue,
  );
}

/// 空は 0、それ以外は 0 以上 [max] 以下の整数だけ通す。不正なら null。
///
/// Example:
/// ```dart
/// _parseNonNegativeIntOrZeroWhenEmpty('30', max: 59);
/// ```
int? _parseNonNegativeIntOrZeroWhenEmpty(String trimmed, {required int max}) {
  if (trimmed.isEmpty) {
    return 0;
  }
  final value = int.tryParse(trimmed);
  if (value == null || value < 0 || value > max) {
    return null;
  }
  return value;
}

/// 入力欄の変更を State へ反映し、平均速度を距離÷時間で再計算する。
///
/// Example:
/// ```dart
/// OnFieldChangedDelegate(state: state).updateDistance('1.5');
/// ```
@internal
final class OnFieldChangedDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnFieldChangedDelegate(state: state);
  /// ```
  const OnFieldChangedDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// 走行距離を更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.updateDistance('1.5');
  /// ```
  Future<void> updateDistance(String raw) async {
    late final double? distanceKm;
    try {
      distanceKm = parseNonNegativeDoubleOrNull(raw);
    } on FormatException {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(distanceInvalid: true, dirty: true),
        );
      });
      return;
    }
    await state.updateWithLock((current, emitter) async {
      final speed = _speed(distanceKm: distanceKm, duration: current.duration);
      await emitter.emit(
        current.copyWith(
          distanceKm: distanceKm,
          clearDistanceKm: distanceKm == null,
          averageSpeedKmh: speed,
          clearAverageSpeedKmh: speed == null,
          distanceInvalid: false,
          dirty: true,
        ),
      );
    });
  }

  /// 運動時間を更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.updateDuration(hours: '0', minutes: '30', seconds: '0');
  /// ```
  Future<void> updateDuration({
    required String hours,
    required String minutes,
    required String seconds,
  }) async {
    late final Duration? duration;
    try {
      duration = parseDurationOrNull(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
    } on FormatException {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(durationInvalid: true, dirty: true),
        );
      });
      return;
    }
    await state.updateWithLock((current, emitter) async {
      final speed = _speed(distanceKm: current.distanceKm, duration: duration);
      await emitter.emit(
        current.copyWith(
          duration: duration,
          clearDuration: duration == null,
          averageSpeedKmh: speed,
          clearAverageSpeedKmh: speed == null,
          durationInvalid: false,
          dirty: true,
        ),
      );
    });
  }

  /// 消費カロリーを更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.updateCalories('100');
  /// ```
  Future<void> updateCalories(String raw) async {
    late final double? caloriesKcal;
    try {
      caloriesKcal = parseNonNegativeDoubleOrNull(raw);
    } on FormatException {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(caloriesInvalid: true, dirty: true),
        );
      });
      return;
    }
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          caloriesKcal: caloriesKcal,
          clearCaloriesKcal: caloriesKcal == null,
          caloriesInvalid: false,
          dirty: true,
        ),
      );
    });
  }

  /// 運動した日時を更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.updateRecordedAt(DateTime(2026, 11, 8, 12));
  /// ```
  Future<void> updateRecordedAt(DateTime value) async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          recordedAt: value,
          recordedAtManuallySet: true,
          recordedAtInvalid: false,
          dirty: true,
        ),
      );
    });
  }
}

/// 距離と時間が揃っているときだけ平均速度を再計算する。欠けていれば null。
///
/// Example:
/// ```dart
/// _speed(distanceKm: 1, duration: const Duration(minutes: 1));
/// ```
double? _speed({required double? distanceKm, required Duration? duration}) {
  if (distanceKm == null || duration == null) {
    return null;
  }
  return calculateAverageSpeedKmh(distanceKm: distanceKm, duration: duration);
}
