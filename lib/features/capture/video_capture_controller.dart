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
      state = state.copyWith(status: VideoCaptureStatus.detecting);

      cameraController!.startImageStream((CameraImage image) async {
        // Process the image for clothing detection
        await processImageForDetection(image);
      });

    } catch (e) {
      state = state.copyWith(
        status: VideoCaptureStatus.error,
        error: 'Failed to initialize camera: ${e.toString()}',
      );
    }
  }

  // New method to process image for clothing detection
  Future<void> processImageForDetection(CameraImage image) async {
    // Convert image to the format required by the ML model
    // Send the image to the ML model for detection
    // Update state with detected items
  }
}
