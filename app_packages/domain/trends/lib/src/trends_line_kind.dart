/// 推移グラフの線種。
///
/// バケット index が隣なら [solid]、間に空バケットがあれば [dashed]。
///
/// Example:
/// ```dart
/// TrendsLineKind.solid;
/// ```
enum TrendsLineKind {
  /// バケット列上で隣り合う 2 点を結ぶ実線。
  solid,

  /// 間に空バケットがある 2 点を結ぶ点線。
  dashed,
}
