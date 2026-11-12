/// メーター読み取り結果の画面メッセージ区分。
///
/// 誘導の有無とは独立に決める。
///
/// Example:
/// ```dart
/// MeterReadingMessageKind.complete;
/// ```
enum MeterReadingMessageKind {
  /// コアが揃い、成功と注意を出す。
  complete,

  /// コアの一部だけあり、注意と手打ち案内を出す。
  incomplete,

  /// コアが皆無で、手打ち案内のみ出す。
  empty,
}
