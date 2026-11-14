import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_mobile/src/method_channel_gemma_meter_native_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getAvailability は Map を写す', () async {
    const channel = MethodChannel('test_gemma_meter_availability');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getAvailability');
          return <String, dynamic>{
            'status': 'modelNotDownloaded',
            'reason': 'missingFile',
            'message': 'download needed',
          };
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final client = MethodChannelGemmaMeterNativeClient(methodChannel: channel);
    final availability = await client.getAvailability();
    expect(availability.status, 'modelNotDownloaded');
    expect(availability.reason, 'missingFile');
    expect(availability.message, 'download needed');
    expect(availability.isReady, isFalse);
  });

  test('prepareModel は EventChannel の進捗を流す', () async {
    const methodChannel = MethodChannel('test_gemma_meter_prepare');
    const eventChannel = EventChannel('test_gemma_meter_prepare/events');
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

    final client = MethodChannelGemmaMeterNativeClient(
      methodChannel: methodChannel,
      prepareEventChannel: eventChannel,
    );
    expect(await client.prepareModel().toList(), [0.25, 1.0]);
  });

  test('prepareModel の PlatformException を写す', () async {
    const methodChannel = MethodChannel('test_gemma_meter_prepare_error');
    const eventChannel = EventChannel('test_gemma_meter_prepare_error/events');
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

    final client = MethodChannelGemmaMeterNativeClient(
      methodChannel: methodChannel,
      prepareEventChannel: eventChannel,
    );
    await expectLater(
      client.prepareModel().toList(),
      throwsA(
        isA<GemmaMeterPrepareException>().having(
          (e) => e.kind,
          'kind',
          GemmaMeterPrepareFailureKind.insufficientStorage,
        ),
      ),
    );
  });

  test('mapPrepareError は network / generic を写す', () {
    expect(
      MethodChannelGemmaMeterNativeClient.mapPrepareError(
        PlatformException(code: 'network', message: 'offline'),
      ),
      isA<GemmaMeterPrepareException>().having(
        (e) => e.kind,
        'kind',
        GemmaMeterPrepareFailureKind.network,
      ),
    );
    expect(
      MethodChannelGemmaMeterNativeClient.mapPrepareError(
        PlatformException(code: 'generic'),
      ),
      isA<GemmaMeterPrepareException>().having(
        (e) => e.kind,
        'kind',
        GemmaMeterPrepareFailureKind.generic,
      ),
    );
  });

  test('generateWithImage は本文を返す', () async {
    const channel = MethodChannel('test_gemma_meter_generate');
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

    final client = MethodChannelGemmaMeterNativeClient(methodChannel: channel);
    expect(
      await client.generateWithImage(
        prompt: 'panel',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      ),
      'DISTANCE_KM=1',
    );
  });
}
