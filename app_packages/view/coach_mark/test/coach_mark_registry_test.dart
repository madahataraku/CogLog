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
}
