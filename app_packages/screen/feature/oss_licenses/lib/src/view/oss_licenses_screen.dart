import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/oss_licenses_screen_view_model.dart';
import 'oss_licenses_screen_body.dart';

/// OSS ライセンス一覧画面。
///
/// Example:
/// ```dart
/// const OssLicensesScreen();
/// ```
class OssLicensesScreen extends HookConsumerWidget {
  /// 一覧画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesScreen();
  /// ```
  const OssLicensesScreen({super.key});

  /// 初回読込を走らせ、見た目は [OssLicensesScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(OssLicensesScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const OssLicensesScreenBody();
  }
}
