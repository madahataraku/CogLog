import 'package:health/health.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';

/// `health` パッケージ経由の身体指標ソース。
///
/// 体重・体脂肪率・除脂肪体重を READ で扱う。値は kg / % に正規化する。
/// HealthKit entitlement が無い環境では許可拒否や空読取になり得る。
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
  HealthBodyPermissionStatus _mapHasPermissions(bool? granted) {
    if (granted == true) {
      return HealthBodyPermissionStatus.granted;
    }
    if (granted == false) {
      return HealthBodyPermissionStatus.denied;
    }
    return HealthBodyPermissionStatus.unknown;
  }

  /// いまの許可状態を返す。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageBodyMetricsSource().permissionStatus();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> permissionStatus() async {
    await _ensureConfigured();
    final granted = await _health.hasPermissions(_types);
    return _mapHasPermissions(granted);
  }

  /// 3 指標まとめて許可を求め、拒否の連続は永久拒否に寄せる。
  ///
  /// Example:
  /// ```dart
  /// await HealthPackageBodyMetricsSource().requestPermission();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> requestPermission() async {
    await _ensureConfigured();
    final before = _mapHasPermissions(await _health.hasPermissions(_types));
    if (before == HealthBodyPermissionStatus.granted) {
      return HealthBodyPermissionStatus.granted;
    }
    await _health.requestAuthorization(_types);
    final after = _mapHasPermissions(await _health.hasPermissions(_types));
    if (after == HealthBodyPermissionStatus.granted) {
      return HealthBodyPermissionStatus.granted;
    }
    if (before == HealthBodyPermissionStatus.denied &&
        after == HealthBodyPermissionStatus.denied) {
      return HealthBodyPermissionStatus.permanentlyDenied;
    }
    return after;
  }

  /// `[startInclusive, endExclusive)` の計測を返す。失敗時は例外。
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
    await _ensureConfigured();
    try {
      final points = await _health.getHealthDataFromTypes(
        types: _types,
        preferredUnits: _preferredUnits,
        startTime: startInclusive,
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
  double? _toPercent(double raw, HealthDataUnit unit) {
    return switch (unit) {
      HealthDataUnit.PERCENT => raw,
      _ => null,
    };
  }
}
