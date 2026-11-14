import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'model_download_guidance_dialog.dart';
import 'strings.dart';

/// モデル未ダウンロード誘導ダイアログを開く。(A)/(B) で共用する。
///
/// Example:
/// ```dart
/// await ModelDownloadGuidanceLauncher.show(
///   context,
///   onPrepare: () async {},
/// );
/// ```
final class ModelDownloadGuidanceLauncher {
  const ModelDownloadGuidanceLauncher._();

  /// [barrierDismissible] は false。表示前に呼び側で session.markPresented 済みであること。
  ///
  /// [onPrepare] と [onPrepareProgress] のどちらか一方を渡す。(A) は従来どおり
  /// [onPrepare] のみでよい。(B) は進捗付きの [onPrepareProgress] と
  /// [disableDismissWhilePreparing] true を渡す。
  ///
  /// Example:
  /// ```dart
  /// // (A)
  /// await ModelDownloadGuidanceLauncher.show(
  ///   context,
  ///   onPrepare: () async {},
  /// );
  ///
  /// // (B)
  /// await ModelDownloadGuidanceLauncher.show(
  ///   context,
  ///   title: 'Gemma',
  ///   body: 'body',
  ///   disableDismissWhilePreparing: true,
  ///   onPrepareProgress: () async* {
  ///     yield 0.5;
  ///   },
  ///   mapPrepareError: (error) => 'failed',
  /// );
  /// ```
  static Future<void> show(
    BuildContext context, {

    /// 完了のみ返す準備（(A)）。[onPrepareProgress] と排他。
    Future<void> Function()? onPrepare,

    /// 0.0〜1.0 の進捗を流す準備（(B)）。[onPrepare] と排他。
    Stream<double> Function()? onPrepareProgress,

    /// 未指定時は (A) 用 CSV タイトル。
    String? title,

    /// 未指定時は (A) 用 CSV 本文。
    String? body,

    /// 準備失敗を利用者向け文言へ写す。未指定時は共通失敗文言。
    String Function(Object error)? mapPrepareError,

    /// 準備中に「閉じる」を無効化する。(B) のみ true。
    bool disableDismissWhilePreparing = false,
  }) {
    assert(
      (onPrepare != null) ^ (onPrepareProgress != null),
      'Pass exactly one of onPrepare or onPrepareProgress.',
    );
    final Stream<double> Function() prepareStream =
        onPrepareProgress ??
        () async* {
          await onPrepare!();
        };
    return showFDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context, style, animation) {
        return ModelDownloadGuidanceDialog(
          style: style,
          animation: animation,
          title: title ?? strings.view_model_download_guidance_title,
          body: body ?? strings.view_model_download_guidance_body,
          dismissLabel: strings.view_model_download_guidance_dismiss,
          prepareLabel: strings.view_model_download_guidance_prepare,
          prepareFailedLabel:
              strings.view_model_download_guidance_prepare_failed,
          mapPrepareError: mapPrepareError,
          disableDismissWhilePreparing: disableDismissWhilePreparing,
          onDismiss: () => _completeDialogRoute(context),
          onPrepare: prepareStream,
        );
      },
    );
  }

  /// showFDialog が積んだ DialogRoute を完了する（画面 pop ではない）。
  ///
  /// Example:
  /// ```dart
  /// _completeDialogRoute(context);
  /// ```
  static void _completeDialogRoute(BuildContext context) {
    Navigator.of(context).pop();
  }
}
