import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'capture_controller.dart';
import 'capture_state.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(captureControllerProvider.notifier).initCamera();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureControllerProvider);
    final controller = ref
        .read(captureControllerProvider.notifier)
        .cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

          /// Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (state.status == CaptureStatus.uploading)
                  const LinearProgressIndicator(),

                const SizedBox(height: 16),

                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: state.status == CaptureStatus.recording
                      ? ref
                            .read(captureControllerProvider.notifier)
                            .stopRecording
                      : ref
                            .read(captureControllerProvider.notifier)
                            .startRecording,
                  child: Icon(
                    state.status == CaptureStatus.recording
                        ? Icons.stop
                        : Icons.fiber_manual_record,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ref.read(captureControllerProvider.notifier).cameraController?.dispose();
    super.dispose();
  }
}
