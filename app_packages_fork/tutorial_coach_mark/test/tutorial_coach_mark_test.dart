import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() {
  test('TargetFocus.enableTargetPassThrough の既定は false', () {
    final focus = TargetFocus(identify: 'x', keyTarget: GlobalKey());
    expect(focus.enableTargetPassThrough, isFalse);
  });

  test('TargetFocus.enableTargetPassThrough を true にできる', () {
    final focus = TargetFocus(
      identify: 'x',
      keyTarget: GlobalKey(),
      enableTargetPassThrough: true,
    );
    expect(focus.enableTargetPassThrough, isTrue);
  });

  test('NotFoundTargetException は identify をメッセージに含む', () {
    final error = NotFoundTargetException('homeFab');
    expect(error.message, contains('homeFab'));
  });
}
