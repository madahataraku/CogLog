import 'package:foundation_resources/gen/strings.dart' as foundation_resources;
import 'package:meta/meta.dart';

import '../gen/strings.dart';

/// この view と共通リソースの文言。
final class _Strings
    with L10nStringsMixin, foundation_resources.L10nStringsMixin {
  /// 生成 mixin を束ねる。
  const _Strings();
}

/// 画面から参照する文言。
///
/// Example:
/// ```dart
/// strings.view_model_download_guidance_title;
/// ```
@internal
final strings = _Strings();
