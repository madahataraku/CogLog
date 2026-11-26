import 'package:meta/meta.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// 再ダウンロード確定後の診断更新が終わったことをセッションへ伝える。
///
/// Example:
/// ```dart
/// OnAcknowledgeRedownloadDiagnoseRefreshDelegate(
///   session: session,
/// ).execute();
/// ```
@internal
final class OnAcknowledgeRedownloadDiagnoseRefreshDelegate {
  /// 診断更新完了を伝える対象 session を束ねる。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeRedownloadDiagnoseRefreshDelegate(session: session);
  /// ```
  const OnAcknowledgeRedownloadDiagnoseRefreshDelegate({required this.session});

  /// 診断更新待ちフラグを持つプロセス内セッション。
  final MeterVlRedownloadSession session;

  /// 再診断完了を session に伝え、[MeterVlRedownloadSessionState.diagnoseRefreshPending] を落とす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() => session.acknowledgeDiagnoseRefresh();
}
