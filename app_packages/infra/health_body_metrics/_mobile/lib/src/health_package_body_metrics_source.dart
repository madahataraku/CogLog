import 'dart:io';

import 'package:health/health.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';

/// `health` パッケージ経由の身体指標ソース。
///
/// 体重・体脂肪率・除脂肪体重を READ で扱う。値は kg / % に正規化する。
/// HealthKit entitlement（`com.apple.developer.healthkit`）は署名準備後に
/// Runner へ有効化する。未設定のままでも unsigned / 開発ビルドは壊さない。
///
/// Example:
/// ```dart
/// HealthPackageBodyMetricsSource();
/// ```
final class HealthPackageBodyMetricsSource implements HealthBodyMetricsSource {
  /// [health] を差し替え可能にした実装を作る。省略時は新規 [Health]。
  ///
  /// Example:
  /// ```dart
  /// HealthPackageBodyMetricsSource();
  /// ```
  HealthPackageBodyMetricsSource({Health? health})
    : _health = health ?? Health();

  static const _types = <HealthDataType>[
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.LEAN_BODY_MASS,
  ];

  static const _preferredUnits = <HealthDataType, HealthDataUnit>{
    HealthDataType.WEIGHT: HealthDataUnit.KILOGRAM,
    HealthDataType.BODY_FAT_PERCENTAGE: HealthDataUnit.PERCENT,
    HealthDataType.LEAN_BODY_MASS: HealthDataUnit.KILOGRAM,
  };

  final Health _health;
  var _configured = false;

  /// プラグインを一度だけ構成する。
  Future<void> _ensureConfigured() async {
    if (_configured) {
      return;
    }
    await _health.configure();
    _configured = true;
  }

  /// [hasPermissions] の結果を [HealthBodyPermissionStatus] へ写す。
  ///
  /// iOS の READ は `null`（unknown）になり得る。呼び出し側は unknown でも
  /// 読取を試し、空結果を「データなし／未許可」として扱う。
  HealthBodyPermissionStatus _mapHasPermissions(bool? granted) {
    if (granted == true) {
      return HealthBodyPermissionStatus.granted;
    }
    if (granted == false) {
      return HealthBodyPermissionStatus.denied;
    }
    return HealthBodyPermissionStatus.unknown;
  }

  /// いまの許可状態を返す。失敗時は unknown。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageBodyMetricsSource().permissionStatus();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> permissionStatus() async {
    try {
      await _ensureConfigured();
      final granted = await _health.hasPermissions(_types);
      return _mapHasPermissions(granted);
    } catch (_) {
      return HealthBodyPermissionStatus.unknown;
    }
  }

  /// 3 指標まとめて許可を求める。iOS は再実行しても安全で、結果は unknown になり得る。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageBodyMetricsSource().requestPermission();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> requestPermission() async {
    await _ensureConfigured();
    if (Platform.isIOS) {
      await _health.requestAuthorization(_types);
      return _mapHasPermissions(await _health.hasPermissions(_types));
    }

    final before = _mapHasPermissions(await _health.hasPermissions(_types));
    if (before == HealthBodyPermissionStatus.granted) {
      await _ensureHistoryAuthorization();
      return HealthBodyPermissionStatus.granted;
    }
    await _health.requestAuthorization(_types);
    await _ensureHistoryAuthorization();
    return _mapHasPermissions(await _health.hasPermissions(_types));
  }

  /// Android の履歴許可が未取得なら要求する。
  Future<void> _ensureHistoryAuthorization() async {
    if (!Platform.isAndroid) {
      return;
    }
    final authorized = await _health.isHealthDataHistoryAuthorized();
    if (authorized) {
      return;
    }
    await _health.requestHealthDataHistoryAuthorization();
  }

  /// `[startInclusive, endExclusive)` の計測を返す。失敗時は例外。
  ///
  /// Android で履歴許可が無いときは開始を直近 30 暦日に切り詰める。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageBodyMetricsSource().read(
  ///   startInclusive: DateTime(2026, 10, 12),
  ///   endExclusive: DateTime(2026, 11, 11),
  /// );
  /// ```
  @override
  Future<List<HealthBodySample>> read({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    try {
      await _ensureConfigured();
      var start = startInclusive;
      if (Platform.isAndroid) {
        final historyOk = await _health.isHealthDataHistoryAuthorized();
        if (!historyOk) {
          final localNow = DateTime.now().toLocal();
          final floor = DateTime(
            localNow.year,
            localNow.month,
            localNow.day - 29,
          );
          if (start.isBefore(floor)) {
            start = floor;
          }
        }
      }
      final points = await _health.getHealthDataFromTypes(
        types: _types,
        preferredUnits: _preferredUnits,
        startTime: start,
        endTime: endExclusive,
      );
      final out = <HealthBodySample>[];
      for (final point in points) {
        final sample = _toSample(point);
        if (sample == null) {
          continue;
        }
        final local = sample.at.toLocal();
        if (local.isBefore(startInclusive) || !local.isBefore(endExclusive)) {
          continue;
        }
        out.add(sample);
      }
      return out;
    } on HealthBodyMetricsReadException {
      rethrow;
    } catch (error) {
      throw HealthBodyMetricsReadException(error.toString());
    }
  }

  /// [point] を正規化済み [HealthBodySample] へ写す。変換不可なら null。
  HealthBodySample? _toSample(HealthDataPoint point) {
    final kind = switch (point.type) {
      HealthDataType.WEIGHT => HealthBodyMetricKind.weightKg,
      HealthDataType.BODY_FAT_PERCENTAGE => HealthBodyMetricKind.bodyFatPercent,
      HealthDataType.LEAN_BODY_MASS => HealthBodyMetricKind.leanMassKg,
      _ => null,
    };
    if (kind == null) {
      return null;
    }
    final value = point.value;
    if (value is! NumericHealthValue) {
      return null;
    }
    final raw = value.numericValue.toDouble();
    final normalized = switch (kind) {
      HealthBodyMetricKind.weightKg ||
      HealthBodyMetricKind.leanMassKg => _toKilograms(raw, point.unit),
      HealthBodyMetricKind.bodyFatPercent => _toPercent(raw, point.unit),
    };
    if (normalized == null) {
      return null;
    }
    return HealthBodySample(kind: kind, at: point.dateFrom, value: normalized);
  }

  /// 質量単位を kg へ正規化する。未知単位は null。
  double? _toKilograms(double raw, HealthDataUnit unit) {
    return switch (unit) {
      HealthDataUnit.KILOGRAM => raw,
      HealthDataUnit.GRAM => raw / 1000,
      HealthDataUnit.POUND => raw * 0.45359237,
      HealthDataUnit.OUNCE => raw * 0.028349523125,
      HealthDataUnit.STONE => raw * 6.35029318,
      _ => null,
    };
  }

  /// 体脂肪を 0–100 の % へ正規化する。未知単位は null。
  ///
  /// iOS HealthKit は 0–1 分数で返すことがあるため、そのときは 100 倍する。
  double? _toPercent(double raw, HealthDataUnit unit) {
    return switch (unit) {
      HealthDataUnit.PERCENT =>
        (Platform.isIOS && raw <= 1.0) ? raw * 100 : raw,
      _ => null,
    };
  }
}
