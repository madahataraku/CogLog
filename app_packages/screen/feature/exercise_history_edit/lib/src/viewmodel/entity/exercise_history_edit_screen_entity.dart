/// 運動履歴編集の表示用状態。
///
/// Example:
/// ```dart
/// const ExerciseHistoryEditScreenEntity(
///   showLoading: false,
///   showMissing: false,
///   showLoadError: false,
///   canRetry: false,
///   loadErrorText: null,
///   distanceText: '',
///   hoursText: '',
///   minutesText: '',
///   secondsText: '',
///   averageSpeedText: '',
///   caloriesText: '',
///   recordedAtText: '',
///   showHandEntryGuidance: false,
///   isDirty: false,
///   busy: false,
///   canSave: false,
///   saveErrorText: null,
///   permissionDeniedText: null,
///   showOpenSettings: false,
///   photoPath: null,
///   showPhotoBytes: false,
///   showPhotoPath: false,
///   showPhotoError: false,
/// );
/// ```
final class ExerciseHistoryEditScreenEntity {
  /// 入力欄の文字列と表示フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryEditScreenEntity(
  ///   showLoading: true,
  ///   showMissing: false,
  ///   showLoadError: false,
  ///   canRetry: false,
  ///   loadErrorText: null,
  ///   distanceText: '',
  ///   hoursText: '',
  ///   minutesText: '',
  ///   secondsText: '',
  ///   averageSpeedText: '',
  ///   caloriesText: '',
  ///   recordedAtText: '',
  ///   showHandEntryGuidance: false,
  ///   isDirty: false,
  ///   busy: false,
  ///   canSave: false,
  ///   saveErrorText: null,
  ///   permissionDeniedText: null,
  ///   showOpenSettings: false,
  ///   photoPath: null,
  ///   showPhotoBytes: false,
  ///   showPhotoPath: false,
  ///   showPhotoError: false,
  /// );
  /// ```
  const ExerciseHistoryEditScreenEntity({
    required this.showLoading,
    required this.showMissing,
    required this.showLoadError,
    required this.canRetry,
    required this.loadErrorText,
    required this.distanceText,
    required this.hoursText,
    required this.minutesText,
    required this.secondsText,
    required this.averageSpeedText,
    required this.caloriesText,
    required this.recordedAtText,
    required this.showHandEntryGuidance,
    required this.isDirty,
    required this.busy,
    required this.canSave,
    required this.saveErrorText,
    required this.permissionDeniedText,
    required this.showOpenSettings,
    required this.photoPath,
    required this.showPhotoBytes,
    required this.showPhotoPath,
    required this.showPhotoError,
  });

  /// 読込スピナーを出すか。
  final bool showLoading;

  /// 不在 UI を出すか。
  final bool showMissing;

  /// 読込失敗 UI を出すか。
  final bool showLoadError;

  /// 再試行を出せるか。
  final bool canRetry;

  /// 読込失敗文言。無ければ null。
  final String? loadErrorText;

  /// 走行距離の入力文字。
  final String distanceText;

  /// 運動時間・時。
  final String hoursText;

  /// 運動時間・分。
  final String minutesText;

  /// 運動時間・秒。
  final String secondsText;

  /// 平均速度（表示のみ）。
  final String averageSpeedText;

  /// 消費カロリー。
  final String caloriesText;

  /// 記録日時。
  final String recordedAtText;

  /// 手打ち案内を出すか。
  final bool showHandEntryGuidance;

  /// 未保存変更があるか。
  final bool isDirty;

  /// 読取・保存中で操作を止めるか。
  final bool busy;

  /// 保存ボタンを有効にするか。
  final bool canSave;

  /// 保存失敗文言。無ければ null。
  final String? saveErrorText;

  /// 権限拒否文言。無ければ null。
  final String? permissionDeniedText;

  /// 設定を開く導線を出すか。
  final bool showOpenSettings;

  /// 既存写真パス。
  final String? photoPath;

  /// 差し替えバイトの Image.memory を出すか。
  final bool showPhotoBytes;

  /// 既存パスの Image.file を出すか。
  final bool showPhotoPath;

  /// 写真が無いときのエラー文言を出すか。
  final bool showPhotoError;
}
