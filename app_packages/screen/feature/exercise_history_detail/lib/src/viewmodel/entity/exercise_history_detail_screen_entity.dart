/// 運動履歴詳細の表示用状態。
///
/// Example:
/// ```dart
/// const ExerciseHistoryDetailScreenEntity(
///   showLoading: false,
///   showMissing: true,
///   showError: false,
///   canRetry: false,
///   errorText: null,
///   showPagePosition: false,
///   pageCurrent: 1,
///   pageTotal: 1,
///   pageLoading: false,
///   caloriesText: '',
///   durationText: '',
///   distanceText: '',
///   createdAtText: '',
///   capturedAtText: '',
///   averageSpeedText: '',
///   recordedAtText: '',
///   recordedAtEditedSuffix: '',
///   savedAtText: '',
///   photoPath: null,
///   showPhoto: false,
///   showPhotoError: false,
/// );
/// ```
final class ExerciseHistoryDetailScreenEntity {
  /// 各欄の文字列と表示フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryDetailScreenEntity(
  ///   showLoading: true,
  ///   showMissing: false,
  ///   showError: false,
  ///   canRetry: false,
  ///   errorText: null,
  ///   showPagePosition: false,
  ///   pageCurrent: 1,
  ///   pageTotal: 0,
  ///   pageLoading: false,
  ///   caloriesText: '',
  ///   durationText: '',
  ///   distanceText: '',
  ///   createdAtText: '',
  ///   capturedAtText: '',
  ///   averageSpeedText: '',
  ///   recordedAtText: '',
  ///   recordedAtEditedSuffix: '',
  ///   savedAtText: '',
  ///   photoPath: null,
  ///   showPhoto: false,
  ///   showPhotoError: false,
  /// );
  /// ```
  const ExerciseHistoryDetailScreenEntity({
    required this.showLoading,
    required this.showMissing,
    required this.showError,
    required this.canRetry,
    required this.errorText,
    required this.showPagePosition,
    required this.pageCurrent,
    required this.pageTotal,
    required this.pageLoading,
    required this.caloriesText,
    required this.durationText,
    required this.distanceText,
    required this.createdAtText,
    required this.capturedAtText,
    required this.averageSpeedText,
    required this.recordedAtText,
    required this.recordedAtEditedSuffix,
    required this.savedAtText,
    required this.photoPath,
    required this.showPhoto,
    required this.showPhotoError,
  });

  /// 読込スピナーを出すか。
  final bool showLoading;

  /// 不在 UI を出すか。
  final bool showMissing;

  /// エラー UI を出すか。
  final bool showError;

  /// 再試行を出せるか。
  final bool canRetry;

  /// エラー文言。無ければ null。
  final String? errorText;

  /// 同一日複数件の件数位置を出すか。
  final bool showPagePosition;

  /// 何件中の何件目か（1 始まり）。
  final int pageCurrent;

  /// 同一日の件数。
  final int pageTotal;

  /// ページめくり後の詳細読込中か。
  final bool pageLoading;

  /// 消費カロリー。
  final String caloriesText;

  /// 運動時間。
  final String durationText;

  /// 走行距離。
  final String distanceText;

  /// 作成開始日時。
  final String createdAtText;

  /// 撮影日時。
  final String capturedAtText;

  /// 平均速度。
  final String averageSpeedText;

  /// 記録日時（サフィックス無し）。
  final String recordedAtText;

  /// 手変更時だけ付く「（編集済み）」。
  final String recordedAtEditedSuffix;

  /// 保存日時。
  final String savedAtText;

  /// 写真パス。無ければ null。
  final String? photoPath;

  /// Image.file を出すか。
  final bool showPhoto;

  /// 写真枠のエラー文言を出すか。
  final bool showPhotoError;
}
