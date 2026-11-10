import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_app_runtime_info/usecase_load_app_runtime_info.dart';

import '../state/app_settings_screen_state.dart';

/// アプリ実行情報を読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadUsecase: loadUsecase,
/// );
/// ```
final class OnInitializeDelegate {
  /// [state] と読込 Usecase を受け取る。
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
  final MutableStateStream<AppSettingsScreenState> state;

  /// 実行情報の読込。
  final LoadAppRuntimeInfoUsecase loadUsecase;

  /// 実行情報を読んで [state] を更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final info = await loadUsecase.execute();
    try {
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(AppSettingsScreenState(loading: false, info: info));
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
