import 'package:usecase_import_app_data/usecase_import_app_data.dart';

import '../state/data_management_screen_state.dart';

/// Usecase のインポートエラーを画面種別へ写す。
///
/// Example:
/// ```dart
/// mapImportAppDataErrorKind(ImportAppDataError.corrupt);
/// ```
DataManagementErrorKind mapImportAppDataErrorKind(ImportAppDataError error) {
  return switch (error) {
    ImportAppDataError.corrupt => DataManagementErrorKind.corrupt,
    ImportAppDataError.unsupportedVersion =>
      DataManagementErrorKind.unsupportedVersion,
    ImportAppDataError.missingRequired =>
      DataManagementErrorKind.missingRequired,
    ImportAppDataError.permissionDenied =>
      DataManagementErrorKind.permissionDenied,
    ImportAppDataError.storageFull => DataManagementErrorKind.storageFull,
    ImportAppDataError.unexpected => DataManagementErrorKind.unexpected,
  };
}
