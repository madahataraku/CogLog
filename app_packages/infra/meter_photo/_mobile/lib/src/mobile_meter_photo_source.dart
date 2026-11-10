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
  Future<void> startInAppCamera() async {
    final token = ++_startToken;
    await _disposeController();
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
        await controller.dispose();
        return;
      }
      _controller = controller;
      await _emit(
        MeterInAppCameraReady(aspectRatio: controller.value.aspectRatio),
      );
    } on CameraException catch (error) {
      await controller?.dispose();
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
      await controller?.dispose();
      if (token != _startToken) {
        return;
      }
      await _disposeController();
      await _emit(const MeterInAppCameraFailed());
    }
  }

  /// プレビューを止め資源を解放する。
  ///
  /// Example:
  /// ```dart
  /// await source.stopInAppCamera();
  /// ```
  @override
  Future<void> stopInAppCamera() async {
    _startToken++;
    await _disposeController();
    await _emit(const MeterInAppCameraIdle());
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

  Future<void> _emit(MeterInAppCameraStatus next) async {
    _current = next;
    if (!_statusController.isClosed) {
      _statusController.add(next);
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
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
