/// チュートリアルのメイン完了と各文脈の表示済み、メイン到達段階。
///
/// Example:
/// ```dart
/// TutorialProgress.initial;
/// ```
final class TutorialProgress {
  /// メイン完了・到達段階・文脈ごとの表示済みをまとめる。
  ///
  /// Example:
  /// ```dart
  /// const TutorialProgress(
  ///   mainCompleted: false,
  ///   mainReachedStep: 0,
  ///   goalSettingsContextSeen: false,
  ///   cameraContextSeen: false,
  ///   meterEditContextSeen: false,
  ///   trendsContextSeen: false,
  ///   historyContextSeen: false,
  ///   achievementContextSeen: false,
  /// );
  /// ```
  const TutorialProgress({
    required this.mainCompleted,
    required this.mainReachedStep,
    required this.goalSettingsContextSeen,
    required this.cameraContextSeen,
    required this.meterEditContextSeen,
    required this.trendsContextSeen,
    required this.historyContextSeen,
    required this.achievementContextSeen,
  });

  /// キー無し・未保存相当。すべて未完了／未表示。
  static const initial = TutorialProgress(
    mainCompleted: false,
    mainReachedStep: 0,
    goalSettingsContextSeen: false,
    cameraContextSeen: false,
    meterEditContextSeen: false,
    trendsContextSeen: false,
    historyContextSeen: false,
    achievementContextSeen: false,
  );

  /// メイン導線が完了またはスキップ済みか。
  final bool mainCompleted;

  /// メイン導線の到達段階（0〜7）。ホームでの段階4〜7再開に使う。
  final int mainReachedStep;

  /// 目標設定文脈を表示済みか。
  final bool goalSettingsContextSeen;

  /// 撮影画面文脈を表示済みか。
  final bool cameraContextSeen;

  /// 撮影結果画面文脈を表示済みか。
  final bool meterEditContextSeen;

  /// 推移文脈を表示済みか。
  final bool trendsContextSeen;

  /// 運動履歴文脈を表示済みか。
  final bool historyContextSeen;

  /// 旧アチーブメント文脈の表示済み（互換用。案内はメイン段階7へ移した）。
  final bool achievementContextSeen;

  /// すべて未表示の [initial] を返す。
  ///
  /// Example:
  /// ```dart
  /// TutorialProgress.initial
  ///     .copyWith(mainCompleted: true)
  ///     .reset();
  /// ```
  TutorialProgress reset() => initial;

  /// 指定フィールドだけ差し替える。
  ///
  /// null の引数は現状の値を残す。
  ///
  /// Example:
  /// ```dart
  /// TutorialProgress.initial.copyWith(mainCompleted: true);
  /// ```
  TutorialProgress copyWith({
    bool? mainCompleted,
    int? mainReachedStep,
    bool? goalSettingsContextSeen,
    bool? cameraContextSeen,
    bool? meterEditContextSeen,
    bool? trendsContextSeen,
    bool? historyContextSeen,
    bool? achievementContextSeen,
  }) => TutorialProgress(
    mainCompleted: mainCompleted ?? this.mainCompleted,
    mainReachedStep: mainReachedStep ?? this.mainReachedStep,
    goalSettingsContextSeen:
        goalSettingsContextSeen ?? this.goalSettingsContextSeen,
    cameraContextSeen: cameraContextSeen ?? this.cameraContextSeen,
    meterEditContextSeen: meterEditContextSeen ?? this.meterEditContextSeen,
    trendsContextSeen: trendsContextSeen ?? this.trendsContextSeen,
    historyContextSeen: historyContextSeen ?? this.historyContextSeen,
    achievementContextSeen:
        achievementContextSeen ?? this.achievementContextSeen,
  );

  /// 永続フィールドがすべて同じなら等しい。
  ///
  /// Example:
  /// ```dart
  /// TutorialProgress.initial == TutorialProgress.initial;
  /// ```
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialProgress &&
          mainCompleted == other.mainCompleted &&
          mainReachedStep == other.mainReachedStep &&
          goalSettingsContextSeen == other.goalSettingsContextSeen &&
          cameraContextSeen == other.cameraContextSeen &&
          meterEditContextSeen == other.meterEditContextSeen &&
          trendsContextSeen == other.trendsContextSeen &&
          historyContextSeen == other.historyContextSeen &&
          achievementContextSeen == other.achievementContextSeen;

  /// 永続フィールドに基づくハッシュ。
  ///
  /// Example:
  /// ```dart
  /// TutorialProgress.initial.hashCode;
  /// ```
  @override
  int get hashCode => Object.hash(
    mainCompleted,
    mainReachedStep,
    goalSettingsContextSeen,
    cameraContextSeen,
    meterEditContextSeen,
    trendsContextSeen,
    historyContextSeen,
    achievementContextSeen,
  );
}
