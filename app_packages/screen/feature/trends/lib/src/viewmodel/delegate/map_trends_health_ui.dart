import 'package:usecase_load_trends/usecase_load_trends.dart';

import '../state/trends_health_permission_ui.dart';

/// usecase の許可結果を画面用 enum へ写す。
///
/// Example:
/// ```dart
/// mapTrendsHealthUi(LoadTrendsHealthPermission.denied);
/// ```
TrendsHealthPermissionUi mapTrendsHealthUi(LoadTrendsHealthPermission status) =>
    switch (status) {
      LoadTrendsHealthPermission.unknown => TrendsHealthPermissionUi.unknown,
      LoadTrendsHealthPermission.granted => TrendsHealthPermissionUi.granted,
      LoadTrendsHealthPermission.denied => TrendsHealthPermissionUi.denied,
      LoadTrendsHealthPermission.permanentlyDenied =>
        TrendsHealthPermissionUi.permanentlyDenied,
    };
