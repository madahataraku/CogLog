import 'package:foundation_resources/gen/strings.dart' as foundation_resources;
import 'package:meta/meta.dart';
import 'package:view_model_download_guidance/gen/strings.dart'
    as view_model_download_guidance;

import '../gen/strings.dart';

/// この画面と共通リソース・誘導文言。
final class _Strings
    with
        L10nStringsMixin,
        foundation_resources.L10nStringsMixin,
        view_model_download_guidance.L10nStringsMixin {
  /// 生成 mixin を束ねる。
  const _Strings();
}

/// 画面から参照する文言。
///
/// Example:
/// ```dart
/// strings.screen_feature_top_today;
/// ```
@internal
final strings = _Strings();
