import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:meta/meta.dart';

import 'strings.dart';

/// 読み取り中モーダルの内容（不定スピナー・文言・中止）。
///
/// Example:
/// ```dart
/// MeterReadingProgressDialog(
///   style: style,
///   animation: animation,
///   onCancel: () {},
/// );
/// ```
@internal
final class MeterReadingProgressDialog extends StatelessWidget {
  /// スタイルと中止コールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// MeterReadingProgressDialog(
  ///   style: style,
  ///   animation: animation,
  ///   onCancel: () {},
  /// );
  /// ```
  const MeterReadingProgressDialog({
    required this.style,
    required this.animation,
    required this.onCancel,
    super.key,
  });

  /// 内容外周の余白（論理ピクセル）。
  static const double contentPadding = 16;

  /// ダイアログスタイル。
  final FDialogStyle style;

  /// 出現アニメーション。
  final Animation<double> animation;

  /// 中止ボタン押下。
  final VoidCallback onCancel;

  /// スピナー・文言・中止ボタンを描く。
  ///
  /// Example:
  /// ```dart
  /// dialog.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final readingLabel = strings.view_meter_reading_progress_reading;
    final cancelLabel = strings.view_meter_reading_progress_cancel;
    return FDialog(
      style: style,
      animation: animation,
      builder: (context, style) {
        return Padding(
          padding: const EdgeInsets.all(contentPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: contentPadding,
            children: [
              const Center(child: FCircularProgress()),
              Semantics(
                container: true,
                liveRegion: true,
                label: readingLabel,
                child: Text(readingLabel, textAlign: TextAlign.center),
              ),
              Semantics(
                button: true,
                label: cancelLabel,
                child: FButton(
                  variant: .secondary,
                  onPress: onCancel,
                  child: Text(cancelLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
