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
  /// デバッグ画面の本文として親ウィジェットから差し込む。引数は持たない。
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
    // null は未診断、bool はローカライズした yes/no へ。
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
          // 実行中はスナップショット行を出さず進行のみ示す。
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

  /// 診断ラベルと Entity の文字列値を 1 行の選択可能テキストにする。
  ///
  /// Example:
  /// ```dart
  /// _line(strings.screen_feature_debug_status_label, entity.status);
  /// ```
  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SelectableText('$label: $value'),
    );
  }
}

/// [logText] を [logController] へ同期し、必要なら [logScrollController] の offset を復元する。
///
/// 末尾追記では選択を維持し、先頭破棄では残存部分へ選択を移す。対応できない置換では選択を解除する。
/// 利用者のドラッグ／慣性スクロール中、および補正不要時は [ScrollController.jumpTo] を呼ばない。
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
  final previousText = logController.text;
  final previousOffset = logScrollController.hasClients
      ? logScrollController.offset
      : 0.0;
  final previousSelection = logController.selection;
  logController.value = TextEditingValue(
    text: logText,
    selection: mapLogSelection(
      previousText: previousText,
      nextText: logText,
      previousSelection: previousSelection,
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!logScrollController.hasClients) {
      return;
    }
    final position = logScrollController.position;
    if (position.isScrollingNotifier.value) {
      return;
    }
    final target = previousOffset.clamp(0.0, position.maxScrollExtent);
    if ((position.pixels - target).abs() < 0.5) {
      return;
    }
    logScrollController.jumpTo(target);
  });
}

/// ログ文字列の差し替えに合わせて [previousSelection] を写す。
///
/// Example:
/// ```dart
/// mapLogSelection(
///   previousText: 'ab',
///   nextText: 'abc',
///   previousSelection: TextSelection(baseOffset: 1, extentOffset: 2),
/// );
/// ```
@visibleForTesting
TextSelection mapLogSelection({
  required String previousText,
  required String nextText,
  required TextSelection previousSelection,
}) {
  if (!previousSelection.isValid) {
    return const TextSelection.collapsed(offset: 0);
  }
  if (nextText.startsWith(previousText)) {
    return TextSelection(
      baseOffset: previousSelection.baseOffset.clamp(0, nextText.length),
      extentOffset: previousSelection.extentOffset.clamp(0, nextText.length),
    );
  }
  if (nextText.isEmpty) {
    return const TextSelection.collapsed(offset: 0);
  }
  var drop = -1;
  for (var i = 0; i <= previousText.length; i++) {
    if (nextText.startsWith(previousText.substring(i))) {
      drop = i;
      break;
    }
  }
  if (drop < 0 ||
      previousSelection.baseOffset < drop ||
      previousSelection.extentOffset < drop) {
    return const TextSelection.collapsed(offset: 0);
  }
  return TextSelection(
    baseOffset: (previousSelection.baseOffset - drop).clamp(0, nextText.length),
    extentOffset: (previousSelection.extentOffset - drop).clamp(
      0,
      nextText.length,
    ),
  );
}
