import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:view_confirm_dialog/view_confirm_dialog.dart';

import '../strings.dart';
import '../viewmodel/data_management_screen_view_model.dart';
import '../viewmodel/entity/data_management_screen_entity.dart';
import '../viewmodel/state/data_management_screen_state.dart';
import 'data_management_screen_providers.dart';

/// エクスポート／インポート操作の一覧。
///
/// Example:
/// ```dart
/// const DataManagementScreenBody();
/// ```
@internal
class DataManagementScreenBody extends HookConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementScreenBody();
  /// ```
  const DataManagementScreenBody({super.key});

  /// タイル・進捗・結果文言を描画する。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(DataManagementScreenViewModel.provider);
    final entity = ref.watch(DataManagementScreenProviders.entity);
    final confirmHandled = useRef(false);

    useEffect(() {
      if (!entity.awaitingImportConfirm) {
        confirmHandled.value = false;
        return null;
      }
      if (confirmHandled.value) {
        return null;
      }
      confirmHandled.value = true;
      scheduleMicrotask(() async {
        if (!context.mounted) {
          return;
        }
        final ok = await showConfirmDialog(
          context,
          title: strings.screen_feature_data_management_import_confirm_title,
          body: strings.screen_feature_data_management_import_confirm_body,
          confirmLabel:
              strings.screen_feature_data_management_import_confirm_ok,
          cancelLabel:
              strings.screen_feature_data_management_import_confirm_cancel,
        );
        if (!context.mounted) {
          return;
        }
        if (ok) {
          await viewModel.onConfirmImport();
        } else {
          await viewModel.onCancelImportConfirm();
        }
      });
      return null;
    }, [entity.awaitingImportConfirm, viewModel]);

    return PopScope(
      canPop: !entity.blocksRoutePop,
      child: FScaffold(
        header: FHeader.nested(
          title: Text(strings.screen_feature_data_management_title),
          prefixes: [
            FHeaderAction.back(
              onPress: entity.interactive ? viewModel.onBack : null,
              semanticsLabel:
                  strings.screen_feature_data_management_back_semantics,
            ),
          ],
        ),
        child: ListView(
          // FScaffold の childPad とヘッダで余白を持つため、ListView 既定の
          // MediaQuery top padding による AppBar 直下の空きを抑える。
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DefaultTextStyle.merge(
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Text(
                      strings
                          .screen_feature_data_management_description_overview,
                    ),
                    Text(
                      strings.screen_feature_data_management_description_manual,
                    ),
                    Text(
                      strings
                          .screen_feature_data_management_description_privacy,
                    ),
                  ],
                ),
              ),
            ),
            FTileGroup(
              children: [
                FTile(
                  title: Text(
                    strings.screen_feature_data_management_export_item,
                  ),
                  onPress: entity.interactive
                      ? () {
                          unawaited(viewModel.onExport());
                        }
                      : null,
                ),
                FTile(
                  title: Text(
                    strings.screen_feature_data_management_import_item,
                  ),
                  onPress: entity.interactive
                      ? () {
                          unawaited(viewModel.onImportPick());
                        }
                      : null,
                ),
              ],
            ),
            if (entity.showProgress)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.screen_feature_data_management_progress_working,
                    ),
                    const SizedBox(height: 8),
                    FDeterminateProgress(value: entity.progressFraction),
                  ],
                ),
              ),
            ..._statusMessages(entity).map(
              (text) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// フェーズに応じた案内文言。
  ///
  /// Example:
  /// ```dart
  /// DataManagementScreenBody()._statusMessages(entity);
  /// ```
  List<String> _statusMessages(DataManagementScreenEntity entity) {
    switch (entity.phase) {
      case DataManagementPhase.successExport:
        return [strings.screen_feature_data_management_success_export];
      case DataManagementPhase.successExportEmpty:
        return [
          strings.screen_feature_data_management_export_empty_message,
          strings.screen_feature_data_management_success_export,
        ];
      case DataManagementPhase.successImport:
        return [strings.screen_feature_data_management_success_import];
      case DataManagementPhase.successImportWarning:
        return [
          strings.screen_feature_data_management_success_import,
          if (entity.photoMissingCount > 0)
            strings.screen_feature_data_management_photo_missing_warning,
          if (entity.notificationPermissionDenied)
            strings
                .screen_feature_data_management_notification_permission_denied,
        ];
      case DataManagementPhase.error:
        return [_errorText(entity.errorKind)];
      case DataManagementPhase.idle ||
          DataManagementPhase.exporting ||
          DataManagementPhase.picking ||
          DataManagementPhase.confirming ||
          DataManagementPhase.importing:
        return const [];
    }
  }

  /// エラー種別の文言。
  ///
  /// Example:
  /// ```dart
  /// DataManagementScreenBody()._errorText(DataManagementErrorKind.corrupt);
  /// ```
  String _errorText(DataManagementErrorKind? kind) {
    return switch (kind) {
      DataManagementErrorKind.corrupt =>
        strings.screen_feature_data_management_error_corrupt,
      DataManagementErrorKind.unsupportedVersion =>
        strings.screen_feature_data_management_error_unsupported_version,
      DataManagementErrorKind.missingRequired =>
        strings.screen_feature_data_management_error_missing_required,
      DataManagementErrorKind.permissionDenied =>
        strings.screen_feature_data_management_error_permission_denied,
      DataManagementErrorKind.storageFull =>
        strings.screen_feature_data_management_error_storage_full,
      DataManagementErrorKind.unexpected ||
      null => strings.screen_feature_data_management_error_unexpected,
    };
  }
}
