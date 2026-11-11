import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'on_device_llm_native_availability.dart';
import 'on_device_llm_native_client.dart';
import 'on_device_llm_native_platform_info.dart';

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

  /// セッション ID の衝突を避ける乱数。
  final Random _random = Random();

  /// 同一 download EventChannel 名の進行中 [prepare] を共有する。
  static final Map<String, Future<void>> _prepareInFlightByChannel = {};

  /// Map 戻り値の method を呼び出す。
  ///
  /// Example:
  /// ```dart
  /// await client._invokeMap('getAvailability');
  /// ```
  Future<Map<String, dynamic>?> _invokeMap(
    String method, [
    Object? arguments,
  ]) async {
    return methodChannel.invokeMapMethod<String, dynamic>(method, arguments);
  }

  /// 任意型の method を呼び出す。
  ///
  /// Example:
  /// ```dart
  /// await client._invoke<void>('sessionClose', {'sessionId': id});
  /// ```
  Future<T?> _invoke<T>(String method, [Object? arguments]) {
    return methodChannel.invokeMethod<T>(method, arguments);
  }

  /// 時刻と乱数から一意なセッション ID を作る。
  ///
  /// Example:
  /// ```dart
  /// final id = client._newSessionId();
  /// ```
  String _newSessionId() =>
      's${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(1 << 20).toRadixString(36)}';

  /// セッションを開いて任意の [imageBytes] と [prompt] を送り、本文を返す。
  ///
  /// Example:
  /// ```dart
  /// await client._runSession('hi');
  /// ```
  Future<String> _runSession(String prompt, {Uint8List? imageBytes}) async {
    final sessionId = _newSessionId();
    await _invoke<void>('createSession', {'sessionId': sessionId});
    try {
      if (imageBytes != null) {
        await _invoke<void>('sessionAddImage', {
          'sessionId': sessionId,
          'imageBytes': imageBytes,
        });
      }
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

  /// download EventChannel を購読し、完了または失敗まで待つ。
  ///
  /// Example:
  /// ```dart
  /// await client._runPrepare();
  /// ```
  Future<void> _runPrepare() async {
    String? failure;
    var ready = false;
    StreamSubscription<dynamic>? subscription;
    final done = Completer<void>();
    try {
      subscription = downloadEventChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is! Map) {
            return;
          }
          final map = Map<String, dynamic>.from(event);
          final status = map['status'] as String?;
          if (status == 'available') {
            ready = true;
            if (!done.isCompleted) {
              done.complete();
            }
          } else if (status == 'unavailable') {
            failure = map['errorMessage'] as String? ?? 'unavailable';
            if (!done.isCompleted) {
              done.complete();
            }
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!done.isCompleted) {
            done.completeError(error, stackTrace);
          }
        },
        onDone: () {
          if (!done.isCompleted) {
            done.complete();
          }
        },
        cancelOnError: true,
      );
      await done.future;
    } finally {
      await subscription?.cancel();
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

  /// 既存セッション method 列で画像付き生成する。新規 MethodChannel 名は作らない。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelOnDeviceLlmNativeClient().generateWithImage(
  ///   prompt: 'hi',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) => _runSession(prompt, imageBytes: imageBytes);

  @override
  Future<String> diagnoseGenerate({required String prompt}) =>
      _runSession(prompt);

  /// 進行中の準備があればそれを共有し、なければ download 購読を開始する。
  ///
  /// 同一 [downloadEventChannel] 名のインスタンス間でも共有する。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelOnDeviceLlmNativeClient().prepare();
  /// ```
  @override
  Future<void> prepare() async {
    final channelName = downloadEventChannel.name;
    final inFlight = _prepareInFlightByChannel[channelName];
    if (inFlight != null) {
      return inFlight;
    }

    final state = await getAvailability();
    if (state.isReady) {
      return;
    }
    if (state.status == 'unavailable' && state.reason != 'modelNotReady') {
      throw StateError('OnDeviceLlm model is unavailable: ${state.message}');
    }

    // getAvailability 待ちのあいだに別呼び出しが開始している場合は共有する。
    final raced = _prepareInFlightByChannel[channelName];
    if (raced != null) {
      return raced;
    }

    final future = _runPrepare();
    _prepareInFlightByChannel[channelName] = future;
    try {
      await future;
    } finally {
      if (identical(_prepareInFlightByChannel[channelName], future)) {
        _prepareInFlightByChannel.remove(channelName);
      }
    }
  }
}
