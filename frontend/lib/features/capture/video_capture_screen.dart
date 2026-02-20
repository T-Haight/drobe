import 'dart:async';

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

class _VideoCaptureScreenState extends ConsumerState<VideoCaptureScreen>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _confirmationOverlay;
  Timer? _confirmationTimer;

  void _onDetectionTapped(Detection det) async {
    final controller = ref.read(videoCaptureControllerProvider.notifier);
    final frame = controller.lastFrame;
    if (frame == null) return;

    try {
      await ref.read(wardrobeApiProvider).saveWardrobeItem(
        image: frame,
        bbox: {
          "x": det.x,
          "y": det.y,
          "width": det.width,
          "height": det.height,
        },
        label: det.label,
      );

      if (!mounted) return;
      _showConfirmation(det.label);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save ${det.label}")),
      );
    }
  }

  void _showConfirmation(String label) {
    _dismissConfirmation();

    final overlay = Overlay.of(context);
    _confirmationOverlay = OverlayEntry(
      builder: (context) => _ConfirmationPopup(label: label),
    );
    overlay.insert(_confirmationOverlay!);

    _confirmationTimer = Timer(const Duration(seconds: 2), () {
      _dismissConfirmation();
    });
  }

  void _dismissConfirmation() {
    _confirmationTimer?.cancel();
    _confirmationTimer = null;
    _confirmationOverlay?.remove();
    _confirmationOverlay = null;
  }

  @override
  void initState() {
    super.initState();
    ref.read(videoCaptureControllerProvider.notifier).initCamera();
  }

  @override
  void dispose() {
    _dismissConfirmation();
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

class _ConfirmationPopup extends StatefulWidget {
  final String label;
  const _ConfirmationPopup({required this.label});

  @override
  State<_ConfirmationPopup> createState() => _ConfirmationPopupState();
}

class _ConfirmationPopupState extends State<_ConfirmationPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _animController.reverse();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: Colors.green.shade700,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.label} added',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
