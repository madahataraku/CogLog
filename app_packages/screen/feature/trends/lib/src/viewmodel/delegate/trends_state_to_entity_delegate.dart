import '../entity/trends_screen_entity.dart';
import '../state/trends_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const TrendsStateToEntityDelegate().execute(TrendsScreenState.initial);
/// ```
final class TrendsStateToEntityDelegate {
  /// 変換だけを行う。
  ///
  /// Example:
  /// ```dart
  /// const TrendsStateToEntityDelegate();
  /// ```
  const TrendsStateToEntityDelegate();

  /// [state] の期間とグループを Entity にする。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsScreenState.initial);
  /// ```
  TrendsScreenEntity execute(TrendsScreenState state) {
    return TrendsScreenEntity(period: state.period, group: state.group);
  }
}
