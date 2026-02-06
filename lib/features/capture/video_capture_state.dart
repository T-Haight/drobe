import 'package:drobe_application/shared/models/clothing_item.dart';

enum VideoCaptureStatus {
  idle,
  recording,
  preview,
  uploading,
  processing,
  success,
  error,
  detecting
}

class VideoCaptureState {
  final VideoCaptureStatus status;
  final double progress;
  final String? error;
  final String? recordedVideoPath;
  final List<ClothingItem> detectedItems;

  VideoCaptureState({
    required this.status,
    this.progress = 0,
    this.error,
    this.recordedVideoPath,
    this.detectedItems = const [],
  });

  VideoCaptureState copyWith({
    VideoCaptureStatus? status,
    double? progress,
    String? error,
    String? recordedVideoPath,
    bool clearVideoPath = false,
    List<ClothingItem>? detectedItems,
  }) {
    return VideoCaptureState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error,
      recordedVideoPath: clearVideoPath
          ? null
          : (recordedVideoPath ?? this.recordedVideoPath),
      detectedItems: detectedItems ?? this.detectedItems,
    );
  }
}
