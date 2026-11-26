import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:meta/meta.dart';

import 'top_home_loading_dialog.dart';

/// ホーム初回読み込み中ダイアログを開き、Ready で閉じる。
///
/// Example:
/// ```dart
/// await TopHomeLoadingLauncher.show(
///   context,
///   untilReady: Future<void>.value(),
///   onRetry: () async {},
/// );
/// ```
@internal
final class TopHomeLoadingLauncher {
  const TopHomeLoadingLauncher._();

  /// [barrierDismissible] は false。[useRootNavigator] は true。
  ///
  /// 戻るでは閉じない。[untilReady] 完了で自身の Route だけを外す。
  ///
  /// Example:
  /// ```dart
  /// await TopHomeLoadingLauncher.show(
  ///   context,
  ///   untilReady: Future<void>.value(),
  ///   onRetry: () async {},
  /// );
  /// ```
  static Future<void> show(
    BuildContext context, {
    required Future<void> untilReady,
    required Future<void> Function() onRetry,
  }) {
    return showFDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context, style, animation) {
        return _TopHomeLoadingRoute(
          style: style,
          animation: animation,
          untilReady: untilReady,
          onRetry: onRetry,
        );
      },
    );
  }
}

/// Ready 待ちと Pop 無効化を担う Route 本体。
final class _TopHomeLoadingRoute extends StatefulWidget {
  /// Dialog の見た目と閉じ方を受け取る。
  ///
  /// Example:
  /// ```dart
  /// _TopHomeLoadingRoute(
  ///   style: style,
  ///   animation: animation,
  ///   untilReady: Future<void>.value(),
  ///   onRetry: () async {},
  /// );
  /// ```
  const _TopHomeLoadingRoute({
    required this.style,
    required this.animation,
    required this.untilReady,
    required this.onRetry,
  });

  /// ダイアログスタイル。
  final FDialogStyle style;

  /// 出現アニメーション。
  final Animation<double> animation;

  /// Ready になるまで待つ。
  final Future<void> untilReady;

  /// 再試行。
  final Future<void> Function() onRetry;

  @override
  State<_TopHomeLoadingRoute> createState() => _TopHomeLoadingRouteState();
}

final class _TopHomeLoadingRouteState extends State<_TopHomeLoadingRoute> {
  var _finishing = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.untilReady.then((_) {
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
    final route = ModalRoute.of(context);
    if (route == null) {
      return;
    }
    Navigator.of(context).removeRoute(route);
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
      child: TopHomeLoadingDialog(
        style: widget.style,
        animation: widget.animation,
        onRetry: widget.onRetry,
      ),
    );
  }
}
