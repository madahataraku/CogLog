import '../state/data_management_screen_state.dart';

/// データ管理画面の表示用。
///
/// Example:
/// ```dart
/// const DataManagementScreenEntity(
///   interactive: true,
///   showProgress: false,
///   progressFraction: 0,
///   phase: DataManagementPhase.idle,
///   errorKind: null,
///   photoMissingCount: 0,
///   notificationPermissionDenied: false,
///   awaitingImportConfirm: false,
/// );
/// ```
final class DataManagementScreenEntity {
  /// 表示に必要な値。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementScreenEntity(
  ///   interactive: false,
  ///   showProgress: true,
  ///   progressFraction: 0.5,
  ///   phase: DataManagementPhase.exporting,
  ///   errorKind: null,
  ///   photoMissingCount: 0,
  ///   notificationPermissionDenied: false,
  ///   awaitingImportConfirm: false,
  /// );
  /// ```
  const DataManagementScreenEntity({
    required this.interactive,
    required this.showProgress,
    required this.progressFraction,
    required this.phase,
    required this.errorKind,
    required this.photoMissingCount,
    required this.notificationPermissionDenied,
    required this.awaitingImportConfirm,
  });

  /// エクスポート／インポートボタンが押せるか。
  final bool interactive;

  /// 確定進捗を出すか。
  final bool showProgress;

  /// 進捗 0.0–1.0。
  final double progressFraction;

  /// 現在のフェーズ。
  final DataManagementPhase phase;

  /// 失敗時の種別。
  final DataManagementErrorKind? errorKind;

  /// 写真欠落件数。
  final int photoMissingCount;

  /// 通知許可無し案内を出すか。
  final bool notificationPermissionDenied;

  /// 全置換確認ダイアログを出すか。
  final bool awaitingImportConfirm;

  /// システム戻るで画面を閉じてはいけないか（エクスポート／選択／適用中）。
  bool get blocksRoutePop => switch (phase) {
    DataManagementPhase.exporting ||
    DataManagementPhase.picking ||
    DataManagementPhase.importing => true,
    _ => false,
  };
}
