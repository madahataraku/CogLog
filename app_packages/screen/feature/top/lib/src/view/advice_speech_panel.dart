import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

/// 吹き出し（左）とアドバイザー画像（右）でワンポイントを示す。
///
/// [tone] の画像は `screen_feature_top` の `assets/advisor/` 配下で enum 名と同名の PNG を読む。
///
/// Example:
/// ```dart
/// AdviceSpeechPanel(
///   adviceText: '水分を取ろう',
///   tone: AdviceTone.fun,
///   semanticsLabel: 'アドバイザー',
/// );
/// ```
@internal
class AdviceSpeechPanel extends StatelessWidget {
  /// [adviceText] を吹き出しに、[tone] の表情を右に置く。
  ///
  /// Example:
  /// ```dart
  /// AdviceSpeechPanel(
  ///   adviceText: '水分を取ろう',
  ///   tone: AdviceTone.fun,
  ///   semanticsLabel: 'アドバイザー',
  /// );
  /// ```
  const AdviceSpeechPanel({
    required this.adviceText,
    required this.tone,
    required this.semanticsLabel,
    super.key,
  });

  /// 吹き出し内の本文。
  final String adviceText;

  /// 右側キャラクターの表情。
  ///
  /// 画像パスは `assets/advisor/${tone.name}.png` となる。
  final AdviceTone tone;

  /// キャラクター画像の代替テキスト。
  final String semanticsLabel;

  /// 左に吹き出し、右に高さ 96 のキャラクターを並べる。
  ///
  /// Example:
  /// ```dart
  /// const AdviceSpeechPanel(
  ///   adviceText: 'x',
  ///   tone: AdviceTone.fun,
  ///   semanticsLabel: 'アドバイザー',
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final bubbleColor = colors.secondary;
    final borderColor = colors.border;
    final textStyle = context.theme.typography.body.sm.copyWith(
      color: colors.secondaryForeground,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Expanded(
          child: _SpeechBubble(
            color: bubbleColor,
            borderColor: borderColor,
            child: Text(
              adviceText,
              style: textStyle,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Semantics(
          label: semanticsLabel,
          image: true,
          child: Image.asset(
            'assets/advisor/${tone.name}.png',
            package: 'screen_feature_top',
            height: 96,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

/// 右中央にしっぽが付く吹き出し。
///
/// Example:
/// ```dart
/// _SpeechBubble(
///   color: Colors.white,
///   borderColor: Colors.grey,
///   child: Text('x'),
/// );
/// ```
class _SpeechBubble extends StatelessWidget {
  /// [child] を角丸枠と右しっぽで包む。
  ///
  /// Example:
  /// ```dart
  /// _SpeechBubble(
  ///   color: Colors.white,
  ///   borderColor: Colors.grey,
  ///   child: Text('x'),
  /// );
  /// ```
  const _SpeechBubble({
    required this.color,
    required this.borderColor,
    required this.child,
  });

  /// 塗り。
  final Color color;

  /// 枠線。
  final Color borderColor;

  /// 本文。
  final Widget child;

  /// しっぽ付き外形の上に本文パディングを載せる。
  ///
  /// Example:
  /// ```dart
  /// _SpeechBubble(
  ///   color: Colors.white,
  ///   borderColor: Colors.grey,
  ///   child: Text('x'),
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(color: color, borderColor: borderColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 18, 10),
        child: child,
      ),
    );
  }
}

/// 角丸矩形と右向き三角形を描く。
class _SpeechBubblePainter extends CustomPainter {
  /// [color] と [borderColor] で吹き出し外形を塗る。
  ///
  /// Example:
  /// ```dart
  /// const _SpeechBubblePainter(
  ///   color: Colors.white,
  ///   borderColor: Colors.grey,
  /// );
  /// ```
  const _SpeechBubblePainter({required this.color, required this.borderColor});

  /// 塗り。
  final Color color;

  /// 枠線。
  final Color borderColor;

  /// 本体と右しっぽの Path を塗りと枠で描く。
  ///
  /// Example:
  /// ```dart
  /// painter.paint(canvas, const Size(100, 40));
  /// ```
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 12.0;
    const tail = 8.0;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width - tail, size.height),
      const Radius.circular(radius),
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(size.width - tail, size.height / 2 - 6)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - tail, size.height / 2 + 6)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  /// 色が変わったときだけ再描画する。
  ///
  /// Example:
  /// ```dart
  /// painter.shouldRepaint(oldPainter);
  /// ```
  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) =>
      color != oldDelegate.color || borderColor != oldDelegate.borderColor;
}
