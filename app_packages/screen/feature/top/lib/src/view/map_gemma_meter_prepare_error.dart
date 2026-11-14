import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:meta/meta.dart';

import '../strings.dart';

/// Gemma 準備失敗を誘導ダイアログ用の文字列へ写す。
///
/// NOTE.
/// `view_model_download_guidance` が `infra_gemma_meter` に依存しないよう、
/// 画面側で失敗種別を文言へ変換する。
/// 未知の例外は共通失敗文言へ落とす。
///
/// Example:
/// ```dart
/// mapGemmaMeterPrepareError(
///   const GemmaMeterPrepareException(
///     GemmaMeterPrepareFailureKind.wifiRequired,
///   ),
/// );
/// ```
@internal
String mapGemmaMeterPrepareError(Object error) {
  if (error is GemmaMeterPrepareException) {
    return switch (error.kind) {
      GemmaMeterPrepareFailureKind.wifiRequired =>
        strings.view_model_download_guidance_prepare_failed_wifi,
      GemmaMeterPrepareFailureKind.insufficientStorage =>
        strings.view_model_download_guidance_prepare_failed_storage,
      GemmaMeterPrepareFailureKind.network =>
        strings.view_model_download_guidance_prepare_failed_network,
      GemmaMeterPrepareFailureKind.generic =>
        strings.view_model_download_guidance_prepare_failed,
    };
  }
  return strings.view_model_download_guidance_prepare_failed;
}
