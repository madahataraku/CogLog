import 'dart:io';

import 'package:health/health.dart';
import 'package:infra_health_workout/infra_health_workout.dart';

import 'workout_write_units.dart';

/// `health` パッケージ経由のサイクリング書き込み。
///
/// Example:
/// ```dart
/// HealthPackageWorkoutWriter();
/// ```
final class HealthPackageWorkoutWriter implements HealthWorkoutWriter {
  /// [health] を差し替え可能にした実装を作る。省略時は新規 [Health]。
  ///
  /// Example:
  /// ```dart
  /// HealthPackageWorkoutWriter();
  /// ```
  HealthPackageWorkoutWriter({Health? health}) : _health = health ?? Health();

  final Health _health;
  var _configured = false;

  static const _candidateTypes = <HealthDataType>[
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  /// プラグイン構成・HC 可用性・WRITE 権限を一度に整える。
  ///
  /// 書き込み可能なら true。未導入・部分許可・例外は false。
  Future<bool> _prepareForWrite() async {
    await _ensureConfigured();
    if (!await _ensureHealthConnectOnAndroid()) {
      return false;
    }
    await _requestWritePermission();
    return _hasAllWritePermissions();
  }

  /// プラグインを一度だけ構成する。
  Future<void> _ensureConfigured() async {
    if (_configured) {
      return;
    }
    await _health.configure();
    _configured = true;
  }

  /// 端末で使える書き込み候補型だけを返す。
  List<HealthDataType> _writableTypes() => [
    for (final type in _candidateTypes)
      if (_health.isDataTypeAvailable(type)) type,
  ];

  /// Android でヘルスコネクトが使えるか。iOS は常に true。
  Future<bool> _ensureHealthConnectOnAndroid() async {
    if (!Platform.isAndroid) {
      return true;
    }
    try {
      return await _health.isHealthConnectAvailable();
    } on Object {
      // 可用性問い合わせ失敗は未導入と同様に書き込み不可とする。
      return false;
    }
  }

  /// サイクリング書き込みに必要な WRITE 権限を要求する。
  Future<void> _requestWritePermission() async {
    final types = _writableTypes();
    if (types.isEmpty) {
      return;
    }
    await _health.requestAuthorization(
      types,
      permissions: List.filled(types.length, HealthDataAccess.WRITE),
    );
  }

  /// Android は全 WRITE 必須。iOS は開示しないため true（実書き込みで判定）。
  Future<bool> _hasAllWritePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final types = _writableTypes();
    if (types.isEmpty) {
      return false;
    }
    final grantedByType = <HealthDataType, bool?>{};
    for (final type in types) {
      grantedByType[type] = await _health.hasPermissions(
        [type],
        permissions: [HealthDataAccess.WRITE],
      );
    }
    return allWritePermissionsGranted(grantedByType);
  }

  /// 準備済み前提でサイクリングを書き、成功時は外部 ID を返す。
  Future<String?> _writeCyclingAfterPrepare({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required double caloriesKcal,
  }) async {
    final uuid = await _health.writeWorkoutDataUUID(
      activityType: HealthWorkoutActivityType.BIKING,
      start: start,
      end: end,
      totalEnergyBurned: caloriesKcalToInt(caloriesKcal),
      totalDistance: distanceKmToMeters(distanceKm),
      recordingMethod: RecordingMethod.manual,
    );
    return isValidWorkoutUuid(uuid) ? uuid : null;
  }

  /// サイクリングを書き、成功時は外部 ID を返す。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageWorkoutWriter().writeCycling(
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  /// );
  /// ```
  @override
  Future<String?> writeCycling({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  }) async {
    try {
      if (!await _prepareForWrite()) {
        return null;
      }
      return await _writeCyclingAfterPrepare(
        start: start,
        end: end,
        distanceKm: distanceKm,
        caloriesKcal: caloriesKcal,
      );
    } on Object {
      // 権限拒否・プラグイン例外でも呼び出し元へ投げず失敗（null）とする。
      return null;
    }
  }

  /// 新しいサイクリングを先に書き、外部 ID を返す（旧レコードは消さない）。
  ///
  /// 旧 ID の削除は呼び出し側が、ローカルへの新 ID 付与成功後に行う。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageWorkoutWriter().updateCycling(
  ///   externalId: 'health-1',
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  /// );
  /// ```
  @override
  Future<String?> updateCycling({
    required String externalId,
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  }) async {
    try {
      // externalId は呼び出し側が旧削除に使う。空なら更新対象が無いので失敗。
      if (externalId.isEmpty) {
        return null;
      }
      if (!await _prepareForWrite()) {
        return null;
      }
      return await _writeCyclingAfterPrepare(
        start: start,
        end: end,
        distanceKm: distanceKm,
        caloriesKcal: caloriesKcal,
      );
    } on Object {
      // 更新経路の例外も失敗（null）に畳み、Usecase のローカル成功を守る。
      return null;
    }
  }

  /// [externalId] のサイクリングを消す。成功時 true。
  ///
  /// Android では距離・カロリーが別レコードのため、[start]〜[end] の時間窓でも消す。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageWorkoutWriter().deleteCycling(
  ///   externalId: 'health-1',
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  /// );
  /// ```
  @override
  Future<bool> deleteCycling({
    required String externalId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await _ensureConfigured();
      if (!await _ensureHealthConnectOnAndroid()) {
        return false;
      }
      final workoutDeleted = await _health.deleteByUUID(
        uuid: externalId,
        type: HealthDataType.WORKOUT,
      );
      if (Platform.isAndroid) {
        await _deleteAndroidCompanionRecords(start: start, end: end);
      }
      return workoutDeleted;
    } on Object {
      // 削除失敗を例外にせず false を返し、ローカル削除 success を維持する。
      return false;
    }
  }

  /// Android の付随距離・カロリーを時間窓で消す（自アプリ分のみ）。
  Future<void> _deleteAndroidCompanionRecords({
    required DateTime start,
    required DateTime end,
  }) async {
    for (final type in const [
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.TOTAL_CALORIES_BURNED,
    ]) {
      if (!_health.isDataTypeAvailable(type)) {
        continue;
      }
      try {
        await _health.delete(type: type, startTime: start, endTime: end);
      } on Object {
        // 付随削除の失敗でワークアウト削除結果を覆さない。
      }
    }
  }
}
