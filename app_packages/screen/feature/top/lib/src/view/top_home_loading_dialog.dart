import 'dart:async';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:view_loading_spinner/view_loading_spinner.dart';

import '../strings.dart';
import 'top_screen_providers.dart';

/// ホーム初回読み込み中／失敗時のダイアログ内容。
///
/// Example:
/// ```dart
/// TopHomeLoadingDialog(
///   style: style,
///   animation: animation,
///   onRetry: () async {},
/// );
/// ```
@internal
final class TopHomeLoadingDialog extends ConsumerWidget {
  /// スタイルと再試行コールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// TopHomeLoadingDialog(
  ///   style: style,
  ///   animation: animation,
  ///   onRetry: () async {},
  /// );
  /// ```
  const TopHomeLoadingDialog({
    required this.style,
    required this.animation,
    required this.onRetry,
    super.key,
  });

  /// 内容外周の余白（論理ピクセル）。
  static const double contentPadding = 16;

  /// ダイアログスタイル。
  final FDialogStyle style;

  /// 出現アニメーション。
  final Animation<double> animation;

  /// 再試行ボタン押下。
  final Future<void> Function() onRetry;

  /// 読込中または失敗 UI を描く。
  ///
  /// Example:
  /// ```dart
  /// dialog.build(context, ref);
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(TopScreenProviders.entity);
    return FDialog(
      style: style,
      animation: animation,
      builder: (context, style) {
        return TopHomeLoadingDialogBody(
          loadFailed: entity.loadFailed,
          onRetry: onRetry,
        );
      },
    );
  }
}

/// 読込中／失敗の中身（Golden からも直接載せる）。
///
/// Example:
/// ```dart
/// TopHomeLoadingDialogBody(loadFailed: false, onRetry: () async {});
/// ```
@internal
final class TopHomeLoadingDialogBody extends StatelessWidget {
  /// 失敗フラグと再試行を受け取る。
  ///
  /// Example:
  /// ```dart
  /// TopHomeLoadingDialogBody(loadFailed: true, onRetry: () async {});
  /// ```
  const TopHomeLoadingDialogBody({
    required this.loadFailed,
    required this.onRetry,
    super.key,
  });

  /// 失敗表示のとき true。
  final bool loadFailed;

  /// 再試行。
  final Future<void> Function() onRetry;

  /// スピナーまたはエラー＋再試行を描く。
  ///
  /// Example:
  /// ```dart
  /// body.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final loadingLabel = strings.screen_feature_top_loading;
    final failedLabel = strings.screen_feature_top_load_failed;
    final retryLabel = strings.screen_feature_top_retry;
    return Padding(
      padding: const EdgeInsets.all(TopHomeLoadingDialog.contentPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TopHomeLoadingDialog.contentPadding,
        children: [
          if (!loadFailed) ...[
            const Center(child: AppLoadingSpinner()),
            Semantics(
              container: true,
              liveRegion: true,
              label: loadingLabel,
              child: Text(loadingLabel, textAlign: TextAlign.center),
            ),
          ] else ...[
            Semantics(
              container: true,
              liveRegion: true,
              label: failedLabel,
              child: Text(failedLabel, textAlign: TextAlign.center),
            ),
            FButton(
              variant: .primary,
              onPress: () {
                unawaited(onRetry());
              },
              child: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }
}
