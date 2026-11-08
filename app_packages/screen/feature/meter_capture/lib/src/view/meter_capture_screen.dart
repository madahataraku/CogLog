import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../strings.dart';

/// メーター記録の画面。中身は別計画で足す。
///
/// Example:
/// ```dart
/// const MeterCaptureScreen();
/// ```
class MeterCaptureScreen extends StatelessWidget {
  /// メーター記録画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  const MeterCaptureScreen({super.key});

  /// タイトルだけの空画面を出す。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  @override
  Widget build(BuildContext context) => FScaffold(
    header: FHeader(title: Text(strings.screen_feature_meter_capture_title)),
    child: const SizedBox.shrink(),
  );
}
