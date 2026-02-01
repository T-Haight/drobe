enum VideoCaptureStatus {
  idle,
  recording,
  preview,
  uploading,
  processing,
  success,
  error,
}

class VideoCaptureState {
  final VideoCaptureStatus status;
  final double progress;
  final String? error;
  final String? recordedVideoPath;

  VideoCaptureState({
    required this.status,
    this.progress = 0,
    this.error,
    this.recordedVideoPath,
  });

  VideoCaptureState copyWith({
    VideoCaptureStatus? status,
    double? progress,
    String? error,
    String? recordedVideoPath,
    bool clearVideoPath = false,
  }) {
    return VideoCaptureState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error,
      recordedVideoPath: clearVideoPath
          ? null
          : (recordedVideoPath ?? this.recordedVideoPath),
    );
  }
}
