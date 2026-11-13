import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/debug_screen_view_model.dart';
import 'debug_screen_providers.dart';

/// 上書きスイッチ・診断結果・アプリログ。
///
/// アプリログは固定高さの編集不可テキスト領域で示し、親 ListView と独立してスクロールする。
///
/// Example:
/// ```dart
/// const DebugScreenBody();
/// ```
@internal
class DebugScreenBody extends HookConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenBody();
  /// ```
  const DebugScreenBody({super.key});

  /// ログ領域の固定高さ（論理ピクセル）。親 ListView 内で内部スクロールさせる。
  static const double _logAreaHeight = 240;

  /// 上書き・診断・ログを縦に並べる。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(DebugScreenProviders.entity);
    final logController = useTextEditingController();
    final logScrollController = useScrollController();
    final logText = entity.logLines.join('\n');
    useEffect(() {
      // Entity の結合文字列を Controller へ映す。変化時のみ。スクロール位置は維持する。
      syncLogText(logController, logScrollController, logText);
      return null;
    }, [logText]);
    final canGenerateText = switch (entity.canGenerate) {
      null => '-',
      true => strings.screen_feature_debug_yes,
      false => strings.screen_feature_debug_no,
    };
    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_debug_title),
        prefixes: [
          FHeaderAction.back(
            onPress: () => ref.read(DebugScreenViewModel.provider).onBack(),
            semanticsLabel: strings.screen_feature_debug_back_semantics,
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            strings.screen_feature_debug_section_overrides,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FTileGroup(
            children: [
              FTile(
                title: Text(
                  strings.screen_feature_debug_force_spatial_ocr_item,
                ),
                suffix: FSwitch(
                  value: entity.forceSpatialOcr,
                  onChange: (value) => ref
                      .read(DebugScreenViewModel.provider)
                      .onToggleForceSpatialOcr(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            strings.screen_feature_debug_section_availability,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (entity.running)
            Text(strings.screen_feature_debug_running)
          else ...[
            _line(
              strings.screen_feature_debug_readiness_label,
              entity.readiness,
            ),
            _line(strings.screen_feature_debug_status_label, entity.status),
            _line(strings.screen_feature_debug_reason_label, entity.reason),
            _line(strings.screen_feature_debug_message_label, entity.message),
            _line(strings.screen_feature_debug_backend_label, entity.backend),
            _line(
              strings.screen_feature_debug_platform_notes_label,
              entity.platformNotes,
            ),
            _line(
              strings.screen_feature_debug_availability_error_label,
              entity.availabilityError,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            strings.screen_feature_debug_section_probe,
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _line(
            strings.screen_feature_debug_can_generate_label,
            canGenerateText,
          ),
          _line(
            strings.screen_feature_debug_sample_output_label,
            entity.sampleOutput,
          ),
          _line(
            strings.screen_feature_debug_generate_error_label,
            entity.generateError,
          ),
          _line(
            strings.screen_feature_debug_prepare_error_label,
            entity.prepareError,
          ),
          _line(
            strings.screen_feature_debug_probe_skipped_label,
            entity.probeSkipped,
          ),
          const SizedBox(height: 12),
          FButton(
            onPress: entity.running
                ? null
                : () => ref.read(DebugScreenViewModel.provider).onInitialize(),
            child: Text(strings.screen_feature_debug_run_diagnose),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.screen_feature_debug_section_logs,
                  style: context.theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FButton(
                variant: .secondary,
                onPress: () =>
                    ref.read(DebugScreenViewModel.provider).onClearLogs(),
                child: Text(strings.screen_feature_debug_clear_logs),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: _logAreaHeight,
            // readOnly: true かつ enabled は落とさない（選択・コピーを維持）。
            child: FTextField(
              control: .managed(controller: logController),
              readOnly: true,
              expands: true,
              maxLines: null,
              minLines: null,
              scrollController: logScrollController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SelectableText('$label: $value'),
    );
  }
}

/// [logText] を [logController] へ同期し、[logScrollController] の offset を復元する。
///
/// Example:
/// ```dart
/// syncLogText(controller, scrollController, 'a\\nb');
/// ```
@visibleForTesting
void syncLogText(
  TextEditingController logController,
  ScrollController logScrollController,
  String logText,
) {
  if (logController.text == logText) {
    return;
  }
  final previousOffset = logScrollController.hasClients
      ? logScrollController.offset
      : 0.0;
  final previousSelection = logController.selection;
  final max = logText.length;
  final base = previousSelection.baseOffset.clamp(0, max);
  final extent = previousSelection.extentOffset.clamp(0, max);
  logController.value = TextEditingValue(
    text: logText,
    selection: TextSelection(baseOffset: base, extentOffset: extent),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!logScrollController.hasClients) {
      return;
    }
    final maxScroll = logScrollController.position.maxScrollExtent;
    logScrollController.jumpTo(previousOffset.clamp(0.0, maxScroll));
  });
}
