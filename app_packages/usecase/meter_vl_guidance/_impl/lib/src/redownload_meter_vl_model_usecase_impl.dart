import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_network_connectivity/infra_network_connectivity.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// Wi-Fi 確認のうえ削除し、[MeterVlVision.prepareModel] へ委譲する実装。
///
/// Example:
/// ```dart
/// RedownloadMeterVlModelUsecaseImpl(network: network, meterVl: meterVl);
/// ```
final class RedownloadMeterVlModelUsecaseImpl
    implements RedownloadMeterVlModelUsecase {
  /// [network] と [meterVl] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// RedownloadMeterVlModelUsecaseImpl(network: network, meterVl: meterVl);
  /// ```
  RedownloadMeterVlModelUsecaseImpl({
    required this.network,
    required this.meterVl,
  });

  /// Wi-Fi 必須判定に使う接続状態。
  final NetworkConnectivity network;

  /// 削除と prepare を委譲するメーター VL 実装。
  final MeterVlVision meterVl;

  /// Wi-Fi 確認 → 削除 → busy 再確認 → prepare 進捗を流す。
  ///
  /// 非 Wi-Fi・削除失敗・削除直後 busy・prepare 失敗は
  /// [MeterVlPrepareException]。誘導フラグは触らない。
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
    await meterVl.deleteDownloadedModels();
    // delete 解放後〜prepare 開始前に generate 等が入った場合は競合として止める。
    if (await meterVl.isOperationBusy) {
      throw const MeterVlPrepareException(MeterVlPrepareFailureKind.generic);
    }
    yield* meterVl.prepareModel();
  }
}
