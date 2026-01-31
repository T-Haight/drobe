import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'capture_state.dart';

final captureControllerProvider =
    NotifierProvider<CaptureController, CaptureState>(
      () => CaptureController(),
    );

class CaptureController extends Notifier<CaptureState> {
  @override
  CaptureState build() => CaptureState(status: CaptureStatus.idle);
  CameraController? cameraController;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController!.initialize();
  }

  Future<void> startRecording() async {
    state = state.copyWith(status: CaptureStatus.recording);
    await cameraController!.startVideoRecording();

    Future.delayed(const Duration(seconds: 20), () {
      if (state.status == CaptureStatus.recording) {
        stopRecording();
      }
    });
  }

  Future<void> stopRecording() async {
    final file = await cameraController!.stopVideoRecording();
    state = state.copyWith(status: CaptureStatus.uploading);

    // TODO: upload video
  }
}
