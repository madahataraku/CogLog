import 'package:infra_local_notification_testing/infra_local_notification_testing.dart';
import 'package:test/test.dart';

void main() {
  test('schedule と cancel を記録する', () async {
    final gateway = FakeLocalNotificationGateway(permissionGranted: true);
    await gateway.initialize(onNotificationOpenHome: () {});
    expect(gateway.initializeCount, 1);

    final when = DateTime(2026, 11, 10, 17);
    await gateway.scheduleReminder(when: when, title: 't', body: 'b');
    expect(gateway.scheduled?.when, when);

    await gateway.cancelReminder();
    expect(gateway.scheduled, isNull);
    expect(gateway.cancelCount, 1);
  });
}
