/// 通知タイトルと本文の固定文言。
///
/// 起動直後は L10n が未準備のため定数を使う。
///
/// Example:
/// ```dart
/// ExerciseReminderCopy.titleFor('ja');
/// ```
final class ExerciseReminderCopy {
  /// インスタンス化しない。
  const ExerciseReminderCopy._();

  /// 日本語タイトル。
  static const titleJa = 'そろそろ運動を始めましょう！';

  /// 日本語本文。
  static const bodyJa = '運動を行なったらぜひCogLogに記録してくださいね！';

  /// 英語タイトル（仮訳）。
  static const titleEn = "It's almost time to exercise!";

  /// 英語本文（仮訳）。
  static const bodyEn = 'When you finish exercising, please log it in CogLog!';

  /// [languageCode] に応じたタイトル。
  ///
  /// Example:
  /// ```dart
  /// ExerciseReminderCopy.titleFor('en');
  /// ```
  static String titleFor(String languageCode) =>
      languageCode == 'en' ? titleEn : titleJa;

  /// [languageCode] に応じた本文。
  ///
  /// Example:
  /// ```dart
  /// ExerciseReminderCopy.bodyFor('en');
  /// ```
  static String bodyFor(String languageCode) =>
      languageCode == 'en' ? bodyEn : bodyJa;
}
