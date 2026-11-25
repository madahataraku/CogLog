import 'package:meta/meta.dart';
import 'package:view_coach_mark/gen/strings.dart' as view_coach_mark;

import '../gen/strings.dart';

/// この画面とコーチマーク共通文言。
final class _Strings with L10nStringsMixin, view_coach_mark.L10nStringsMixin {
  /// 生成 mixin を束ねる。
  const _Strings();
}

/// 画面から参照する文言。
///
/// Example:
/// ```dart
/// strings.screen_feature_trends_title;
/// ```
@internal
final strings = _Strings();
