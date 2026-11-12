import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// 確認ダイアログを開き、確定なら true・キャンセルなら false を返す。
///
/// [barrierDismissible] は常に false。文言は呼び出し側が渡す。
/// [title]・[body]・[confirmLabel]・[cancelLabel] は表示文言。
///
/// Example:
/// ```dart
/// final ok = await showConfirmDialog(
///   context,
///   title: '削除しますか？',
///   body: 'この操作は取り消せません。',
///   confirmLabel: '削除',
///   cancelLabel: 'キャンセル',
/// );
/// ```
Future<bool> showConfirmDialog(
  BuildContext context, {

  /// ダイアログ見出し。
  required String title,

  /// 確認内容の本文。
  required String body,

  /// 確定ボタンの文言。
  required String confirmLabel,

  /// キャンセルボタンの文言。
  required String cancelLabel,
}) async {
  final result = await showFDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context, style, animation) {
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
              FButton(
                variant: .secondary,
                onPress: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
              FButton(
                onPress: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      );
    },
  );
  return result ?? false;
}
