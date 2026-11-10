import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';

import '../viewmodel/meter_capture_screen_view_model.dart';
import '../viewmodel/state/meter_capture_step.dart';
import 'meter_capture_screen_body.dart';
import 'meter_capture_screen_providers.dart';

/// メーターパネル写真から運動履歴を作成する画面。
///
/// Example:
/// ```dart
/// const MeterCaptureScreen();
/// ```
class MeterCaptureScreen extends HookConsumerWidget {
  /// メーター記録画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  const MeterCaptureScreen({super.key});

  /// タブ選択とライフサイクルに合わせてカメラを開始／停止する。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(MeterCaptureScreenViewModel.provider);
    final step = ref.watch(
      MeterCaptureScreenProviders.state.select((state) => state.step),
    );
    final selected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 1;
    final lifecycle = useAppLifecycleState();

    useEffect(() {
      if (!selected) {
        unawaited(viewModel.onLeaveMeterTab());
        return null;
      }
      final paused =
          lifecycle != null && lifecycle != AppLifecycleState.resumed;
      if (paused) {
        unawaited(viewModel.onAppPaused());
        return null;
      }
      if (step == MeterCaptureStep.photo) {
        unawaited(viewModel.onEnterCamera());
      } else {
        unawaited(viewModel.onAppPaused());
      }
      return null;
    }, [viewModel, selected, lifecycle, step]);

    return const MeterCaptureScreenBody();
  }
}
