import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // テスト対象:
  // CoachMarkRegistry.register / unregister
  //
  // テスト内容:
  // 同一 id を別キーで上書きしたあと、旧キーの unregister では残る。
  test('register / unregister', () {
    final registry = CoachMarkRegistry();
    final key = GlobalKey();
    registry.register(CoachMarkTargetId.navHome, key);

    final other = GlobalKey();
    registry.register(CoachMarkTargetId.navHome, other);
    // 別キーで上書き済みなので旧 key の unregister では残る。
    registry.unregister(CoachMarkTargetId.navHome, key);
    registry.unregister(CoachMarkTargetId.navHome, other);
  });

  // テスト対象:
  // CoachMarkRegistry.rectFor
  //
  // テスト内容:
  // 未マウントの GlobalKey では null を返す。
  testWidgets('rectFor は未マウント時 null', (tester) async {
    final registry = CoachMarkRegistry();
    final key = GlobalKey();
    registry.register(CoachMarkTargetId.navHome, key);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(
      registry.rectFor(
        CoachMarkTargetId.navHome,
        tester.element(find.byType(SizedBox)),
      ),
      isNull,
      reason: '未マウント時は null であること',
    );
  });

  // テスト対象:
  // CoachMarkRegistry.rectFor
  //
  // テスト内容:
  // Overlay を画面原点からずらしても、返す矩形は Overlay 基準（オフセットを除く）。
  testWidgets('rectFor は Overlay オフセットを除いた矩形を返す', (tester) async {
    final registry = CoachMarkRegistry();
    final key = GlobalKey();
    registry.register(CoachMarkTargetId.navHome, key);
    const overlayOffset = Offset(30, 50);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned(
              left: overlayOffset.dx,
              top: overlayOffset.dy,
              width: 200,
              height: 120,
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(key: key, width: 40, height: 24),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.renderObject<RenderBox>(find.byKey(key));
    final globalTopLeft = box.localToGlobal(Offset.zero);
    expect(globalTopLeft, overlayOffset, reason: 'グローバル座標は Overlay オフセットを含むこと');

    final rect = registry.rectFor(
      CoachMarkTargetId.navHome,
      tester.element(find.byKey(key)),
    );
    expect(rect, isNotNull);
    expect(rect!.size, const Size(40, 24));
    expect(
      rect.topLeft,
      Offset.zero,
      reason: 'root Overlay 基準ではオフセットを除いた原点であること',
    );
  });
}
