import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_on_device_llm_mobile/src/method_channel_on_device_llm_native_client.dart';
import 'package:infra_on_device_llm_mobile/src/on_device_llm_native_platform_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fromMap は supportsVision を読み、無ければ false', () {
    expect(
      OnDeviceLlmNativePlatformInfo.fromMap(const {
        'backend': 'androidMlKitGenAi',
        'supportsVision': true,
      }).supportsVision,
      isTrue,
    );
    expect(
      OnDeviceLlmNativePlatformInfo.fromMap(const {'backend': 'unsupported'})
          .supportsVision,
      isFalse,
    );
  });

  test('generateWithImage は sessionAddImage を query より先に呼ぶ', () async {
    const channel = MethodChannel('test_on_device_llm');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          switch (call.method) {
            case 'createSession':
            case 'sessionAddImage':
            case 'sessionAddQuery':
            case 'sessionClose':
              return null;
            case 'sessionGetResponse':
              return {'text': 'ok'};
            default:
              return null;
          }
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final client = MethodChannelOnDeviceLlmNativeClient(methodChannel: channel);
    final text = await client.generateWithImage(
      prompt: 'panel',
      imageBytes: Uint8List.fromList([9, 8, 7]),
    );
    expect(text, 'ok');
    expect(calls, [
      'createSession',
      'sessionAddImage',
      'sessionAddQuery',
      'sessionGetResponse',
      'sessionClose',
    ]);
  });

  test('generate は sessionAddImage を呼ばない', () async {
    const channel = MethodChannel('test_on_device_llm_text');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          switch (call.method) {
            case 'createSession':
            case 'sessionAddQuery':
            case 'sessionClose':
              return null;
            case 'sessionGetResponse':
              return {'text': 'text-only'};
            default:
              return null;
          }
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final client = MethodChannelOnDeviceLlmNativeClient(methodChannel: channel);
    expect(await client.generate(prompt: 'hi'), 'text-only');
    expect(calls, isNot(contains('sessionAddImage')));
  });
}
