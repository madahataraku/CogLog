import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/state/meter_capture_step.dart';
import 'meter_capture_screen_providers.dart';
import 'meter_capture_step1_view.dart';
import 'meter_capture_step2_view.dart';

/// メーター記録の本文。ステップに応じて子を切り替える。
///
/// Example:
/// ```dart
/// const MeterCaptureScreenBody();
/// ```
@internal
class MeterCaptureScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreenBody();
  /// ```
  const MeterCaptureScreenBody({
    this.debugCameraPlaceholder = false,
    super.key,
  });

  /// Golden 用にカメラプレビューを色枠へ差し替える。
  final bool debugCameraPlaceholder;

  /// State と Entity を見て Step1 / Step2 を出す。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(MeterCaptureScreenProviders.state);
    final entity = ref.watch(MeterCaptureScreenProviders.entity);

    return FScaffold(
      header: FHeader(title: Text(strings.screen_feature_meter_capture_title)),
      child: switch (state.step) {
        MeterCaptureStep.photo => MeterCaptureStep1View(
          state: state,
          debugPlaceholder: debugCameraPlaceholder,
        ),
        MeterCaptureStep.edit => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MeterCaptureStep2View(state: state, entity: entity),
        ),
      },
    );
  }
}
