import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:meta/meta.dart';

import 'meter_vl_native_availability.dart';
import 'meter_vl_native_client.dart';

/// [MethodChannel] / [EventChannel] 実装。
///
/// Example:
/// ```dart
/// MethodChannelMeterVlNativeClient();
/// ```
final class MethodChannelMeterVlNativeClient implements MeterVlNativeClient {
  /// 既定 channel 名で作る。
  ///
  /// テストでは [methodChannel] / [prepareEventChannel] を差し替えられる。
  ///
  /// Example:
  /// ```dart
  /// MethodChannelMeterVlNativeClient();
  /// ```
  MethodChannelMeterVlNativeClient({
    MethodChannel? methodChannel,
    EventChannel? prepareEventChannel,
  }) : methodChannel = methodChannel ?? const MethodChannel('infra_meter_vl'),
       prepareEventChannel =
           prepareEventChannel ?? const EventChannel('infra_meter_vl/prepare');

  /// 可用性・生成用 channel。
  @visibleForTesting
  final MethodChannel methodChannel;

  /// モデル準備進捗用 channel。
  @visibleForTesting
  final EventChannel prepareEventChannel;

  /// [PlatformException] の code を [MeterVlPrepareException] へ写す。
  ///
  /// 既知でない code は [MeterVlPrepareFailureKind.generic] とする。
  /// [PlatformException] 以外はそのまま返す。
  ///
  /// Example:
  /// ```dart
  /// MethodChannelMeterVlNativeClient.mapPrepareError(
  ///   PlatformException(code: 'network'),
  /// );
  /// ```
  @visibleForTesting
  static Object mapPrepareError(Object error) {
    if (error is! PlatformException) {
      return error;
    }
    final kind = switch (error.code) {
      'insufficientStorage' => MeterVlPrepareFailureKind.insufficientStorage,
      'network' => MeterVlPrepareFailureKind.network,
      'generic' => MeterVlPrepareFailureKind.generic,
      _ => MeterVlPrepareFailureKind.generic,
    };
    return MeterVlPrepareException(kind, message: error.message);
  }

  /// delete 用。`busy` は generic（画面は競合文言を別経路で出す）。
  ///
  /// Example:
  /// ```dart
  /// MethodChannelMeterVlNativeClient.mapDeleteError(
  ///   PlatformException(code: 'busy'),
  /// );
  /// ```
  @visibleForTesting
  static Object mapDeleteError(Object error) {
    if (error is! PlatformException) {
      return error;
    }
    // ネイティブ busy も MeterVlPrepareException(generic) に落とす。
    // 開始前の競合拒否は Dart 側 isOperationBusy で先に弾く。
    return MeterVlPrepareException(
      MeterVlPrepareFailureKind.generic,
      message: error.message,
    );
  }

  /// ネイティブへ可用性を問い合わせる。
  ///
  /// 応答 Map が無いときは `platformUnsupported` の unavailable を返す。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelMeterVlNativeClient().getAvailability();
  /// ```
  @override
  Future<MeterVlNativeAvailability> getAvailability() async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'getAvailability',
    );
    if (map == null) {
      return const MeterVlNativeAvailability(
        status: 'unavailable',
        reason: 'platformUnsupported',
        message: 'No native implementation answered.',
      );
    }
    return MeterVlNativeAvailability.fromMap(map);
  }

  /// 画像付き短文生成をネイティブへ委譲する。
  ///
  /// 戻りが null のときは空文字にする。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelMeterVlNativeClient().generateWithImage(
  ///   prompt: 'hi',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    final text = await methodChannel.invokeMethod<String>(
      'generateWithImage',
      <String, Object?>{'prompt': prompt, 'imageBytes': imageBytes},
    );
    return text ?? '';
  }

  /// readiness を見ずにネイティブ生成を試す。
  ///
  /// 戻りが null のときは空文字にする。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelMeterVlNativeClient().diagnoseGenerateWithImage(
  ///   prompt: 'ping',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    final text = await methodChannel.invokeMethod<String>(
      'diagnoseGenerateWithImage',
      <String, Object?>{'prompt': prompt, 'imageBytes': imageBytes},
    );
    return text ?? '';
  }

  /// [prepareEventChannel] を購読し、`prepareModel` method 起動後の進捗を流す。
  ///
  /// 購読開始時に method を呼び、失敗は [mapPrepareError] 経由で流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress
  ///     in MethodChannelMeterVlNativeClient().prepareModel()) {
  ///   progress;
  /// }
  /// ```
  @override
  Stream<double> prepareModel() {
    late StreamSubscription<dynamic> subscription;
    late final StreamController<double> controller;
    controller = StreamController<double>(
      onListen: () {
        subscription = prepareEventChannel.receiveBroadcastStream().listen(
          (event) {
            if (event is num) {
              controller.add(event.toDouble());
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!controller.isClosed) {
              controller.addError(mapPrepareError(error), stackTrace);
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              unawaited(controller.close());
            }
          },
          cancelOnError: true,
        );
        unawaited(() async {
          try {
            await methodChannel.invokeMethod<void>('prepareModel');
          } on Object catch (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(mapPrepareError(error), stackTrace);
            }
          }
        }());
      },
      onCancel: () async {
        await subscription.cancel();
      },
    );
    return controller.stream;
  }

  /// MethodChannel `deleteDownloadedModels` を呼び、失敗を [mapDeleteError] へ写す。
  ///
  /// Example:
  /// ```dart
  /// await client.deleteDownloadedModels();
  /// ```
  @override
  Future<void> deleteDownloadedModels() async {
    try {
      await methodChannel.invokeMethod<void>('deleteDownloadedModels');
    } on Exception catch (error, stackTrace) {
      // PlatformException 等の失敗を MeterVlPrepareException へ揃える。
      // Error はチャネル実装の想定外として再 throw させる。
      Error.throwWithStackTrace(mapDeleteError(error), stackTrace);
    }
  }

  /// MethodChannel `isOperationBusy` を呼び、null は false とみなす。
  ///
  /// Example:
  /// ```dart
  /// await client.isOperationBusy;
  /// ```
  @override
  Future<bool> get isOperationBusy async {
    final busy = await methodChannel.invokeMethod<bool>('isOperationBusy');
    return busy ?? false;
  }
}
