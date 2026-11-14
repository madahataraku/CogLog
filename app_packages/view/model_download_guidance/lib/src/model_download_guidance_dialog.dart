import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:meta/meta.dart';

/// モデル未ダウンロード誘導の内容。(A)/(B) で進捗・閉じる可否が異なる。
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
///   onPrepare: () async* {
///     yield 1.0;
///   },
/// );
/// ```
@internal
final class ModelDownloadGuidanceDialog extends HookWidget {
  /// 文言と閉じる／準備コールバックを受け取る。
  ///
  /// [disableDismissWhilePreparing] は (B) のみ true にする。
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
  ///   onPrepare: () async* {
  ///     yield 0.5;
  ///   },
  ///   mapPrepareError: (error) => 'failed',
  ///   disableDismissWhilePreparing: true,
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
    this.mapPrepareError,
    this.disableDismissWhilePreparing = false,
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

  /// 準備失敗時の共通文言。
  final String prepareFailedLabel;

  /// 閉じる（Launcher が DialogRoute を完了する）。
  final VoidCallback onDismiss;

  /// モデル準備の進捗（0.0〜1.0）。成功時は呼び出し側（Launcher）が Route を完了する。
  final Stream<double> Function() onPrepare;

  /// 準備失敗を利用者向け文言へ写す。未指定時は [prepareFailedLabel]。
  final String Function(Object error)? mapPrepareError;

  /// 準備中に「閉じる」を無効化するとき true（(B) のみ）。
  final bool disableDismissWhilePreparing;

  /// 縦並びのタイトル・本文・進捗・エラー・ボタンを描く。
  ///
  /// Example:
  /// ```dart
  /// dialog.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final preparing = useState(false);
    final progress = useState<double?>(null);
    final errorText = useState<String?>(null);

    Future<void> onPreparePressed() async {
      preparing.value = true;
      progress.value = null;
      errorText.value = null;
      try {
        await for (final value in onPrepare()) {
          if (!context.mounted) {
            return;
          }
          progress.value = value;
        }
        if (!context.mounted) {
          return;
        }
        onDismiss();
      } on Object catch (error) {
        // 準備失敗はダイアログを閉じず、利用者へ再試行を促す。
        if (!context.mounted) {
          return;
        }
        preparing.value = false;
        progress.value = null;
        errorText.value = mapPrepareError?.call(error) ?? prepareFailedLabel;
      }
    }

    // (A) は準備中も閉じられる。(B) は disableDismissWhilePreparing で塞ぐ。
    final dismissEnabled = !preparing.value || !disableDismissWhilePreparing;
    final progressValue = progress.value;
    // 進捗は 0〜100% の整数表記。未開始・失敗直後は出さない。
    final progressPercent = progressValue == null
        ? null
        : '${(progressValue.clamp(0.0, 1.0) * 100).round()}%';

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
            if (progressPercent != null) Text(progressPercent),
            if (errorText.value != null) Text(errorText.value!),
            // 副ボタン。準備中の有効／無効は dismissEnabled に従う。
            FButton(
              variant: .secondary,
              onPress: dismissEnabled ? onDismiss : null,
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
