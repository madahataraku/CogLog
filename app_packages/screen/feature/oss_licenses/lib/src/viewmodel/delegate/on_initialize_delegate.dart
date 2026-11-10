import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';

import '../state/oss_licenses_screen_state.dart';

/// 一覧を読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadUsecase: loadUsecase,
/// );
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
  final MutableStateStream<OssLicensesScreenState> state;

  /// ライセンス読込。
  final LoadOssLicensesUsecase loadUsecase;

  /// 一覧を読む。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final entries = await loadUsecase.execute();
    try {
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(OssLicensesScreenState(entries: entries));
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
