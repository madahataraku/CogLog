import 'package:flutter_test/flutter_test.dart';
import 'package:screen_navigation_go_router/screen_navigation_go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('openDataManagement は /settings/data を積む', () {
    final navigation = GoRouterScreenNavigation();
    navigation.openDataManagement();
    expect(
      navigation.router.routeInformationProvider.value.uri.path,
      '/settings/data',
    );
  });
}
