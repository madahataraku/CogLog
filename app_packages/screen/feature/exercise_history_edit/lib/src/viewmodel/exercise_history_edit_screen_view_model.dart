import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';

import 'delegate/exercise_history_edit_state_to_entity_delegate.dart';
import 'delegate/on_discard_delegate.dart';
import 'delegate/on_field_changed_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_open_app_settings_delegate.dart';
import 'delegate/on_pick_library_photo_delegate.dart';
import 'delegate/on_retake_photo_delegate.dart';
import 'delegate/on_save_delegate.dart';
import 'entity/exercise_history_edit_screen_entity.dart';
import 'state/exercise_history_edit_screen_state.dart';

part 'exercise_history_edit_screen_view_model.action.dart';

/// 運動履歴編集の状態と表示。
///
/// Example:
/// ```dart
/// ExerciseHistoryEditScreenViewModel.provider;
/// ```
@internal
final class ExerciseHistoryEditScreenViewModel {
  /// Usecase と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ExerciseHistoryEditScreenViewModel.provider);
  /// ```
  static final provider =
      Provider.autoDispose<ExerciseHistoryEditScreenViewModel>(
        (ref) {
          final result = ExerciseHistoryEditScreenViewModel._(
            state: MutableStateStream(
              ExerciseHistoryEditScreenState.initial(id: ''),
            ),
            loadDetailUsecase: ref.watch(
              LoadExerciseHistoryDetailUsecase.provider,
            ),
            obtainMeterPhotoUsecase: ref.watch(
              ObtainMeterPhotoUsecase.provider,
            ),
            readMeterPanelUsecase: ref.watch(ReadMeterPanelUsecase.provider),
            updateUsecase: ref.watch(UpdateExerciseHistoryUsecase.provider),
            openAppSettingsUsecase: ref.watch(OpenAppSettingsUsecase.provider),
            navigation: ref.watch(screenNavigationProvider),
            stateToEntity: const ExerciseHistoryEditStateToEntityDelegate(),
          );
          ref.onDispose(() {
            unawaited(result._close());
          });
          return result;
        },
        dependencies: [
          LoadExerciseHistoryDetailUsecase.provider,
          ObtainMeterPhotoUsecase.provider,
          ReadMeterPanelUsecase.provider,
          UpdateExerciseHistoryUsecase.provider,
          OpenAppSettingsUsecase.provider,
          screenNavigationProvider,
        ],
      );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// 詳細の読み込み。
  @visibleForTesting
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// 写真取得。
  @visibleForTesting
  final ObtainMeterPhotoUsecase obtainMeterPhotoUsecase;

  /// パネル読み取り。
  @visibleForTesting
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// 運動履歴の更新。
  @visibleForTesting
  final UpdateExerciseHistoryUsecase updateUsecase;

  /// アプリ設定を開く。
  @visibleForTesting
  final OpenAppSettingsUsecase openAppSettingsUsecase;

  /// 戻る・結果付き pop。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State から表示用 Entity への変換。
  @visibleForTesting
  final ExerciseHistoryEditStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditScreenViewModel.provider;
  /// ```
  const ExerciseHistoryEditScreenViewModel._({
    required this.state,
    required this.loadDetailUsecase,
    required this.obtainMeterPhotoUsecase,
    required this.readMeterPanelUsecase,
    required this.updateUsecase,
    required this.openAppSettingsUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列とフラグ。
  StateStream<ExerciseHistoryEditScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// Widget が監視する作業中状態。
  StateStream<ExerciseHistoryEditScreenState> get screenState => state;

  /// 状態の Stream を閉じる。
  Future<void> _close() => state.close();
}
