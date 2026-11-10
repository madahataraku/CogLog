import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/debug_screen_view_model.dart';
import 'debug_screen_providers.dart';

/// 診断結果とアプリログ。
///
/// Example:
/// ```dart
/// const DebugScreenBody();
/// ```
@internal
class DebugScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenBody();
  /// ```
  const DebugScreenBody({super.key});

  /// 診断セクションとログを縦に並べる。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(DebugScreenProviders.entity);
    final viewModel = ref.watch(DebugScreenViewModel.provider);
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
            onPress: viewModel.onBack,
            semanticsLabel: strings.screen_feature_debug_back_semantics,
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            onPress: entity.running ? null : viewModel.onInitialize,
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
                onPress: viewModel.onClearLogs,
                child: Text(strings.screen_feature_debug_clear_logs),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (entity.logLines.isEmpty)
            Text(strings.screen_feature_debug_empty_logs)
          else
            for (final line in entity.logLines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SelectableText(
                  line,
                  style: context.theme.typography.body.sm,
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
