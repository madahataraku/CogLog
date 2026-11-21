import 'dart:typed_data';

/// データ管理画面のフェーズ。
///
/// Example:
/// ```dart
/// DataManagementPhase.idle;
/// ```
enum DataManagementPhase {
  /// 操作待ち。
  idle,

  /// エクスポート中。
  exporting,

  /// ファイル選択中。
  picking,

  /// 全置換確認待ち。
  confirming,

  /// インポート適用中。
  importing,

  /// エクスポート成功。
  successExport,

  /// 履歴なしのエクスポート成功。
  successExportEmpty,

  /// インポート成功（警告なし）。
  successImport,

  /// インポート成功（警告あり）。
  successImportWarning,

  /// 失敗。
  error,
}

/// 画面が区別するエラー種別。
///
/// Example:
/// ```dart
/// DataManagementErrorKind.corrupt;
/// ```
enum DataManagementErrorKind {
  /// 破損。
  corrupt,

  /// 非対応版。
  unsupportedVersion,

  /// 必須欠落。
  missingRequired,

  /// 権限拒否。
  permissionDenied,

  /// 容量不足。
  storageFull,

  /// その他。
  unexpected,
}

/// データ管理画面の内部状態。
///
/// Example:
/// ```dart
/// DataManagementScreenState.initial;
/// ```
final class DataManagementScreenState {
  /// 各フィールドを持つ。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementScreenState(
  ///   phase: DataManagementPhase.idle,
  ///   progressFraction: 0,
  ///   errorKind: null,
  ///   photoMissingCount: 0,
  ///   notificationPermissionDenied: false,
  ///   pendingImportBytes: null,
  /// );
  /// ```
  const DataManagementScreenState({
    required this.phase,
    required this.progressFraction,
    required this.errorKind,
    required this.photoMissingCount,
    required this.notificationPermissionDenied,
    required this.pendingImportBytes,
  });

  /// 初期（操作待ち）。
  static const initial = DataManagementScreenState(
    phase: DataManagementPhase.idle,
    progressFraction: 0,
    errorKind: null,
    photoMissingCount: 0,
    notificationPermissionDenied: false,
    pendingImportBytes: null,
  );

  /// 現在のフェーズ。
  final DataManagementPhase phase;

  /// 進捗 0.0–1.0。
  final double progressFraction;

  /// 失敗時の種別。
  final DataManagementErrorKind? errorKind;

  /// 写真欠落件数。
  final int photoMissingCount;

  /// 通知 ON だが OS 許可無し。
  final bool notificationPermissionDenied;

  /// 確認待ちのインポートバイト列。
  final Uint8List? pendingImportBytes;

  /// 操作中でボタンを無効にするか。
  bool get isBusy => switch (phase) {
    DataManagementPhase.exporting ||
    DataManagementPhase.picking ||
    DataManagementPhase.confirming ||
    DataManagementPhase.importing => true,
    _ => false,
  };

  /// 一部フィールドを差し替えたコピー。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(phase: DataManagementPhase.exporting);
  /// ```
  DataManagementScreenState copyWith({
    DataManagementPhase? phase,
    double? progressFraction,
    DataManagementErrorKind? errorKind,
    bool clearErrorKind = false,
    int? photoMissingCount,
    bool? notificationPermissionDenied,
    Uint8List? pendingImportBytes,
    bool clearPendingImportBytes = false,
  }) {
    return DataManagementScreenState(
      phase: phase ?? this.phase,
      progressFraction: progressFraction ?? this.progressFraction,
      errorKind: clearErrorKind ? null : (errorKind ?? this.errorKind),
      photoMissingCount: photoMissingCount ?? this.photoMissingCount,
      notificationPermissionDenied:
          notificationPermissionDenied ?? this.notificationPermissionDenied,
      pendingImportBytes: clearPendingImportBytes
          ? null
          : (pendingImportBytes ?? this.pendingImportBytes),
    );
  }
}
