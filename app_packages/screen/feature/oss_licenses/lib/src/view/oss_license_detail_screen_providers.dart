import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/detail/oss_license_detail_screen_view_model.dart';

/// OSS ライセンス詳細の表示用 Provider。
@internal
final class OssLicenseDetailScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// OssLicenseDetailScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    OssLicenseDetailScreenViewModel.provider,
    (OssLicenseDetailScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const OssLicenseDetailScreenProviders._();
}
