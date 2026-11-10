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
  VoidCallback? _controllerListener;
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
      _attachController(controller);
      await _emit(
        MeterInAppCameraReady(
          aspectRatio: _displayAspectRatio(controller.value),
        ),
      );
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

  /// [CameraPreview] と同じ向き規則で表示縦横比（幅÷高さ）を求める。
  ///
  /// Example:
  /// ```dart
  /// source._displayAspectRatio(controller.value);
  /// ```
  double _displayAspectRatio(CameraValue value) {
    final sensorAspect = value.aspectRatio;
    if (sensorAspect <= 0) {
      return 3 / 4;
    }
    return _isPreviewLandscape(value) ? sensorAspect : (1 / sensorAspect);
  }

  /// [CameraPreview] と同じ向き判定。
  ///
  /// Example:
  /// ```dart
  /// source._isPreviewLandscape(controller.value);
  /// ```
  bool _isPreviewLandscape(CameraValue value) {
    final orientation = value.isRecordingVideo
        ? value.recordingOrientation!
        : (value.previewPauseOrientation ??
              value.lockedCaptureOrientation ??
              value.deviceOrientation);
    return orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight;
  }

  void _attachController(CameraController controller) {
    _detachControllerListener();
    _controller = controller;
    _controllerListener = _handleControllerChanged;
    controller.addListener(_controllerListener!);
  }

  void _detachControllerListener() {
    final controller = _controller;
    final listener = _controllerListener;
    _controllerListener = null;
    if (controller != null && listener != null) {
      controller.removeListener(listener);
    }
  }

  /// 向き変化で表示比率が変わったら ready を再通知する。
  ///
  /// Example:
  /// ```dart
  /// controller.addListener(source._handleControllerChanged);
  /// ```
  void _handleControllerChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final current = _current;
    if (current is! MeterInAppCameraReady) {
      return;
    }
    final next = _displayAspectRatio(controller.value);
    if ((current.aspectRatio - next).abs() < 0.0001) {
      return;
    }
    unawaited(_emit(MeterInAppCameraReady(aspectRatio: next)));
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _detachControllerListener();
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
