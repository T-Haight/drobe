import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'video_capture_controller.dart';
import 'video_capture_state.dart';
import 'providers/video_capture_repository_provider.dart';

class VideoCaptureScreen extends ConsumerStatefulWidget {
  const VideoCaptureScreen({super.key});

  @override
  ConsumerState<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends ConsumerState<VideoCaptureScreen> {
  bool cameraAccess = false;
  String? error;
  List<CameraDescription>? cameras;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    ref.read(videoCaptureControllerProvider.notifier).initCamera();
  }

  @override
  void dispose() {
    ref
        .read(videoCaptureControllerProvider.notifier)
        .cameraController
        ?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCaptureControllerProvider);
    final controller = ref
        .read(videoCaptureControllerProvider.notifier)
        .cameraController;

    // Show error state
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

    // Display camera feed
    if (state.status == VideoCaptureStatus.detecting) {
      return CameraPreview(controller);
    }

    // Display detected items with bounding boxes
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller),

          /// Framing overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30, width: 2),
              ),
            ),
          ),

          /// Instructions
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Text(
              "Slowly pan across your clothes.\nAvoid overlap.",
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