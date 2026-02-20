import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../../core/providers/api_client_provider.dart';
import 'video_capture_state.dart';

final videoCaptureControllerProvider =
    NotifierProvider<VideoCaptureController, VideoCaptureState>(
      () => VideoCaptureController(),
    );

class VideoCaptureController extends Notifier<VideoCaptureState> {
  CameraController? cameraController;
  Timer? _detectionTimer;
  bool _isDetecting = false;
  XFile? lastFrame;

  @override
  VideoCaptureState build() {
    ref.onDispose(() {
      _detectionTimer?.cancel();
      cameraController?.dispose();
    });
    return VideoCaptureState(status: VideoCaptureStatus.idle);
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        state = state.copyWith(
          status: VideoCaptureStatus.error,
          error: 'No cameras found on this device',
        );
        return;
      }

      final camera = cameras.firstWhere(
        (c) => !c.name.contains('Virtual'),
        orElse: () => cameras.last,
      );

      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      state = state.copyWith(status: VideoCaptureStatus.detecting);

      _detectionTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _detectFrame(),
      );
    } catch (e) {
      state = state.copyWith(
        status: VideoCaptureStatus.error,
        error: 'Failed to initialize camera: ${e.toString()}',
      );
    }
  }

  Future<void> _detectFrame() async {
    if (_isDetecting ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      return;
    }
    _isDetecting = true;
    try {
      final xFile = await cameraController!.takePicture();
      lastFrame = xFile;
      final detectionApi = ref.read(apiClientProvider);
      final detections = await detectionApi.detectFrame(xFile);
      debugPrint('[detect] got ${detections.length} detections');
      state = state.copyWith(detections: detections);
    } catch (e, st) {
      debugPrint('[detect] error: $e\n$st');
    } finally {
      _isDetecting = false;
    }
  }

}
