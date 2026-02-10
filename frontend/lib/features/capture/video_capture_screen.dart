import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/api_client_provider.dart';
import '../../shared/models/detection.dart';
import 'detection_overlay.dart';
import 'video_capture_controller.dart';
import 'video_capture_state.dart';

class VideoCaptureScreen extends ConsumerStatefulWidget {
  const VideoCaptureScreen({super.key});

  @override
  ConsumerState<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends ConsumerState<VideoCaptureScreen> {
  void _onDetectionTapped(Detection det) async {
    await ref.read(wardrobeApiProvider).saveWardrobeItem(
      detectionId: det.id,
      bbox: {"x": det.x, "y": det.y, "width": det.width, "height": det.height},
      label: det.label,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${det.label} added to wardrobe")),
    );
  }

  @override
  void initState() {
    super.initState();
    ref.read(videoCaptureControllerProvider.notifier).initCamera();
  }

  @override
  void dispose() {
    ref.read(videoCaptureControllerProvider.notifier).cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCaptureControllerProvider);
    final controller =
        ref.read(videoCaptureControllerProvider.notifier).cameraController;

    if (state.status == VideoCaptureStatus.error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Camera Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(videoCaptureControllerProvider.notifier)
                        .initCamera();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          if (state.detections.isNotEmpty &&
              controller.value.previewSize != null)
            DetectionOverlay(
              detections: state.detections,
              previewSize: controller.value.previewSize!,
              onTapDetection: (det) => _onDetectionTapped(det as Detection),
            ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Text(
              "Point camera at your clothes.\nTap an item to add it to your wardrobe.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
