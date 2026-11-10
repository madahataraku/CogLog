import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/detail/oss_license_detail_screen_view_model.dart';
import 'oss_license_detail_screen_body.dart';

/// OSS ライセンス詳細画面。
///
/// Example:
/// ```dart
/// OssLicenseDetailScreen(packageName: 'riverpod');
/// ```
class OssLicenseDetailScreen extends HookConsumerWidget {
  /// [packageName] を持つ詳細画面を作る。
  ///
  /// Example:
  /// ```dart
  /// OssLicenseDetailScreen(packageName: 'riverpod');
  /// ```
  const OssLicenseDetailScreen({required this.packageName, super.key});

  /// 対象のパッケージ名。
  final String packageName;

  /// 初回読込を走らせ、見た目は [OssLicenseDetailScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// OssLicenseDetailScreen(packageName: 'riverpod');
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(OssLicenseDetailScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize(packageName: packageName);
      return null;
    }, [viewModel, packageName]);
    return const OssLicenseDetailScreenBody();
  }
}
