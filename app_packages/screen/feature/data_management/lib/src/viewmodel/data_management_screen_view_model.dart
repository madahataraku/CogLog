import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_export_app_data/usecase_export_app_data.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';

import 'delegate/data_management_state_to_entity_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_cancel_import_confirm_delegate.dart';
import 'delegate/on_confirm_import_delegate.dart';
import 'delegate/on_export_delegate.dart';
import 'delegate/on_import_pick_delegate.dart';
import 'entity/data_management_screen_entity.dart';
import 'state/data_management_screen_state.dart';

part 'data_management_screen_view_model.action.dart';

/// データ管理画面の状態と操作。
///
/// Example:
/// ```dart
/// DataManagementScreenViewModel.provider;
/// ```
@internal
final class DataManagementScreenViewModel {
  /// Usecase と遷移を注入する。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(DataManagementScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<DataManagementScreenViewModel>(
    (ref) {
      final result = DataManagementScreenViewModel._(
        state: MutableStateStream(DataManagementScreenState.initial),
        exportUsecase: ref.watch(ExportAppDataUsecase.provider),
        importUsecase: ref.watch(ImportAppDataUsecase.provider),
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const DataManagementStateToEntityDelegate(),
        ref: ref,
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      ExportAppDataUsecase.provider,
      ImportAppDataUsecase.provider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<DataManagementScreenState> state;

  /// エクスポート。
  @visibleForTesting
  final ExportAppDataUsecase exportUsecase;

  /// インポート。
  @visibleForTesting
  final ImportAppDataUsecase importUsecase;

  /// 遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final DataManagementStateToEntityDelegate stateToEntity;

  /// 世代カウンタ更新用。
  @visibleForTesting
  final Ref ref;

  DataManagementScreenViewModel._({
    required this.state,
    required this.exportUsecase,
    required this.importUsecase,
    required this.navigation,
    required this.stateToEntity,
    required this.ref,
  });

  Future<void> _close() => state.close();
}
