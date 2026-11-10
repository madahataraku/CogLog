import 'package:meta/meta.dart';

import '../gen/strings.dart';

/// この画面の文言。
final class _Strings with L10nStringsMixin {
  /// 生成 mixin を束ねる。
  const _Strings();
}

/// 画面から参照する文言。
///
/// Example:
/// ```dart
/// strings.screen_feature_debug_title;
/// ```
@internal
final strings = _Strings();
