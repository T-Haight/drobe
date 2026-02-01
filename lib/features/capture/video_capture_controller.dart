import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'video_capture_state.dart';

final videoCaptureControllerProvider =
    NotifierProvider<VideoCaptureController, VideoCaptureState>(
      () => VideoCaptureController(),
    );

class VideoCaptureController extends Notifier<VideoCaptureState> {
  @override
  VideoCaptureState build() =>
      VideoCaptureState(status: VideoCaptureStatus.idle);
  CameraController? cameraController;

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

      // Try to find back or external camera first, otherwise use any available camera
      final camera = cameras.firstWhere(
        (c) => !c.name.contains('Virtual'),
        //  (c.lensDirection == CameraLensDirection.back ||
        //  c.lensDirection == CameraLensDirection.external),
        orElse: () =>
            cameras.last, // Fallback to first available camera (e.g., front)
      );

      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      state = state.copyWith(status: VideoCaptureStatus.idle);
    } catch (e) {
      state = state.copyWith(
        status: VideoCaptureStatus.error,
        error: 'Failed to initialize camera: ${e.toString()}',
      );
    }
  }

  Future<void> startRecording() async {
    state = state.copyWith(status: VideoCaptureStatus.recording);
    await cameraController!.startVideoRecording();

    Future.delayed(const Duration(seconds: 30), () {
      if (state.status == VideoCaptureStatus.recording) {
        stopRecording();
      }
    });
  }

  Future<void> stopRecording() async {
    final videoFile = await cameraController!.stopVideoRecording();
    state = state.copyWith(
      status: VideoCaptureStatus.preview,
      recordedVideoPath: videoFile.path,
    );
  }

  Future<void> submitVideo() async {
    // This will be called when user confirms the video
    // The actual upload will be handled by the screen/repository
    state = state.copyWith(status: VideoCaptureStatus.uploading);
  }

  void cancelPreview() {
    // Return to idle state and clear the recorded video
    state = state.copyWith(
      status: VideoCaptureStatus.idle,
      clearVideoPath: true,
    );
  }
}
