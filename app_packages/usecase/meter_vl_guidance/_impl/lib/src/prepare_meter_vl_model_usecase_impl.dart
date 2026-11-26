import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_network_connectivity/infra_network_connectivity.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// Wi-Fi 確認のうえ [MeterVlVision.prepareModel] へ委譲する実装。
///
/// Example:
/// ```dart
/// PrepareMeterVlModelUsecaseImpl(network: network, meterVl: meterVl);
/// ```
final class PrepareMeterVlModelUsecaseImpl
    implements PrepareMeterVlModelUsecase {
  /// [network] と [meterVl] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// PrepareMeterVlModelUsecaseImpl(network: network, meterVl: meterVl);
  /// ```
  PrepareMeterVlModelUsecaseImpl({
    required this.network,
    required this.meterVl,
  });

  /// Wi-Fi 判定。
  final NetworkConnectivity network;

  /// メーター VL経路。
  final MeterVlVision meterVl;

  /// Wi-Fi 以外なら [MeterVlPrepareFailureKind.wifiRequired] で失敗する。
  /// Wi-Fi なら [MeterVlVision.prepareModel] の進捗を流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in usecase.execute()) {
  ///   progress;
  /// }
  /// ```
  @override
  Stream<double> execute() async* {
    if (!await network.isWifi) {
      throw const MeterVlPrepareException(
        MeterVlPrepareFailureKind.wifiRequired,
      );
    }
    yield* meterVl.prepareModel();
  }
}
