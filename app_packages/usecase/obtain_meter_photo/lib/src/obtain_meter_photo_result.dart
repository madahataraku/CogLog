import 'dart:typed_data';

import 'meter_photo_permission_kind.dart';

part 'obtain_meter_photo_cancelled.dart';
part 'obtain_meter_photo_permission_denied.dart';
part 'obtain_meter_photo_success.dart';

/// 写真取得の結果。キャンセルと権限拒否を区別する。
///
/// Example:
/// ```dart
/// const ObtainMeterPhotoCancelled();
/// ```
sealed class ObtainMeterPhotoResult {
  /// 結果の共通基底。
  ///
  /// Example:
  /// ```dart
  /// const ObtainMeterPhotoCancelled();
  /// ```
  const ObtainMeterPhotoResult();
}
