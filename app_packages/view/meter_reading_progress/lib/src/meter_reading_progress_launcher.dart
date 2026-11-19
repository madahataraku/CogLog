import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'meter_reading_progress_dialog.dart';

/// 読み取り中モーダルを開き、完了または中止で DialogRoute を閉じる。
///
/// Example:
/// ```dart
/// await MeterReadingProgressLauncher.show(
///   context,
///   onCancel: () async {},
///   untilDismiss: Future<void>.value(),
/// );
/// ```
final class MeterReadingProgressLauncher {
  const MeterReadingProgressLauncher._();

  /// [barrierDismissible] は false。pop はこの Launcher 内だけが行う。
  ///
  /// [untilDismiss] が完了するか [onCancel] が成功すると Route を閉じる。
  ///
  /// Example:
  /// ```dart
  /// await MeterReadingProgressLauncher.show(
  ///   context,
  ///   onCancel: () async {},
  ///   untilDismiss: Future<void>.value(),
  /// );
  /// ```
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onCancel,
    required Future<void> untilDismiss,
  }) {
    return showFDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context, style, animation) {
        return _MeterReadingProgressRoute(
          style: style,
          animation: animation,
          onCancel: onCancel,
          untilDismiss: untilDismiss,
        );
      },
    );
  }
}

/// 中止と [untilDismiss] の競合を一度だけ閉じて解決する Route 本体。
final class _MeterReadingProgressRoute extends StatefulWidget {
  /// Dialog の見た目と閉じ方を受け取る。
  ///
  /// Example:
  /// ```dart
  /// _MeterReadingProgressRoute(
  ///   style: style,
  ///   animation: animation,
  ///   onCancel: () async {},
  ///   untilDismiss: Future<void>.value(),
  /// );
  /// ```
  const _MeterReadingProgressRoute({
    required this.style,
    required this.animation,
    required this.onCancel,
    required this.untilDismiss,
  });

  /// ダイアログスタイル。
  final FDialogStyle style;

  /// 出現アニメーション。
  final Animation<double> animation;

  /// 中止（実キャンセルなしの状態打ち切り）。
  final Future<void> Function() onCancel;

  /// 読み取り終了を待つ。
  final Future<void> untilDismiss;

  @override
  State<_MeterReadingProgressRoute> createState() =>
      _MeterReadingProgressRouteState();
}

final class _MeterReadingProgressRouteState
    extends State<_MeterReadingProgressRoute> {
  var _finishing = false;
  var _canceling = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.untilDismiss.then((_) {
        _finish();
      }),
    );
  }

  /// DialogRoute を一度だけ完了する。
  ///
  /// Example:
  /// ```dart
  /// _finish();
  /// ```
  void _finish() {
    if (_finishing || !mounted) {
      return;
    }
    _finishing = true;
    Navigator.of(context).pop();
  }

  /// 中止コールバックのあと Route を閉じる。
  ///
  /// Example:
  /// ```dart
  /// await _runCancel();
  /// ```
  Future<void> _runCancel() async {
    if (_finishing || _canceling) {
      return;
    }
    _canceling = true;
    try {
      await widget.onCancel();
    } finally {
      _finish();
    }
  }

  /// PopScope 付き Dialog を描く。
  ///
  /// Example:
  /// ```dart
  /// build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_runCancel());
        }
      },
      child: MeterReadingProgressDialog(
        style: widget.style,
        animation: widget.animation,
        onCancel: () {
          unawaited(_runCancel());
        },
      ),
    );
  }
}
