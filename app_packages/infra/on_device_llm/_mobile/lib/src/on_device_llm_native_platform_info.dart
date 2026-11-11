/// ネイティブ層のプラットフォーム診断。
///
/// Example:
/// ```dart
/// const OnDeviceLlmNativePlatformInfo(
///   backend: 'androidMlKitGenAi',
///   diagnosticNotes: 'modelReady=true',
/// );
/// ```
final class OnDeviceLlmNativePlatformInfo {
  /// [backend] と任意の [diagnosticNotes] / [supportsVision] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const OnDeviceLlmNativePlatformInfo(backend: 'androidMlKitGenAi');
  /// ```
  const OnDeviceLlmNativePlatformInfo({
    required this.backend,
    this.diagnosticNotes,
    this.supportsVision = false,
  });

  /// MethodChannel の Map から復元する。
  ///
  /// Example:
  /// ```dart
  /// OnDeviceLlmNativePlatformInfo.fromMap(const {'backend': 'unsupported'});
  /// ```
  factory OnDeviceLlmNativePlatformInfo.fromMap(Map<String, dynamic> map) {
    return OnDeviceLlmNativePlatformInfo(
      backend: map['backend'] as String? ?? 'unsupported',
      diagnosticNotes: map['diagnosticNotes'] as String?,
      supportsVision: map['supportsVision'] as bool? ?? false,
    );
  }

  /// バックエンド識別子。
  final String backend;

  /// 診断メモ（Android FORK 必須項目を含むことがある）。
  final String? diagnosticNotes;

  /// 画像入力付き生成が使えるとき true。
  final bool supportsVision;
}
