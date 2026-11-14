import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:meta/meta.dart';

import 'gemma_meter_native_availability.dart';
import 'gemma_meter_native_client.dart';

/// [MethodChannel] / [EventChannel] 実装。
///
/// Example:
/// ```dart
/// MethodChannelGemmaMeterNativeClient();
/// ```
final class MethodChannelGemmaMeterNativeClient
    implements GemmaMeterNativeClient {
  /// 既定 channel 名で作る。
  ///
  /// テストでは [methodChannel] / [prepareEventChannel] を差し替えられる。
  ///
  /// Example:
  /// ```dart
  /// MethodChannelGemmaMeterNativeClient();
  /// ```
  MethodChannelGemmaMeterNativeClient({
    MethodChannel? methodChannel,
    EventChannel? prepareEventChannel,
  }) : methodChannel =
           methodChannel ?? const MethodChannel('infra_gemma_meter'),
       prepareEventChannel =
           prepareEventChannel ??
           const EventChannel('infra_gemma_meter/prepare');

  /// 可用性・生成用 channel。
  @visibleForTesting
  final MethodChannel methodChannel;

  /// モデル準備進捗用 channel。
  @visibleForTesting
  final EventChannel prepareEventChannel;

  /// [PlatformException] の code を [GemmaMeterPrepareException] へ写す。
  ///
  /// 既知でない code は [GemmaMeterPrepareFailureKind.generic] とする。
  /// [PlatformException] 以外はそのまま返す。
  ///
  /// Example:
  /// ```dart
  /// MethodChannelGemmaMeterNativeClient.mapPrepareError(
  ///   PlatformException(code: 'network'),
  /// );
  /// ```
  @visibleForTesting
  static Object mapPrepareError(Object error) {
    if (error is! PlatformException) {
      return error;
    }
    final kind = switch (error.code) {
      'insufficientStorage' => GemmaMeterPrepareFailureKind.insufficientStorage,
      'network' => GemmaMeterPrepareFailureKind.network,
      'generic' => GemmaMeterPrepareFailureKind.generic,
      _ => GemmaMeterPrepareFailureKind.generic,
    };
    return GemmaMeterPrepareException(kind, message: error.message);
  }

  /// ネイティブへ可用性を問い合わせる。
  ///
  /// 応答 Map が無いときは `platformUnsupported` の unavailable を返す。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelGemmaMeterNativeClient().getAvailability();
  /// ```
  @override
  Future<GemmaMeterNativeAvailability> getAvailability() async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'getAvailability',
    );
    if (map == null) {
      return const GemmaMeterNativeAvailability(
        status: 'unavailable',
        reason: 'platformUnsupported',
        message: 'No native implementation answered.',
      );
    }
    return GemmaMeterNativeAvailability.fromMap(map);
  }

  /// 画像付き短文生成をネイティブへ委譲する。
  ///
  /// 戻りが null のときは空文字にする。
  ///
  /// Example:
  /// ```dart
  /// await MethodChannelGemmaMeterNativeClient().generateWithImage(
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
  /// await MethodChannelGemmaMeterNativeClient().diagnoseGenerateWithImage(
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
  ///     in MethodChannelGemmaMeterNativeClient().prepareModel()) {
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
}
