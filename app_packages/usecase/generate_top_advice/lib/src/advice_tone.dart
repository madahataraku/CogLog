/// ワンポイントアドバイスのトーン。表情差分の選択に使う。
enum AdviceTone {
  /// 元気な励まし。目開きの笑顔アセット。
  fun,

  /// 困惑や厳しさ。不機嫌顔アセット。
  confused,

  /// 称賛や満足。目閉じ笑顔アセット。
  happy,

  /// 気づきや呼びかけ。感嘆符アセット。
  realized;

  /// ワイヤ名からトーンを返す。[raw] が未知または空のときは [AdviceTone.fun]。
  ///
  /// Example:
  /// ```dart
  /// AdviceTone.parse('happy');
  /// ```
  static AdviceTone parse(String raw) {
    final key = raw.trim().toLowerCase();
    for (final tone in AdviceTone.values) {
      if (tone.name == key) {
        return tone;
      }
    }
    return AdviceTone.fun;
  }
}
