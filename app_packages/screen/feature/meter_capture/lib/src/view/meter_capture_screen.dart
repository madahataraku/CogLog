import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'meter_capture_screen_body.dart';

/// メーターパネル写真から運動履歴を作成する画面。
///
/// Example:
/// ```dart
/// const MeterCaptureScreen();
/// ```
class MeterCaptureScreen extends ConsumerWidget {
  /// メーター記録画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  const MeterCaptureScreen({super.key});

  /// 見た目は [MeterCaptureScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const MeterCaptureScreenBody();
}
