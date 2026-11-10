import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'model_download_guidance_dialog.dart';
import 'strings.dart';

/// モデル未ダウンロード誘導ダイアログを開く。
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
  /// Example:
  /// ```dart
  /// await ModelDownloadGuidanceLauncher.show(
  ///   context,
  ///   onPrepare: () async {},
  /// );
  /// ```
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onPrepare,
  }) {
    return showFDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context, style, animation) {
        return ModelDownloadGuidanceDialog(
          style: style,
          animation: animation,
          title: strings.view_model_download_guidance_title,
          body: strings.view_model_download_guidance_body,
          dismissLabel: strings.view_model_download_guidance_dismiss,
          prepareLabel: strings.view_model_download_guidance_prepare,
          prepareFailedLabel:
              strings.view_model_download_guidance_prepare_failed,
          onDismiss: () => _completeDialogRoute(context),
          onPrepare: onPrepare,
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
