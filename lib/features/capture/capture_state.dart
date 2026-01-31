enum CaptureStatus {
  idle,
  recording,
  uploading,
  processing,
  success,
  error,
}

class CaptureState {
  final CaptureStatus status;
  final double progress;
  final String? error;

  CaptureState({
    required this.status,
    this.progress = 0,
    this.error,
  });

  CaptureState copyWith({
    CaptureStatus? status,
    double? progress,
    String? error,
  }) {
    return CaptureState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}
