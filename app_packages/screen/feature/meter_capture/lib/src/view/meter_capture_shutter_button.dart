import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';

/// カメラアプリと同様の丸いシャッター。
///
/// Example:
/// ```dart
/// MeterCaptureShutterButton(onPress: () {});
/// ```
@internal
class MeterCaptureShutterButton extends StatelessWidget {
  /// [onPress] が null のとき無効表示にする。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureShutterButton(onPress: null);
  /// ```
  const MeterCaptureShutterButton({required this.onPress, super.key});

  /// タップ時の撮影。null なら押せない。
  final VoidCallback? onPress;

  /// 円形の外側リングと内側の塗りつぶしを描画する。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureShutterButton(onPress: null);
  /// ```
  @override
  Widget build(BuildContext context) {
    final enabled = onPress != null;
    final colors = context.theme.colors;
    final ring = enabled
        ? colors.foreground
        : colors.disable(colors.foreground);
    final fill = enabled
        ? colors.foreground
        : colors.disable(colors.foreground);

    return Semantics(
      button: true,
      enabled: enabled,
      label: strings.screen_feature_meter_capture_shutter,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPress,
          child: SizedBox(
            width: 72,
            height: 72,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
