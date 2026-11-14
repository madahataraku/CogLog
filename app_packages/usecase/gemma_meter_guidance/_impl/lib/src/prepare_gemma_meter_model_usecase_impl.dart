import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_network_connectivity/infra_network_connectivity.dart';
import 'package:usecase_gemma_meter_guidance/usecase_gemma_meter_guidance.dart';

/// Wi-Fi 確認のうえ [GemmaMeterVision.prepareModel] へ委譲する実装。
///
/// Example:
/// ```dart
/// PrepareGemmaMeterModelUsecaseImpl(network: network, gemma: gemma);
/// ```
final class PrepareGemmaMeterModelUsecaseImpl
    implements PrepareGemmaMeterModelUsecase {
  /// [network] と [gemma] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// PrepareGemmaMeterModelUsecaseImpl(network: network, gemma: gemma);
  /// ```
  PrepareGemmaMeterModelUsecaseImpl({
    required this.network,
    required this.gemma,
  });

  /// Wi-Fi 判定。
  final NetworkConnectivity network;

  /// Gemma メーター経路。
  final GemmaMeterVision gemma;

  /// Wi-Fi 以外なら [GemmaMeterPrepareFailureKind.wifiRequired] で失敗する。
  /// Wi-Fi なら [GemmaMeterVision.prepareModel] の進捗を流す。
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
      throw const GemmaMeterPrepareException(
        GemmaMeterPrepareFailureKind.wifiRequired,
      );
    }
    yield* gemma.prepareModel();
  }
}
