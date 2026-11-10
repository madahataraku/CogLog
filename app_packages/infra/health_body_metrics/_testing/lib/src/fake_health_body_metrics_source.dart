import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';

/// テストから状態とサンプルを差し替える身体指標ソース。
///
/// Example:
/// ```dart
/// FakeHealthBodyMetricsSource(
///   status: HealthBodyPermissionStatus.granted,
/// );
/// ```
final class FakeHealthBodyMetricsSource implements HealthBodyMetricsSource {
  /// [status]・[samples]・[throwOnRead]・[throwOnPermissionStatus]・[requestResult] を差し替え可能にする。
  ///
  /// Example:
  /// ```dart
  /// FakeHealthBodyMetricsSource();
  /// ```
  FakeHealthBodyMetricsSource({
    this.status = HealthBodyPermissionStatus.unknown,
    List<HealthBodySample> samples = const [],
    this.throwOnRead = false,
    this.throwOnPermissionStatus = false,
    this.requestResult,
  }) : samples = List<HealthBodySample>.from(samples);

  /// [permissionStatus] が返す許可状態。
  HealthBodyPermissionStatus status;

  /// [read] が返す候補サンプル。期間外は除外する。
  List<HealthBodySample> samples;

  /// true のとき [read] が [HealthBodyMetricsReadException] を投げる。
  bool throwOnRead;

  /// true のとき [permissionStatus] が例外を投げる。
  bool throwOnPermissionStatus;

  /// [requestPermission] が返す値。null なら granted にする。
  HealthBodyPermissionStatus? requestResult;

  /// [requestPermission] が呼ばれた回数。
  int requestCallCount = 0;

  /// [read] が呼ばれた回数。
  int readCallCount = 0;

  /// [status] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthBodyMetricsSource().permissionStatus();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> permissionStatus() async {
    if (throwOnPermissionStatus) {
      throw StateError('fake permissionStatus failure');
    }
    return status;
  }

  /// [requestResult] または granted を [status] に書き戻して返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthBodyMetricsSource(
  ///   requestResult: HealthBodyPermissionStatus.granted,
  /// ).requestPermission();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> requestPermission() async {
    requestCallCount += 1;
    final next = requestResult ?? HealthBodyPermissionStatus.granted;
    status = next;
    return next;
  }

  /// [throwOnRead] か、許可時の期間内 [samples] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthBodyMetricsSource(
  ///   status: HealthBodyPermissionStatus.granted,
  /// ).read(
  ///   startInclusive: DateTime(2026, 10, 12),
  ///   endExclusive: DateTime(2026, 11, 11),
  /// );
  /// ```
  @override
  Future<List<HealthBodySample>> read({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    readCallCount += 1;
    if (throwOnRead) {
      throw const HealthBodyMetricsReadException('fake read failure');
    }
    // iOS と同様、unknown でも読取を試し、denied 系だけ空にする。
    if (status == HealthBodyPermissionStatus.denied ||
        status == HealthBodyPermissionStatus.permanentlyDenied) {
      return const [];
    }
    return [
      for (final sample in samples)
        if (!sample.at.toLocal().isBefore(startInclusive) &&
            sample.at.toLocal().isBefore(endExclusive))
          sample,
    ];
  }
}
