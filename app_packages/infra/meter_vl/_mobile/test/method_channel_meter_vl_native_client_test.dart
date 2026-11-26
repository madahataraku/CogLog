import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_mobile/src/method_channel_meter_vl_native_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getAvailability は Map を写す', () async {
    const channel = MethodChannel('test_meter_vl_availability');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getAvailability');
          return <String, dynamic>{
            'status': 'modelNotDownloaded',
            'reason': 'missingFile',
            'message': 'download needed',
            'backend': 'gpu',
            'visionBackend': 'cpu',
          };
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final client = MethodChannelMeterVlNativeClient(methodChannel: channel);
    final availability = await client.getAvailability();
    expect(availability.status, 'modelNotDownloaded');
    expect(availability.reason, 'missingFile');
    expect(availability.message, 'download needed');
    expect(availability.backend, 'gpu');
    expect(availability.visionBackend, 'cpu');
    expect(availability.isReady, isFalse);
  });

  test('prepareModel は EventChannel の進捗を流す', () async {
    const methodChannel = MethodChannel('test_meter_vl_prepare');
    const eventChannel = EventChannel('test_meter_vl_prepare/events');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      expect(call.method, 'prepareModel');
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(methodChannel, null);
    });

    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.success(0.25);
          events.success(1.0);
          events.endOfStream();
        },
      ),
    );
    addTearDown(() {
      messenger.setMockStreamHandler(eventChannel, null);
    });

    final client = MethodChannelMeterVlNativeClient(
      methodChannel: methodChannel,
      prepareEventChannel: eventChannel,
    );
    expect(await client.prepareModel().toList(), [0.25, 1.0]);
  });

  test('prepareModel の PlatformException を写す', () async {
    const methodChannel = MethodChannel('test_meter_vl_prepare_error');
    const eventChannel = EventChannel('test_meter_vl_prepare_error/events');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(methodChannel, (call) async => null);
    addTearDown(() {
      messenger.setMockMethodCallHandler(methodChannel, null);
    });

    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.error(code: 'insufficientStorage', message: 'disk full');
        },
      ),
    );
    addTearDown(() {
      messenger.setMockStreamHandler(eventChannel, null);
    });

    final client = MethodChannelMeterVlNativeClient(
      methodChannel: methodChannel,
      prepareEventChannel: eventChannel,
    );
    await expectLater(
      client.prepareModel().toList(),
      throwsA(
        isA<MeterVlPrepareException>().having(
          (e) => e.kind,
          'kind',
          MeterVlPrepareFailureKind.insufficientStorage,
        ),
      ),
    );
  });

  test('mapPrepareError は network / generic を写す', () {
    expect(
      MethodChannelMeterVlNativeClient.mapPrepareError(
        PlatformException(code: 'network', message: 'offline'),
      ),
      isA<MeterVlPrepareException>().having(
        (e) => e.kind,
        'kind',
        MeterVlPrepareFailureKind.network,
      ),
    );
    expect(
      MethodChannelMeterVlNativeClient.mapPrepareError(
        PlatformException(code: 'generic'),
      ),
      isA<MeterVlPrepareException>().having(
        (e) => e.kind,
        'kind',
        MeterVlPrepareFailureKind.generic,
      ),
    );
  });

  test('generateWithImage は本文を返す', () async {
    const channel = MethodChannel('test_meter_vl_generate');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'generateWithImage');
          final args = call.arguments! as Map;
          expect(args['prompt'], 'panel');
          expect(args['imageBytes'], Uint8List.fromList([1, 2, 3]));
          return 'DISTANCE_KM=1';
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final client = MethodChannelMeterVlNativeClient(methodChannel: channel);
    expect(
      await client.generateWithImage(
        prompt: 'panel',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      ),
      'DISTANCE_KM=1',
    );
  });
}
