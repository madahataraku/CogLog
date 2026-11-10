import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:meta/meta.dart';

/// モデル未ダウンロード誘導の内容。
///
/// Example:
/// ```dart
/// ModelDownloadGuidanceDialog(
///   style: style,
///   animation: animation,
///   title: 't',
///   body: 'b',
///   dismissLabel: '閉じる',
///   prepareLabel: '準備',
///   prepareFailedLabel: '失敗',
///   onDismiss: () {},
///   onPrepare: () async {},
/// );
/// ```
@internal
final class ModelDownloadGuidanceDialog extends HookWidget {
  /// 文言と閉じる／準備コールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// ModelDownloadGuidanceDialog(
  ///   style: style,
  ///   animation: animation,
  ///   title: 't',
  ///   body: 'b',
  ///   dismissLabel: '閉じる',
  ///   prepareLabel: '準備',
  ///   prepareFailedLabel: '失敗',
  ///   onDismiss: () {},
  ///   onPrepare: () async {},
  /// );
  /// ```
  const ModelDownloadGuidanceDialog({
    required this.style,
    required this.animation,
    required this.title,
    required this.body,
    required this.dismissLabel,
    required this.prepareLabel,
    required this.prepareFailedLabel,
    required this.onDismiss,
    required this.onPrepare,
    super.key,
  });

  /// ダイアログスタイル。
  final FDialogStyle style;

  /// 出現アニメーション。
  final Animation<double> animation;

  /// タイトル文言。
  final String title;

  /// 本文文言。
  final String body;

  /// 閉じるボタン文言。
  final String dismissLabel;

  /// 準備ボタン文言。
  final String prepareLabel;

  /// 準備失敗時の文言。
  final String prepareFailedLabel;

  /// 閉じる（Launcher が DialogRoute を完了する）。
  final VoidCallback onDismiss;

  /// モデル準備。成功時は呼び出し側（Launcher）が Route を完了する。
  final Future<void> Function() onPrepare;

  /// 縦並びのタイトル・本文・エラー・ボタンを描く。
  ///
  /// Example:
  /// ```dart
  /// dialog.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final preparing = useState(false);
    final errorText = useState<String?>(null);

    Future<void> onPreparePressed() async {
      preparing.value = true;
      errorText.value = null;
      try {
        await onPrepare();
        onDismiss();
      } on Object {
        // 準備失敗はダイアログを閉じず、利用者へ再試行を促す。
        preparing.value = false;
        errorText.value = prepareFailedLabel;
      }
    }

    return FDialog(
      style: style,
      animation: animation,
      builder: (context, style) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title),
            Text(body),
            if (errorText.value != null) Text(errorText.value!),
            FButton(
              onPress: preparing.value ? null : onDismiss,
              child: Text(dismissLabel),
            ),
            FButton(
              onPress: preparing.value ? null : onPreparePressed,
              child: Text(prepareLabel),
            ),
          ],
        );
      },
    );
  }
}
