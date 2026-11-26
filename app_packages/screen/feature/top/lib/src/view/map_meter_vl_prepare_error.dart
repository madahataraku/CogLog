import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:meta/meta.dart';

import '../strings.dart';

/// メーター VL 準備失敗を誘導ダイアログ用の文字列へ写す。
///
/// NOTE.
/// `view_model_download_guidance` が `infra_meter_vl` に依存しないよう、
/// 画面側で失敗種別を文言へ変換する。
/// 未知の例外は共通失敗文言へ落とす。
///
/// Example:
/// ```dart
/// mapMeterVlPrepareError(
///   const MeterVlPrepareException(
///     MeterVlPrepareFailureKind.wifiRequired,
///   ),
/// );
/// ```
@internal
String mapMeterVlPrepareError(Object error) {
  if (error is MeterVlPrepareException) {
    return switch (error.kind) {
      MeterVlPrepareFailureKind.wifiRequired =>
        strings.view_model_download_guidance_prepare_failed_wifi,
      MeterVlPrepareFailureKind.insufficientStorage =>
        strings.view_model_download_guidance_prepare_failed_storage,
      MeterVlPrepareFailureKind.network =>
        strings.view_model_download_guidance_prepare_failed_network,
      MeterVlPrepareFailureKind.generic =>
        strings.view_model_download_guidance_prepare_failed,
    };
  }
  return strings.view_model_download_guidance_prepare_failed;
}
