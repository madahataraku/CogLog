import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_data_management/src/viewmodel/delegate/map_import_app_data_error.dart';
import 'package:screen_feature_data_management/src/viewmodel/state/data_management_screen_state.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';

void main() {
  test('ImportAppDataError を画面種別へ写す', () {
    expect(
      mapImportAppDataErrorKind(ImportAppDataError.corrupt),
      DataManagementErrorKind.corrupt,
    );
    expect(
      mapImportAppDataErrorKind(ImportAppDataError.unsupportedVersion),
      DataManagementErrorKind.unsupportedVersion,
    );
    expect(
      mapImportAppDataErrorKind(ImportAppDataError.missingRequired),
      DataManagementErrorKind.missingRequired,
    );
    expect(
      mapImportAppDataErrorKind(ImportAppDataError.permissionDenied),
      DataManagementErrorKind.permissionDenied,
    );
    expect(
      mapImportAppDataErrorKind(ImportAppDataError.storageFull),
      DataManagementErrorKind.storageFull,
    );
    expect(
      mapImportAppDataErrorKind(ImportAppDataError.unexpected),
      DataManagementErrorKind.unexpected,
    );
  });
}
