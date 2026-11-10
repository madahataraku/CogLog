import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/oss_licenses_screen_view_model.dart';

/// OSS ライセンス一覧の表示用 Provider。
@internal
final class OssLicensesScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// OssLicensesScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    OssLicensesScreenViewModel.provider,
    (OssLicensesScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const OssLicensesScreenProviders._();
}
