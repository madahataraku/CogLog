import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';

import '../state/oss_license_detail_screen_state.dart';

/// 対象パッケージの本文を読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadUsecase: loadUsecase,
/// ).execute(packageName: 'riverpod');
/// ```
final class OnInitializeDelegate {
  /// [state] と一覧 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadUsecase: loadUsecase,
  /// );
  /// ```
  const OnInitializeDelegate({required this.state, required this.loadUsecase});

  /// 画面状態。
  final MutableStateStream<OssLicenseDetailScreenState> state;

  /// ライセンス読込。
  final LoadOssLicensesUsecase loadUsecase;

  /// [packageName] に一致する本文を読む。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(packageName: 'riverpod');
  /// ```
  Future<void> execute({required String packageName}) async {
    final entries = await loadUsecase.execute();
    String? licenseText;
    for (final entry in entries) {
      if (entry.name == packageName) {
        licenseText = entry.license;
        break;
      }
    }
    try {
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(
          OssLicenseDetailScreenState(
            packageName: packageName,
            licenseText: licenseText,
          ),
        );
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
