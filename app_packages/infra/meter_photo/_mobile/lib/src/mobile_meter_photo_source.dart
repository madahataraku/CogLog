import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';

/// アプリ内カメラと ImagePicker ライブラリで写真を取る。
///
/// 撮影はシステムカメラを開かず [CameraController.takePicture] のみ。
/// 撮影日時メタは常に null（EXIF 抽出は後続）。
/// 開始と停止はキューで直列化し、古い開始の破棄が新しい初期化と重ならないようにする。
///
/// Example:
/// ```dart
/// MobileMeterPhotoSource();
/// ```
final class MobileMeterPhotoSource implements MeterPhotoSource {
  /// [picker] を差し替え可能にする。省略時は新規 [ImagePicker]。
  ///
  /// Example:
  /// ```dart
  /// MobileMeterPhotoSource();
  /// ```
  MobileMeterPhotoSource({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final StreamController<MeterInAppCameraStatus> _statusController =
      StreamController<MeterInAppCameraStatus>.broadcast();
  MeterInAppCameraStatus _current = const MeterInAppCameraIdle();
  CameraController? _controller;
  int _startToken = 0;
  Future<void> _operation = Future<void>.value();

  /// 現在状態を流し、以降の更新を購読する。
  ///
  /// Example:
  /// ```dart
  /// source.watchInAppCamera();
  /// ```
  @override
  Stream<MeterInAppCameraStatus> watchInAppCamera() async* {
    yield _current;
    yield* _statusController.stream;
  }

  /// 権限要求とプレビュー開始。
  ///
  /// Example:
  /// ```dart
  /// await source.startInAppCamera();
  /// ```
  @override
  Future<void> startInAppCamera() {
    final token = ++_startToken;
    return _enqueue(() => _startInAppCamera(token));
  }

  /// プレビューを止め資源を解放する。
  ///
  /// Example:
  /// ```dart
  /// await source.stopInAppCamera();
  /// ```
  @override
  Future<void> stopInAppCamera() {
    final token = ++_startToken;
    return _enqueue(() => _stopInAppCamera(token));
  }

  /// ready ならライブプレビュー、それ以外は空。
  ///
  /// Example:
  /// ```dart
  /// source.buildInAppPreview();
  /// ```
  @override
  Widget buildInAppPreview({Key? key}) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return SizedBox.shrink(key: key);
    }
    return KeyedSubtree(key: key, child: CameraPreview(controller));
  }

  /// アプリ内カメラで 1 枚撮る。
  ///
  /// Example:
  /// ```dart
  /// await source.captureWithCamera();
  /// ```
  @override
  Future<MeterPhotoCapture?> captureWithCamera() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _current is! MeterInAppCameraReady) {
      return null;
    }
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      return MeterPhotoCapture(bytes: bytes);
    } on CameraException catch (error) {
      if (_isCameraPermissionDenied(error)) {
        throw const MeterPhotoPermissionDeniedException(
          MeterPhotoPermissionKind.camera,
        );
      }
      return null;
    }
  }

  /// ライブラリから 1 枚選ぶ。
  ///
  /// Example:
  /// ```dart
  /// await source.pickFromLibrary();
  /// ```
  @override
  Future<MeterPhotoCapture?> pickFromLibrary() => _pick(
    source: ImageSource.gallery,
    kind: MeterPhotoPermissionKind.library,
  );

  Future<void> _enqueue(Future<void> Function() action) {
    final previous = _operation;
    final run = () async {
      try {
        await previous;
      } on Object {
        // 直前失敗でも次の開始／停止を続行する。
      }
      await action();
    }();
    _operation = run;
    return run;
  }

  Future<void> _startInAppCamera(int token) async {
    if (token != _startToken) {
      return;
    }
    await _disposeController();
    if (token != _startToken) {
      return;
    }
    await _emit(const MeterInAppCameraStarting());
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (token != _startToken) {
        return;
      }
      if (cameras.isEmpty) {
        await _emit(const MeterInAppCameraFailed());
        return;
      }
      final camera = cameras.firstWhere(
        (candidate) => candidate.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (token != _startToken) {
        await _safeDispose(controller);
        return;
      }
      _controller = controller;
      // CameraPreview は縦向きで 1/sensorAspect を使う。画面側の全面表示も
      // 同じ表示縦横比（幅÷高さ）で揃える。
      final sensorAspect = controller.value.aspectRatio;
      final displayAspect = sensorAspect > 0 ? (1 / sensorAspect) : (3 / 4);
      await _emit(MeterInAppCameraReady(aspectRatio: displayAspect));
    } on CameraException catch (error) {
      await _safeDispose(controller);
      if (token != _startToken) {
        return;
      }
      await _disposeController();
      if (_isCameraPermissionDenied(error)) {
        await _emit(const MeterInAppCameraPermissionDenied());
      } else {
        await _emit(const MeterInAppCameraFailed());
      }
    } on Object {
      await _safeDispose(controller);
      if (token != _startToken) {
        return;
      }
      await _disposeController();
      await _emit(const MeterInAppCameraFailed());
    }
  }

  Future<void> _stopInAppCamera(int token) async {
    await _disposeController();
    if (token != _startToken) {
      return;
    }
    await _emit(const MeterInAppCameraIdle());
  }

  Future<void> _emit(MeterInAppCameraStatus next) async {
    _current = next;
    if (!_statusController.isClosed) {
      _statusController.add(next);
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    await _safeDispose(controller);
  }

  Future<void> _safeDispose(CameraController? controller) async {
    if (controller == null) {
      return;
    }
    try {
      await controller.dispose();
    } on Object {
      // 破棄失敗でも状態通知を優先する。
    }
  }

  Future<MeterPhotoCapture?> _pick({
    required ImageSource source,
    required MeterPhotoPermissionKind kind,
  }) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) {
        return null;
      }
      final bytes = await file.readAsBytes();
      return MeterPhotoCapture(bytes: bytes);
    } on PlatformException catch (error) {
      if (_isPickerPermissionDenied(error)) {
        throw MeterPhotoPermissionDeniedException(kind);
      }
      rethrow;
    }
  }

  bool _isCameraPermissionDenied(CameraException error) {
    final code = error.code.toLowerCase();
    return code.contains('access') || code.contains('permission');
  }

  bool _isPickerPermissionDenied(PlatformException error) {
    final code = error.code.toLowerCase();
    return code.contains('access_denied') ||
        code.contains('permission') ||
        code == 'camera_access_denied' ||
        code == 'photo_access_denied';
  }
}
