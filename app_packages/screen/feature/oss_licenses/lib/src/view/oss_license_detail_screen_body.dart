import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/detail/oss_license_detail_screen_view_model.dart';
import 'oss_license_detail_screen_providers.dart';

/// ライセンス本文または空状態。
///
/// Example:
/// ```dart
/// const OssLicenseDetailScreenBody();
/// ```
@internal
class OssLicenseDetailScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseDetailScreenBody();
  /// ```
  const OssLicenseDetailScreenBody({super.key});

  /// 戻ると本文または空状態を描画する。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseDetailScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(OssLicenseDetailScreenProviders.entity);
    final viewModel = ref.watch(OssLicenseDetailScreenViewModel.provider);
    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_oss_licenses_detail_title),
        prefixes: [
          FHeaderAction.back(
            onPress: viewModel.onBack,
            semanticsLabel: strings.screen_feature_oss_licenses_back_semantics,
          ),
        ],
      ),
      child: entity.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  strings.screen_feature_oss_licenses_empty,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(entity.licenseText),
            ),
    );
  }
}
