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

    // Show preview screen after recording
    if (state.status == VideoCaptureStatus.preview &&
        state.recordedVideoPath != null) {
      return _buildPreviewScreen(state.recordedVideoPath!);
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
                if (state.status == VideoCaptureStatus.uploading)
                  const LinearProgressIndicator(),

                const SizedBox(height: 16),

                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: state.status == VideoCaptureStatus.recording
                      ? ref
                            .read(videoCaptureControllerProvider.notifier)
                            .stopRecording
                      : ref
                            .read(videoCaptureControllerProvider.notifier)
                            .startRecording,
                  child: Icon(
                    state.status == VideoCaptureStatus.recording
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

  Widget _buildPreviewScreen(String videoPath) {
    // Initialize video player if not already done
    if (_videoPlayerController == null ||
        _videoPlayerController!.dataSource != videoPath) {
      _videoPlayerController?.dispose();

      // Use network controller for web (blob URLs) and file controller for other platforms
      if (kIsWeb) {
        _videoPlayerController = VideoPlayerController.network(videoPath)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
            _videoPlayerController!.setLooping(true);
          });
      } else {
        _videoPlayerController = VideoPlayerController.file(File(videoPath))
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
            _videoPlayerController!.setLooping(true);
          });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Video'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(videoCaptureControllerProvider.notifier).cancelPreview();
            _videoPlayerController?.dispose();
            _videoPlayerController = null;
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child:
                  _videoPlayerController != null &&
                      _videoPlayerController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(videoCaptureControllerProvider.notifier)
                          .cancelPreview();
                      _videoPlayerController?.dispose();
                      _videoPlayerController = null;
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      ref
                          .read(videoCaptureControllerProvider.notifier)
                          .submitVideo();
                      try {
                        final repository = ref.read(
                          videoCaptureRepositoryProvider,
                        );
                        await repository.uploadVideo(videoPath);
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video uploaded successfully!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Upload failed: $e')),
                          );
                          ref
                              .read(videoCaptureControllerProvider.notifier)
                              .cancelPreview();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
