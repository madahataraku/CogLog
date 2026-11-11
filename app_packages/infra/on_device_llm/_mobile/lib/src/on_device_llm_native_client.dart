import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'on_device_llm_native_availability.dart';
import 'on_device_llm_native_platform_info.dart';

/// OS オンデバイス LLM への MethodChannel 窓口。
///
/// Example:
/// ```dart
/// OnDeviceLlmNativeClient();
/// ```
abstract interface class OnDeviceLlmNativeClient {
  /// 可用性を問い合わせる。
  ///
  /// Example:
  /// ```dart
  /// await OnDeviceLlmNativeClient().getAvailability();
  /// ```
  Future<OnDeviceLlmNativeAvailability> getAvailability();

  /// プラットフォーム診断を問い合わせる。
  ///
  /// Example:
  /// ```dart
  /// await OnDeviceLlmNativeClient().getPlatformInfo();
  /// ```
  Future<OnDeviceLlmNativePlatformInfo> getPlatformInfo();

  /// 短文を生成する。
  ///
  /// Example:
  /// ```dart
  /// await OnDeviceLlmNativeClient().generate(prompt: 'hi');
  /// ```
  Future<String> generate({required String prompt});

  /// readiness を見ずに生成を試す。
  ///
  /// Example:
  /// ```dart
  /// await OnDeviceLlmNativeClient().diagnoseGenerate(prompt: 'ping');
  /// ```
  Future<String> diagnoseGenerate({required String prompt});

  /// モデル準備（ダウンロード）を依頼する。
  ///
  /// Example:
  /// ```dart
  /// await OnDeviceLlmNativeClient().prepare();
  /// ```
  Future<void> prepare();
}

/// [MethodChannel] / [EventChannel] 実装。
///
/// Example:
/// ```dart
/// MethodChannelOnDeviceLlmNativeClient();
/// ```
final class MethodChannelOnDeviceLlmNativeClient
    implements OnDeviceLlmNativeClient {
  /// 既定 channel 名で作る。テストでは [methodChannel] を差し替えられる。
  ///
  /// Example:
  /// ```dart
  /// MethodChannelOnDeviceLlmNativeClient();
  /// ```
  MethodChannelOnDeviceLlmNativeClient({
    MethodChannel? methodChannel,
    EventChannel? downloadEventChannel,
  }) : methodChannel =
           methodChannel ?? const MethodChannel('infra_on_device_llm'),
       downloadEventChannel =
           downloadEventChannel ??
           const EventChannel('infra_on_device_llm/download');

  /// 可用性・セッション用 channel。
  @visibleForTesting
  final MethodChannel methodChannel;

  /// モデル準備進捗用 channel。
  @visibleForTesting
  final EventChannel downloadEventChannel;

  final Random _random = Random();

  Future<Map<String, dynamic>?> _invokeMap(
    String method, [
    Object? arguments,
  ]) async {
    return methodChannel.invokeMapMethod<String, dynamic>(method, arguments);
  }

  Future<T?> _invoke<T>(String method, [Object? arguments]) {
    return methodChannel.invokeMethod<T>(method, arguments);
  }

  String _newSessionId() =>
      's${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(1 << 20).toRadixString(36)}';

  Future<String> _runSession(String prompt) async {
    final sessionId = _newSessionId();
    await _invoke<void>('createSession', {'sessionId': sessionId});
    try {
      await _invoke<void>('sessionAddQuery', {
        'sessionId': sessionId,
        'text': prompt,
      });
      final map = await _invokeMap('sessionGetResponse', {
        'sessionId': sessionId,
      });
      return map?['text'] as String? ?? '';
    } finally {
      await _invoke<void>('sessionClose', {'sessionId': sessionId});
    }
  }

  @override
  Future<OnDeviceLlmNativeAvailability> getAvailability() async {
    final map = await _invokeMap('getAvailability');
    if (map == null) {
      return const OnDeviceLlmNativeAvailability(
        status: 'unavailable',
        reason: 'platformUnsupported',
        message: 'No native implementation answered.',
      );
    }
    return OnDeviceLlmNativeAvailability.fromMap(map);
  }

  @override
  Future<OnDeviceLlmNativePlatformInfo> getPlatformInfo() async {
    final map = await _invokeMap('getPlatformInfo');
    return OnDeviceLlmNativePlatformInfo.fromMap(
      map ?? const {'backend': 'unsupported'},
    );
  }

  @override
  Future<String> generate({required String prompt}) => _runSession(prompt);

  @override
  Future<String> diagnoseGenerate({required String prompt}) =>
      _runSession(prompt);

  @override
  Future<void> prepare() async {
    final state = await getAvailability();
    if (state.isReady) {
      return;
    }
    if (state.status == 'unavailable' && state.reason != 'modelNotReady') {
      throw StateError('OnDeviceLlm model is unavailable: ${state.message}');
    }

    String? failure;
    var ready = false;
    await for (final event in downloadEventChannel.receiveBroadcastStream()) {
      if (event is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(event);
      final status = map['status'] as String?;
      if (status == 'available') {
        ready = true;
      } else if (status == 'unavailable') {
        failure = map['errorMessage'] as String? ?? 'unavailable';
      }
    }
    if (failure != null) {
      throw StateError('Model download failed: $failure');
    }
    if (!ready && !(await getAvailability()).isReady) {
      throw StateError(
        'The model download ended before the model became ready.',
      );
    }
  }
}
