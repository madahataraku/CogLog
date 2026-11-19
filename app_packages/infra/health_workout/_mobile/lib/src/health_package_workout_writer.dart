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
      await _ensureConfigured();
      if (!await _ensureHealthConnectOnAndroid()) {
        return null;
      }
      await _requestWritePermission();
      if (!await _hasAllWritePermissions()) {
        return null;
      }
      final uuid = await _health.writeWorkoutDataUUID(
        activityType: HealthWorkoutActivityType.BIKING,
        start: start,
        end: end,
        totalEnergyBurned: caloriesKcalToInt(caloriesKcal),
        totalDistance: distanceKmToMeters(distanceKm),
        recordingMethod: RecordingMethod.manual,
      );
      return isValidWorkoutUuid(uuid) ? uuid : null;
    } on Object {
      // 権限拒否・プラグイン例外でも呼び出し元へ投げず失敗（null）とする。
      return null;
    }
  }

  /// 既存 ID を消しつつ書き直し、新しい外部 ID を返す。
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
      await _ensureConfigured();
      if (!await _ensureHealthConnectOnAndroid()) {
        return null;
      }
      await _requestWritePermission();
      try {
        await _health.deleteByUUID(
          uuid: externalId,
          type: HealthDataType.WORKOUT,
        );
      } on Object {
        // 旧レコード欠落・削除失敗でも新規書き込みを試し、ローカル更新を止めない。
      }
      return await writeCycling(
        start: start,
        end: end,
        distanceKm: distanceKm,
        duration: duration,
        caloriesKcal: caloriesKcal,
      );
    } on Object {
      // 更新経路の例外も失敗（null）に畳み、Usecase のローカル成功を守る。
      return null;
    }
  }

  /// [externalId] のサイクリングを消す。成功時 true。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageWorkoutWriter().deleteCycling(externalId: 'health-1');
  /// ```
  @override
  Future<bool> deleteCycling({required String externalId}) async {
    try {
      await _ensureConfigured();
      if (!await _ensureHealthConnectOnAndroid()) {
        return false;
      }
      return await _health.deleteByUUID(
        uuid: externalId,
        type: HealthDataType.WORKOUT,
      );
    } on Object {
      // 削除失敗を例外にせず false を返し、ローカル削除 success を維持する。
      return false;
    }
  }
}
