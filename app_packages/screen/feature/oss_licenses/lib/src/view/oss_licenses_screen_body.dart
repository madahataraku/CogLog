import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/oss_licenses_screen_view_model.dart';
import 'oss_licenses_screen_providers.dart';

/// OSS ライセンス名の一覧。
///
/// Example:
/// ```dart
/// const OssLicensesScreenBody();
/// ```
@internal
class OssLicensesScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesScreenBody();
  /// ```
  const OssLicensesScreenBody({super.key});

  /// 戻るとタイル一覧または空状態を描画する。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(OssLicensesScreenProviders.entity);
    final viewModel = ref.watch(OssLicensesScreenViewModel.provider);
    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_oss_licenses_title),
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
          : ListView(
              children: [
                FTileGroup(
                  children: [
                    for (final name in entity.packageNames)
                      FTile(
                        title: Text(name),
                        onPress: () =>
                            viewModel.onOpenDetail(packageName: name),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
