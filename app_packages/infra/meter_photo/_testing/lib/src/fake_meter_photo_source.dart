import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';

/// テスト用の固定写真ソース。
///
/// キャンセルは戻り値 null、権限拒否はフラグで再現する。
///
/// Example:
/// ```dart
/// FakeMeterPhotoSource(cameraCapture: MeterPhotoCapture(bytes: Uint8List(0)));
/// ```
final class FakeMeterPhotoSource implements MeterPhotoSource {
  /// 返却値と権限拒否フラグを指定する。
  ///
  /// Example:
  /// ```dart
  /// FakeMeterPhotoSource(throwPermissionOnCamera: true);
  /// ```
  FakeMeterPhotoSource({
    this.cameraCapture,
    this.libraryCapture,
    this.throwPermissionOnCamera = false,
    this.throwPermissionOnLibrary = false,
    this.startBehavior = const MeterInAppCameraReady(aspectRatio: 0.75),
  });

  /// [captureWithCamera] が返す値。null はキャンセル／失敗。
  MeterPhotoCapture? cameraCapture;

  /// [pickFromLibrary] が返す値。null はキャンセル。
  MeterPhotoCapture? libraryCapture;

  /// true のときカメラで権限拒否例外を投げる。
  bool throwPermissionOnCamera;

  /// true のときライブラリで権限拒否例外を投げる。
  bool throwPermissionOnLibrary;

  /// [startInAppCamera] 完了後に出す状態。
  MeterInAppCameraStatus startBehavior;

  /// [captureWithCamera] が呼ばれた回数。
  int captureCallCount = 0;

  /// [pickFromLibrary] が呼ばれた回数。
  int pickCallCount = 0;

  /// [startInAppCamera] が呼ばれた回数。
  int startCallCount = 0;

  /// [stopInAppCamera] が呼ばれた回数。
  int stopCallCount = 0;

  final StreamController<MeterInAppCameraStatus> _statusController =
      StreamController<MeterInAppCameraStatus>.broadcast();
  MeterInAppCameraStatus _current = const MeterInAppCameraIdle();

  /// テストから status を直接流す。
  ///
  /// Example:
  /// ```dart
  /// fake.emitStatus(const MeterInAppCameraFailed());
  /// ```
  void emitStatus(MeterInAppCameraStatus status) {
    _current = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  /// アプリ内カメラ状態。
  ///
  /// Example:
  /// ```dart
  /// fake.watchInAppCamera();
  /// ```
  @override
  Stream<MeterInAppCameraStatus> watchInAppCamera() async* {
    yield _current;
    yield* _statusController.stream;
  }

  /// [startBehavior] へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// await fake.startInAppCamera();
  /// ```
  @override
  Future<void> startInAppCamera() async {
    startCallCount += 1;
    emitStatus(const MeterInAppCameraStarting());
    emitStatus(startBehavior);
  }

  /// idle へ戻す。
  ///
  /// Example:
  /// ```dart
  /// await fake.stopInAppCamera();
  /// ```
  @override
  Future<void> stopInAppCamera() async {
    stopCallCount += 1;
    emitStatus(const MeterInAppCameraIdle());
  }

  /// Golden／Widget テスト用の色付きプレビュー。
  ///
  /// Example:
  /// ```dart
  /// fake.buildInAppPreview();
  /// ```
  @override
  Widget buildInAppPreview({Key? key}) {
    if (_current is! MeterInAppCameraReady) {
      return SizedBox.shrink(key: key);
    }
    return ColoredBox(
      key: key,
      color: const Color(0xFF336699),
      child: const SizedBox.expand(),
    );
  }

  /// [cameraCapture] を返すか権限拒否する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterPhotoSource().captureWithCamera();
  /// ```
  @override
  Future<MeterPhotoCapture?> captureWithCamera() async {
    captureCallCount += 1;
    if (throwPermissionOnCamera) {
      throw const MeterPhotoPermissionDeniedException(
        MeterPhotoPermissionKind.camera,
      );
    }
    return cameraCapture;
  }

  /// [libraryCapture] を返すか権限拒否する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterPhotoSource().pickFromLibrary();
  /// ```
  @override
  Future<MeterPhotoCapture?> pickFromLibrary() async {
    pickCallCount += 1;
    if (throwPermissionOnLibrary) {
      throw const MeterPhotoPermissionDeniedException(
        MeterPhotoPermissionKind.library,
      );
    }
    return libraryCapture;
  }
}
