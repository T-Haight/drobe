import 'package:flutter_riverpod/flutter_riverpod.dart';

final captureControllerProvider =
  StateNotifierProvider<CaptureController, CaptureState>(
    (ref) => CaptureController(ref.read),
  );

class CaptureController extends StateNotifier<CaptureState> {
  CaptureController(this.ref)
      : super(CaptureState(status: CaptureStatus.idle));

  final Ref ref;
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
